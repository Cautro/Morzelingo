package handlers

import (
	"encoding/json"
	"math/rand"
	"net/http"
	"os"
	"sync"
	"time"

	"github.com/cautro/morzelingo/internal/app"
	"github.com/cautro/morzelingo/internal/models"
	"github.com/gin-gonic/gin"
	"github.com/google/uuid"
)

// duelMu защищает весь цикл чтение→изменение→запись
var duelMu sync.Mutex

// readDuelLocked читает дуэли. Вызывать только под duelMu.
func readDuelLocked() ([]models.Duel, error) {
	b, err := os.ReadFile("data/duel.json")
	if err != nil {
		if os.IsNotExist(err) {
			return []models.Duel{}, nil
		}
		return nil, err
	}
	var duels []models.Duel
	if err := json.Unmarshal(b, &duels); err != nil {
		return nil, err
	}
	return duels, nil
}

// saveDuelLocked сохраняет дуэли. Вызывать только под duelMu.
func saveDuelLocked(duels []models.Duel) error {
	data, err := json.MarshalIndent(duels, "", "  ")
	if err != nil {
		return err
	}
	return os.WriteFile("data/duel.json", data, 0o644)
}

// withDuels выполняет fn под мьютексом — единственный безопасный способ
// читать и писать дуэли. Устраняет race condition.
func withDuels(fn func(duels []models.Duel) ([]models.Duel, error)) error {
	duelMu.Lock()
	defer duelMu.Unlock()

	duels, err := readDuelLocked()
	if err != nil {
		return err
	}
	updated, err := fn(duels)
	if err != nil {
		return err
	}
	if updated != nil {
		return saveDuelLocked(updated)
	}
	return nil
}

func determineWinner(duel *models.Duel) {
	switch {
	case duel.P1Score > duel.P2Score:
		duel.Winner = duel.Player1
	case duel.P2Score > duel.P1Score:
		duel.Winner = duel.Player2
	default:
		duel.Winner = "draw"
	}
	duel.Status = "finished"
}

// ─── Handlers ────────────────────────────────────────────────────────────────

func MakeMatchmakeDuelHandler(a *app.App) gin.HandlerFunc {
	return func(c *gin.Context) {
		username := c.GetString("username")

		type Response struct {
			DuelID string `json:"duel_id"`
			Status string `json:"status"`  // "waiting" | "active"
			Role   string `json:"role"`    // "player1" | "player2"
		}

		var result Response

		err := withDuels(func(duels []models.Duel) ([]models.Duel, error) {
			for i := range duels {
				d := &duels[i]
				if d.Status != "waiting" {
					continue
				}
				if d.Player1 == username {
					result = Response{
						DuelID: d.ID,
						Status: "waiting",
						Role:   "player1",
					}
					return nil, nil 
				}
				d.Player2 = username
				d.Status = "active"
				d.StartedAt = time.Now().UTC().Format(time.RFC3339)
				result = Response{
					DuelID: d.ID,
					Status: "active",
					Role:   "player2",
				}
				return duels, nil
			}

			newDuel := models.Duel{
				ID:        "duel_" + uuid.NewString(),
				Player1:   username,
				Status:    "waiting",
				CreatedAt: time.Now().UTC().Format(time.RFC3339),
			}
			result = Response{
				DuelID: newDuel.ID,
				Status: "waiting",
				Role:   "player1",
			}
			return append(duels, newDuel), nil
		})

		if err != nil {
			c.JSON(http.StatusInternalServerError, gin.H{"error": "matchmaking failed"})
			return
		}

		statusCode := http.StatusOK
		if result.Status == "waiting" {
			statusCode = http.StatusCreated 
		}
		c.JSON(statusCode, result)
	}
}

func MakeStatusDuelHandler(a *app.App) gin.HandlerFunc {
	return func(c *gin.Context) {
		id := c.Param("id")

		duelMu.Lock()
		defer duelMu.Unlock()

		duels, err := readDuelLocked()
		if err != nil {
			c.JSON(http.StatusInternalServerError, gin.H{"error": "failed to read duels"})
			return
		}
		for i := range duels {
			if duels[i].ID == id {
				c.JSON(http.StatusOK, duels[i])
				return
			}
		}
		c.JSON(http.StatusNotFound, gin.H{"error": "duel not found"})
	}
}

func MakeListDuelHandler(a *app.App) gin.HandlerFunc {
	return func(c *gin.Context) {
		duelMu.Lock()
		defer duelMu.Unlock()

		duels, err := readDuelLocked()
		if err != nil {
			c.JSON(http.StatusInternalServerError, gin.H{"error": "failed to read duels"})
			return
		}
		c.JSON(http.StatusOK, duels)
	}
}

func MakeGetScoreHandler(a *app.App) gin.HandlerFunc {
	return func(c *gin.Context) {
		id := c.Param("id")
		username := c.GetString("username")

		var in models.FinishScore
		if err := c.BindJSON(&in); err != nil {
			c.JSON(http.StatusBadRequest, gin.H{"error": "invalid body"})
			return
		}

		var finalDuel models.Duel

		err := withDuels(func(duels []models.Duel) ([]models.Duel, error) {
			for i := range duels {
				if duels[i].ID != id {
					continue
				}
				d := &duels[i]

				if d.Status == "finished" {
					return nil, errAlreadyFinished
				}

				switch username {
				case d.Player1:
					if d.P1Submitted {
						return nil, errAlreadySubmitted
					}
					d.P1Score = in.Score
					d.P1Submitted = true
				case d.Player2:
					if d.P2Submitted {
						return nil, errAlreadySubmitted
					}
					d.P2Score = in.Score
					d.P2Submitted = true
				default:
					return nil, errForbidden
				}

				if d.P1Submitted && d.P2Submitted {
					determineWinner(d)
				}

				finalDuel = *d
				return duels, nil
			}
			return nil, errNotFound
		})

		switch err {
		case nil:
		case errNotFound:
			c.JSON(http.StatusNotFound, gin.H{"error": "duel not found"})
			return
		case errForbidden:
			c.JSON(http.StatusForbidden, gin.H{"error": "you are not a participant"})
			return
		case errAlreadyFinished:
			c.JSON(http.StatusBadRequest, gin.H{"error": "duel already finished"})
			return
		case errAlreadySubmitted:
			c.JSON(http.StatusBadRequest, gin.H{"error": "score already submitted"})
			return
		default:
			c.JSON(http.StatusInternalServerError, gin.H{"error": "server error"})
			return
		}

		if finalDuel.Status == "finished" {
			applyDuelRewards(a, &finalDuel, username)
		}

		if finalDuel.Winner == "" {
			c.JSON(http.StatusOK, gin.H{
				"ok":      true,
				"message": "score saved, waiting for opponent",
				"score":   in.Score,
			})
			return
		}

		result := resultFor(username, &finalDuel)
		c.JSON(http.StatusOK, gin.H{"ok": true, "score": in.Score, "result": result})
	}
}

func MakeFinishDuelHandler(a *app.App) gin.HandlerFunc {
	return func(c *gin.Context) {
		username := c.GetString("username")
		id := c.Param("id")

		duelMu.Lock()
		defer duelMu.Unlock()

		duels, err := readDuelLocked()
		if err != nil {
			c.JSON(http.StatusInternalServerError, gin.H{"error": "failed to read duels"})
			return
		}

		for i := range duels {
			if duels[i].ID != id {
				continue
			}
			d := &duels[i]

			if d.Player1 != username && d.Player2 != username {
				c.JSON(http.StatusForbidden, gin.H{"error": "you are not a participant of this duel"})
				return
			}
			if d.Status != "finished" {
				c.JSON(http.StatusBadRequest, gin.H{"error": "duel not finished yet"})
				return
			}

			c.JSON(http.StatusOK, gin.H{"result": resultFor(username, d)})
			return
		}
		c.JSON(http.StatusNotFound, gin.H{"error": "duel not found"})
	}
}

func MakeGetTasksHandler(a *app.App) gin.HandlerFunc {
	return func(c *gin.Context) {
		username := c.GetString("username")
		lang := c.DefaultQuery("lang", "en")
		id := c.Param("id")

		user, ok := a.GetUserRaw(username)
		if !ok {
			c.JSON(http.StatusInternalServerError, gin.H{"error": "user not found"})
			return
		}

		var symbols []string
		var words []string
		var phrases []string

		switch lang {
		case "en":
			for k := range models.EnglishMorseDictionary {
				symbols = append(symbols, k)
			}
			words = models.EnglishWords
			phrases = models.EnglishPhrases
		case "ru":
			for k := range models.RussianMorseDictionary {
				symbols = append(symbols, k)
			}
			words = models.RussianWords  
			phrases = models.RussianPhrases
		default:
			c.JSON(http.StatusBadRequest, gin.H{"error": "unsupported language"})
			return
		}

		var tasks models.PracticeResponse

		err := withDuels(func(duels []models.Duel) ([]models.Duel, error) {
			for i := range duels {
				if duels[i].ID != id {
					continue
				}
				if duels[i].Player1 != username && duels[i].Player2 != username {
					return nil, errForbidden
				}
				if len(duels[i].Tasks.Questions) > 0 {
					tasks = duels[i].Tasks
					return nil, nil 
				}

				types := []string{"text", "morse", "audio"}
				questions := make([]models.PracticeQuestion, 0, 5)

				for j := 0; j < 5; j++ {
					randomType := types[rand.Intn(len(types))]
					correct := pickContent(user.Level, symbols, words, phrases)
					if correct == "" {
						continue
					}

					switch randomType {
					case "text":
						questions = append(questions, models.PracticeQuestion{
							Type:     "text",
							Question: correct,
						})
					case "morse", "audio":
						questions = append(questions, models.PracticeQuestion{
							Type:     randomType,
							Question: textToMorse(correct, lang),
						})
					}
				}

				duels[i].Tasks = models.PracticeResponse{Questions: questions}
				tasks = duels[i].Tasks
				return duels, nil
			}
			return nil, errNotFound
		})

		switch err {
		case nil:
		case errNotFound:
			c.JSON(http.StatusNotFound, gin.H{"error": "duel not found"})
			return
		case errForbidden:
			c.JSON(http.StatusForbidden, gin.H{"error": "not your duel"})
			return
		default:
			c.JSON(http.StatusInternalServerError, gin.H{"error": "server error"})
			return
		}

		c.JSON(http.StatusOK, tasks)
	}
}

func MakeLeaveDuelsHandler(a *app.App) gin.HandlerFunc {
	return func(c *gin.Context) {
		username := c.GetString("username")
		id := c.Param("id")

		err := withDuels(func(duels []models.Duel) ([]models.Duel, error) {
			for i := range duels {
				if duels[i].ID != id {
					continue
				}
				d := &duels[i]

				if d.Player1 != username && d.Player2 != username {
					return nil, errForbidden
				}
				if d.Status == "finished" || d.Status == "cancelled" {
					return nil, errAlreadyFinished
				}

				if d.Player1 == username {
					d.Player1Left = true
					if d.Player2 == "" {
						d.Status = "cancelled"
					} else {
						d.Winner = d.Player2
						d.Status = "finished"
					}
				} else {
					d.Player2Left = true
					d.Winner = d.Player1
					d.Status = "finished"
				}

				return duels, nil
			}
			return nil, errNotFound
		})

		switch err {
		case nil:
			c.JSON(http.StatusOK, gin.H{"ok": true, "message": "you left the duel"})
		case errNotFound:
			c.JSON(http.StatusNotFound, gin.H{"error": "duel not found"})
		case errForbidden:
			c.JSON(http.StatusForbidden, gin.H{"error": "you are not a participant"})
		case errAlreadyFinished:
			c.JSON(http.StatusBadRequest, gin.H{"error": "duel already finished or cancelled"})
		default:
			c.JSON(http.StatusInternalServerError, gin.H{"error": "failed to save"})
		}
	}
}

// ─── Вспомогательные функции ─────────────────────────────────────────────────

var (
	errNotFound       = &sentinelErr{"not found"}
	errForbidden      = &sentinelErr{"forbidden"}
	errAlreadyFinished = &sentinelErr{"already finished"}
	errAlreadySubmitted = &sentinelErr{"already submitted"}
)

type sentinelErr struct{ msg string }
func (e *sentinelErr) Error() string { return e.msg }

func resultFor(username string, d *models.Duel) string {
	switch {
	case d.Winner == username:
		return "win"
	case d.Winner == "draw":
		return "draw"
	default:
		return "lose"
	}
}

// applyDuelRewards начисляет XP/монеты и обновляет MaxScoreInDuel.
// Вызывается один раз — сразу после завершения дуэли в GetScore.
func applyDuelRewards(a *app.App, duel *models.Duel, username string) {
	var myScore int
	if duel.Player1 == username {
		myScore = duel.P1Score
	} else {
		myScore = duel.P2Score
	}

	user, err := a.GetUserCopy(username)
	if err != nil {
		return
	}

	if myScore > user.MaxScoreInDuel {
		toSave, err := a.UpdateUser(username, func(u *models.User) error {
			u.MaxScoreInDuel = myScore
			return nil
		})
		if err == nil {
			a.Saver.Schedule(toSave)
		}
	}

	result := resultFor(username, duel)
	toSave, err := a.UpdateUser(username, func(u *models.User) error {
		mult := 1 + u.Level/3
		switch result {
		case "win":
			u.XP += 50 * mult
			u.Coins += 100 * mult
			u.NeedXp = max(0, u.NeedXp-10*mult)
		case "lose":
			u.XP += 5 * mult
			u.Coins += 10 * mult
			u.NeedXp = max(0, u.NeedXp-1*mult)
		// draw — на ваше усмотрение
		}
		return nil
	})
	if err == nil {
		a.Saver.Schedule(toSave)
	}
}

// pickContent выбирает текст для задания в зависимости от уровня.
// FIX: теперь защищён от пустых срезов — не будет паники.
func pickContent(level int, symbols, words, phrases []string) string {
	switch {
	case level <= 10 || len(words) == 0:
		if len(symbols) == 0 {
			return ""
		}
		count := rand.Intn(3) + 1
		return generatePractice(symbols, count)
	case level <= 20 || len(phrases) == 0:
		return words[rand.Intn(len(words))]
	default:
		return phrases[rand.Intn(len(phrases))]
	}
}