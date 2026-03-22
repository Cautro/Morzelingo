package handlers

import (
	"encoding/json"
	"os"
	"net/http"
	"time"
	"sync"
	"math/rand"

	"github.com/cautro/morzelingo/internal/app"
	"github.com/cautro/morzelingo/internal/models"
	"github.com/gin-gonic/gin"
	"github.com/google/uuid"
)

var duelMutex sync.Mutex
var e = http.StatusInternalServerError

func ReadDuel() ([]models.Duel, error) {
	duelMutex.Lock()
    defer duelMutex.Unlock()

    filename := "data/duel.json"
    b, err := os.ReadFile(filename)
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

func SaveDuel(duels []models.Duel) error {
	duelMutex.Lock()
    defer duelMutex.Unlock()

    data, err := json.MarshalIndent(duels, "", "  ")
    if err != nil {
        return err
    }
    return os.WriteFile("data/duel.json", data, 0o644)
}

func MakeCreateDuelHandler(a *app.App) gin.HandlerFunc  {
	return func (c *gin.Context)  {
		username := c.GetString("username")

		duels, err := ReadDuel()
		if err != nil {
			c.JSON(http.StatusInternalServerError, gin.H{"error": "Error to read duels"})
            return 
		}

		newDuel := models.Duel{
            ID:        "duel_" + uuid.NewString(),
            Player1:   username,
            Status:    "waiting",
            CreatedAt: time.Now().UTC().Format(time.RFC3339),
        }

		duels = append(duels, newDuel)
        if err := SaveDuel(duels); err != nil {
            c.JSON(http.StatusInternalServerError, gin.H{"error":"failed to save duel"})
            return
        }
		c.JSON(http.StatusCreated, gin.H{"id": newDuel.ID, "status": newDuel.Status})
	}
}

func MakeJoinDuelHandler(a *app.App) gin.HandlerFunc {
    return func(c *gin.Context) {
        username := c.GetString("username")
        var duelID string

        duels, err := ReadDuel()
        if err != nil {
            c.JSON(http.StatusInternalServerError, gin.H{"error":"failed to read duels"})
            return
        }

        joined := false
        for i := range duels {
            if duels[i].Status == "waiting" && duels[i].Player1 != username {
                duels[i].Player2 = username
                duels[i].Status = "active"
                duels[i].CreatedAt = time.Now().UTC().Format(time.RFC3339)
                duelID = duels[i].ID
                joined = true
                break
            }
        }
        if !joined {
            c.JSON(http.StatusNotFound, gin.H{"error":"no available duel to join"})
            return
        }
        if err := SaveDuel(duels); err != nil {
            c.JSON(http.StatusInternalServerError, gin.H{"error":"failed to save duel"})
            return
        }
        c.JSON(http.StatusOK, gin.H{"ok": true, "DuelID": duelID})
    }
}

func MakeStatusDuelHandler(a *app.App) gin.HandlerFunc {
    return func(c *gin.Context) {
        id := c.Param("id")
        duels, err := ReadDuel()
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
        c.JSON(http.StatusNotFound, gin.H{"error":"duel not found"})
    }
}

func MakeListDuelHandler(a *app.App) gin.HandlerFunc {
	return func (c *gin.Context)  {
		c.JSON(http.StatusOK, a.GetAllDuels())
	}
}

func MakeFinishDuelHandler(a *app.App) gin.HandlerFunc {
    return func(c *gin.Context) {
        username := c.GetString("username")
        id := c.Param("id")

        duels, err := ReadDuel()
        if err != nil {
            c.JSON(http.StatusInternalServerError, gin.H{"error": "failed to read duels"})
            return
        }

        foundIdx := -1
        for i := range duels {
            if duels[i].ID == id {
                foundIdx = i
                break
            }
        }

        if foundIdx == -1 {
            c.JSON(http.StatusNotFound, gin.H{"error": "duel not found"})
            return
        }

        duel := duels[foundIdx]

        if duel.Player1 != username && duel.Player2 != username {
            c.JSON(http.StatusForbidden, gin.H{"error": "you are not a participant of this duel"})
            return
        }

        if duel.Status == "finished" {
            c.JSON(http.StatusBadRequest, gin.H{"error": "duel already finished"})
            return
        }

        if !duel.P1Submitted || !duel.P2Submitted {
            c.JSON(http.StatusBadRequest, gin.H{"error": "duel not finished yet"})
            return
        }

        if duel.P1Score > duel.P2Score {
            duels[foundIdx].Winner = duel.Player1
        } else if duel.P2Score > duel.P1Score {
            duels[foundIdx].Winner = duel.Player2
        } else {
            duels[foundIdx].Winner = "draw"
        }

        duels[foundIdx].Status = "finished"

        if err := SaveDuel(duels); err != nil {
            c.JSON(http.StatusInternalServerError, gin.H{"error": "failed to save duel"})
            return
        }

        duel = duels[foundIdx]

        var thatUserScore int
        if duel.Player1 == username {
            thatUserScore = duel.P1Score
        } else {
            thatUserScore = duel.P2Score
        }

        user, err := a.GetUserCopy(username)
        if err != nil {
            c.JSON(http.StatusInternalServerError, gin.H{"error": "user not found"})
            return
        }

        if thatUserScore > user.MaxScoreInDuel {
            toSave, err := a.UpdateUser(username, func(u *models.User) error {
                u.MaxScoreInDuel = thatUserScore
                return nil
            })
            if err == nil {
                a.Saver.Schedule(toSave)
            }
        }

        result := "lose"
        if duel.Winner == username {
            result = "win"
            toSave, err := a.UpdateUser(username, func(u *models.User) error {
                mult := 1 + u.Level/3
                u.XP += 50 * mult
                u.Coins += 100 * mult
                u.NeedXp = max(0, u.NeedXp-10*mult)
                return nil
            })
            if err == nil {
                a.Saver.Schedule(toSave)
            }
        } else if duel.Winner == "draw" {
            result = "draw"
        } else {
            toSave, err := a.UpdateUser(username, func(u *models.User) error {
                mult := 1 + u.Level/3
                u.XP += 5 * mult
                u.Coins += 10 * mult
                u.NeedXp = max(0, u.NeedXp-1*mult)
                return nil
            })
            if err == nil {
                a.Saver.Schedule(toSave)
            }
        }

        c.JSON(http.StatusOK, gin.H{"result": result})
    }
}

func MakeGetTasksHandler(a *app.App) gin.HandlerFunc {
	return func(c *gin.Context) {

		username := c.GetString("username")
		lang := c.DefaultQuery("lang", "en")
		id := c.Param("id")

		var symbols []string
		var words []string
		var phrases []string

		duels, err := ReadDuel()
		if err != nil {
			c.JSON(http.StatusInternalServerError, gin.H{"error": "failed to read duels"})
			return
		}

		user, ok := a.GetUserRaw(username)
		if !ok {
			c.JSON(http.StatusInternalServerError, gin.H{"error": "user not found"})
			return
		}

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

		}

		for i := range duels {

			if duels[i].ID != id {
				continue
			}

			// проверяем что игрок участник
			if duels[i].Player1 != username && duels[i].Player2 != username {
				c.JSON(http.StatusForbidden, gin.H{"error": "not your duel"})
				return
			}

			// ЕСЛИ ЗАДАНИЯ УЖЕ ЕСТЬ → ПРОСТО ВЕРНУТЬ
			if len(duels[i].Tasks.Questions) > 0 {
				c.JSON(http.StatusOK, duels[i].Tasks)
				return
			}

			// ИНАЧЕ СГЕНЕРИРОВАТЬ
			types := []string{"text", "morse", "audio"}

			questions := make([]models.PracticeQuestion, 0, 5)

			for j := 0; j < 5; j++ {

				randomType := types[rand.Intn(len(types))]

				var correct string

				if user.Level <= 10 {

					count := rand.Intn(3) + 1
					correct = generatePractice(symbols, count)

				} else if user.Level <= 20 {

					correct = words[rand.Intn(len(words))]

				} else {

					correct = phrases[rand.Intn(len(phrases))]
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

			duels[i].Tasks = models.PracticeResponse{
				Questions: questions,
			}

			err := SaveDuel(duels)
			if err != nil {
				c.JSON(http.StatusInternalServerError, gin.H{"error": "save error"})
				return
			}

			c.JSON(http.StatusOK, duels[i].Tasks)
			return
		}

		c.JSON(http.StatusNotFound, gin.H{"error": "duel not found"})
	}
}

func MakeGetScoreHandler(a *app.App) gin.HandlerFunc {
    return func (c *gin.Context) {
        id := c.Param("id")
        var in models.FinishScore
        if err := c.BindJSON(&in); err != nil {
            c.JSON(http.StatusBadRequest, gin.H{"error":"invalid body"})
            return
        }
        username := c.GetString("username")
        duels, err := ReadDuel()
        if err != nil {
            c.JSON(e, gin.H{"error":"Server error"})
            return
        }

        found := false
        var idx int

        for i := range duels {
            if duels[i].ID == id {
                idx = i
                if duels[i].Player1 == username {
                    duels[i].P1Score = in.Score
                    duels[i].P1Submitted = true
                } else if duels[i].Player2 == username {
                    duels[i].P2Score = in.Score
                    duels[i].P2Submitted = true
                } else {
                    c.JSON(http.StatusForbidden, gin.H{"error":"you are not a participant"})
                    return
                }
                found = true
                break
            }
        }

        if !found {
            c.JSON(http.StatusNotFound, gin.H{"error":"duel not found"})
            return
        }

        if duels[idx].P1Submitted && duels[idx].P2Submitted {
            if duels[idx].P1Score > duels[idx].P2Score {
                duels[idx].Winner = duels[idx].Player1
            } else if duels[idx].P2Score > duels[idx].P1Score {
                duels[idx].Winner = duels[idx].Player2
            } else {
                duels[idx].Winner = "draw"
            }

            duels[idx].Status = "finished"
        }

        if err := SaveDuel(duels); err != nil {
            c.JSON(http.StatusInternalServerError, gin.H{"error":"failed to save"})
            return
        }

        if duels[idx].Winner == "" {
            c.JSON(http.StatusBadRequest, gin.H{
                "error": "duel not finished yet",
            })
            return
        }

        c.JSON(http.StatusOK, gin.H{
            "score": in.Score,
            "ok": true,
        })
    }
}

func MakeLeaveDuelsHandler(a *app.App) gin.HandlerFunc {
	return func(c *gin.Context) {
		username := c.GetString("username")
		id := c.Param("id")

		duels, err := ReadDuel()
		if err != nil {
			c.JSON(http.StatusInternalServerError, gin.H{"error": "failed to read duels"})
			return
		}

		found := false

		for i := range duels {
			if duels[i].ID != id {
				continue
			}

			found = true

			if duels[i].Player1 != username && duels[i].Player2 != username {
				c.JSON(http.StatusForbidden, gin.H{"error": "you are not a participant of this duel"})
				return
			}

			if duels[i].Status == "finished" {
				c.JSON(http.StatusBadRequest, gin.H{"error": "duel already finished"})
				return
			}

			if duels[i].Player1 == username {
				duels[i].Player1 = duels[i].Player1 + "_left"

				if duels[i].Player2 == "" {
					duels[i].Winner = ""
					duels[i].Status = "cancelled"
				} else {
					duels[i].Winner = duels[i].Player2
					duels[i].Status = "finished"
				}
			} else {
				duels[i].Player2 = duels[i].Player2 + "_left"
				duels[i].Winner = duels[i].Player1
				duels[i].Status = "finished"
			}

			break
		}

		if !found {
			c.JSON(http.StatusNotFound, gin.H{"error": "duel not found"})
			return
		}

		if err := SaveDuel(duels); err != nil {
			c.JSON(http.StatusInternalServerError, gin.H{"error": "failed to save duel"})
			return
		}

		c.JSON(http.StatusOK, gin.H{"ok": true, "message": "You left the duel"})
	}
}