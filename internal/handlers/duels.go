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
)

var duelMutex sync.Mutex

func ReadDuel() ([]models.Duel, error) {
	filename := "data/duel.json"
	b, err := osReadFile(filename)
	if err != nil {
		return nil, err
	}
	var duels []models.Duel
	if err := json.Unmarshal(b, &duels); err != nil {
		return nil, err
	}
	return duels, nil
}

func SaveDuel(duels []models.Duel) error {
	data, err := json.MarshalIndent(duels, "", "  ")
	if err != nil {
		return err
	}

	return os.WriteFile("data/duel.json", data, 0644)
}

func MakeCreateDuelHandler(a *app.App) gin.HandlerFunc  {
	return func (c *gin.Context)  {
		username := c.GetString("username")

		duels, err := ReadDuel()
		if err != nil {
			c.JSON(http.StatusInternalServerError, gin.H{"error": "Error to read duels"})
		}

		IDForDuel := "duel_" + time.Now().Format("2006-01-02")
		duel := models.Duel {
			ID: IDForDuel,
			Player1: username,
			Status: "waiting",
		}

		duels = append(duels, duel)
		SaveDuel(duels)
	}
}

func MakeJoinDuelHandler(a *app.App) gin.HandlerFunc {
	return func (c *gin.Context)  {
		username := c.GetString("username")

		duels, err := ReadDuel()
		if err != nil {
			c.JSON(http.StatusInternalServerError, gin.H{"error": "Error to read duels"})
		}

		NeedStatus := "waiting"

		for i := range duels {
			if duels[i].Status == NeedStatus {
				duels[i].Player2 = username
				duels[i].Status = "active"

				break
			}
		}

		SaveDuel(duels)
	}
}

func MakeStatusDuelHandler(a *app.App) gin.HandlerFunc {
	return func (c *gin.Context)  {
		id := c.Param("id")
		duels, err := ReadDuel()
		if err != nil {
			c.JSON(http.StatusInternalServerError, gin.H{"error": "Error to read duels"})
			return 
		}

		for i := range duels {
			if duels[i].ID == id {
				c.JSON(http.StatusOK, gin.H{
					"IDDuels": duels[i].ID,
					"Status": duels[i].Status,
					"player1": duels[i].Player1,
					"player2": duels[i].Player2,
					"player1_score": duels[i].P1Score,
					"player2_score": duels[i].P2Score,
					"player1_time": duels[i].P1Time,
					"player2_time": duels[i].P2Time,
					"winner": duels[i].Winner,
					"created_at": duels[i].CreatedAt,
					"tasks": duels[i].Tasks,
				})
			}
		}
	}
}

func MakeListDuelHandler(a *app.App) gin.HandlerFunc {
	return func (c *gin.Context)  {
		c.JSON(http.StatusOK, a.GetAllDuels())
	}
}

func MakeFinishDuelHandler(a *app.App) gin.HandlerFunc {
	return func (c *gin.Context)  {
		username := c.GetString("username")
		id := c.Param("id")
		var ThatUserScore int

		duels, err := ReadDuel()
		if err != nil {
			c.JSON(http.StatusInternalServerError, gin.H{"error":"Error to read duels"})
		}

		user, err := a.GetUserCopy(username)
		if err != nil {
			c.JSON(http.StatusInternalServerError, gin.H{"error":"Server error"})
		}

		for i := range duels {
			if duels[i].ID == id {
				if duels[i].Player1 == username {
					ThatUserScore = duels[i].P1Score
				} else if duels[i].Player2 == username {
					ThatUserScore = duels[i].P2Score
				} else {
					c.JSON(http.StatusInternalServerError, gin.H{"error": "Server error"})
					return 
				}

				if user.MaxScoreInDuel >= ThatUserScore {
					toSave, err := a.UpdateUser(username, func(u *models.User) error {
						u.MaxScoreInDuel = ThatUserScore
						return nil
					})
					if err != nil {
						c.JSON(http.StatusInternalServerError, gin.H{"error":"Server error"})
					}

					var updated models.User
					for _, u := range toSave {
						if u.Username == username {
							updated = u
							break
						}
					}
					
					a.Saver.Schedule(toSave)
					c.JSON(http.StatusOK, gin.H{
						"max_score_in_duel": updated.MaxScoreInDuel,
					})
				}
				if duels[i].Winner == username {
					toSave, err := a.UpdateUser(username, func(u *models.User) error {
						mult := u.Level/3
						u.XP += 50*mult
						u.Coins += 100*mult
						u.NeedXp -= 10*mult
						return nil
					})
					if err != nil {
						c.JSON(http.StatusInternalServerError, gin.H{"error": "Server error"})
						return
					}

					var updated models.User
					for _, u := range toSave {
						if u.Username == username {
							updated = u
							break
						}
					}

					a.Saver.Schedule(toSave)
					c.JSON(http.StatusOK, gin.H{
						"NeedXp": updated.NeedXp,
						"Coins":  updated.Coins,
						"XP":     updated.XP,
					})
				} else {
					toSave, err := a.UpdateUser(username, func(u *models.User) error {
						mult := u.Level/3
						u.XP += int(5*mult)
						u.Coins += int(10*mult)
						u.NeedXp -= int(1*mult)
						return nil
					})
					if err != nil {
						c.JSON(http.StatusInternalServerError, gin.H{"error": "Server error"})
						return
					}

					var updated models.User
					for _, u := range toSave {
						if u.Username == username {
							updated = u
							break
						}
					}

					a.Saver.Schedule(toSave)
					c.JSON(http.StatusOK, gin.H{
						"NeedXp": updated.NeedXp,
						"Coins":  updated.Coins,
						"XP":     updated.XP,
					})
				}
			}
		}
		// c.JSON(http.StatusOK, gin.H{})
	}
}

func MakeGetTasksHandler(a *app.App) gin.HandlerFunc {
	return func (c *gin.Context)  {
		username := c.GetString("username")
		lang := c.DefaultQuery("lang", "en")
		id := c.Param("id")

		var symbols []string
		var symbolsWords []string
		var symbolsOffer []string
		questions := make([]models.PracticeQuestion, 0, 5)

		switch lang {
		case "en":
			for k := range models.EnglishMorseDictionary {
				symbols = append(symbols, k)
			}
			symbolsWords = models.EnglishWords
			symbolsOffer = models.EnglishPhrases
		case "ru":
			for k := range models.RussianMorseDictionary {
				symbols = append(symbols, k)
			}
		} 

		duels, err := ReadDuel()
		if err != nil {
			c.JSON(http.StatusInternalServerError, gin.H{"error": "Error to read duels"})
			return
		}

		user, ok := a.GetUserRaw(username)
		if !ok {
			c.JSON(http.StatusInternalServerError, gin.H{"error":"Server error"})
			return 
		}

		for u := range duels {
			if duels[u].ID == id {
				types := []string{"text", "morse", "audio"}

				for i := 0; i < 5; i++ {
					switch user.Level {
					case 10:
						randomType := types[rand.Intn(len(types))]
						randomNumberOfSymbols := rand.Intn(3) + 1
						correctWord := generatePractice(symbols, randomNumberOfSymbols)
						switch randomType {
						case "text":
							questions = append(questions, models.PracticeQuestion{Type: "text", Question: correctWord})
						case "morse", "audio":
							questions = append(questions, models.PracticeQuestion{Type: randomType, Question: textToMorse(correctWord, lang)})
						}
					case 20:
						randomType := types[rand.Intn(len(types))]
						randomNumberOfSymbols := rand.Intn(len(models.EnglishWords))
						correctWord := generatePractice(symbolsWords, randomNumberOfSymbols)
						switch randomType {
						case "text":
							questions = append(questions, models.PracticeQuestion{Type: "text", Question: correctWord})
						case "morse", "audio":
							questions = append(questions, models.PracticeQuestion{Type: randomType, Question: textToMorse(correctWord, lang)})
						}
					case 30:
						randomType := types[rand.Intn(len(types))]
						randomNumberOfSymbols := rand.Intn(3) + 3
						correctWord := generatePractice(symbolsOffer, randomNumberOfSymbols)
						switch randomType {
						case "text":
							questions = append(questions, models.PracticeQuestion{Type: "text", Question: correctWord})
						case "morse", "audio":
							questions = append(questions, models.PracticeQuestion{Type: randomType, Question: textToMorse(correctWord, lang)})
						}
					}
				}
			}
			duel := models.Duel {
				Tasks: models.PracticeResponse{Questions: questions},
			}
			duels = append(duels, duel)
			SaveDuel(duels)
		}
	}
}