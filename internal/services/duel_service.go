package services

import (
	"github.com/cautro/morzelingo/internal/app"
	"github.com/cautro/morzelingo/internal/models"
	"time"
	// "net/http"
	"github.com/google/uuid"
	"math/rand"
)

type DuelService struct {
	app *app.App
}

func NewDuelService(a *app.App) *DuelService {
	return &DuelService{
		app: a,
	}
}

type sentinelErr struct{ msg string }

func (e *sentinelErr) Error() string { return e.msg }

var (
    errNotFound        = &sentinelErr{"not found"}
    errForbidden       = &sentinelErr{"forbidden"}
    errAlreadyFinished = &sentinelErr{"already finished"}
    errAlreadyDone     = &sentinelErr{"already done"}
    errNotActive       = &sentinelErr{"duel not active"}
	errServerError     = &sentinelErr{"server error"}
)


func (s *DuelService) MatchmakeDuel(username string) (MatchmakeResult, error) {
	var result MatchmakeResult

	err := withDuels(func(duels []models.Duel) ([]models.Duel, error) {
		for i := range duels {
			d := &duels[i]

			if d.Status != "waiting" {
				continue
			}

			if d.Player1 == username {
				result = MatchmakeResult{
					DuelID: d.ID,
					Status: "waiting",
					Role:   "player1",
				}
				return nil, nil
			}

			d.Player2 = username
			d.Status = "active"
			d.StartedAt = time.Now().UTC().Format(time.RFC3339)

			result = MatchmakeResult{
				DuelID: d.ID,
				Status: "active",
				Role:   "player2",
			}
			return duels, nil
		}

		nd := models.Duel{
			ID:        "duel_" + uuid.NewString(),
			Player1:   username,
			Status:    "waiting",
			CreatedAt: time.Now().UTC().Format(time.RFC3339),
		}

		result = MatchmakeResult{
			DuelID: nd.ID,
			Status: "waiting",
			Role:   "player1",
		}

		return append(duels, nd), nil
	})

	return result, err
}

func (s *DuelService) GetTasks(username, lang string, id int) (TasksResult, error) {
	var tasks models.PracticeResponse

	user, ok := s.app.GetUserRaw(username)
	if !ok {
		return TasksResult{}, nil
	}

	var symbols, words, phrases []string
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
		return TasksResult{}, nil
	}

	err := withDuels(func(duels []models.Duel) ([]models.Duel, error) {
		for i := range duels {
			if duels[i].ID != string(id) {
				continue
			}
			if duels[i].Player1 != username && duels[i].Player2 != username {
				return nil, nil
			}
			if len(duels[i].Tasks.Questions) > 0 {
				tasks = duels[i].Tasks
				return nil, nil
			}
			types := []string{"text", "morse", "audio"}
			questions := make([]models.PracticeQuestion, 0, 10)
			for j := 0; j < 10; j++ { // 10 вопросов вместо 5
				correct := pickContent(user.Level, symbols, words, phrases)
				if correct == "" {
					continue
				}
				t := types[rand.Intn(len(types))]
				switch t {
				case "text":
					questions = append(questions, models.PracticeQuestion{Type: "text", Question: correct})
				default:
					questions = append(questions, models.PracticeQuestion{Type: t, Question: textToMorse(correct, lang)})
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
		return tasks, nil
	case errNotFound:
		return nil, errNotFound
	case errForbidden:
		return nil, errForbidden
	default:
		return nil, errServerError
	}
}