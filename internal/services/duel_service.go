package services

import (
	"math/rand"
	"time"

	"github.com/cautro/morzelingo/internal/app"
	"github.com/cautro/morzelingo/internal/models"
	"github.com/cautro/morzelingo/internal/utils"
	"github.com/google/uuid"
)

type DuelService struct {
	app *app.App
}

func NewDuelService(a *app.App) *DuelService {
	SetDuelStorage(a.Storage)
	return &DuelService{
		app: a,
	}
}

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

func (s *DuelService) GetTasks(username, lang, id string) (TasksResult, error) {
	var tasks models.PracticeResponse

	user, ok := s.app.GetUserRaw(username)
	if !ok {
		return TasksResult{}, ErrUserNotFound
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
		return TasksResult{}, ErrUnsupportedLanguage
	}

	err := withDuels(func(duels []models.Duel) ([]models.Duel, error) {
		for i := range duels {
			if duels[i].ID != id {
				continue
			}
			if duels[i].Player1 != username && duels[i].Player2 != username {
				return nil, ErrNotYourDuel
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
					questions = append(questions, models.PracticeQuestion{Type: t, Question: utils.TextToMorse(correct, lang)})
				}
			}
			duels[i].Tasks = models.PracticeResponse{Questions: questions}
			tasks = duels[i].Tasks
			return duels, nil
		}
		return nil, ErrDuelNotFound
	})

	switch err {
	case nil:
		return tasks, nil
	default:
		return TasksResult{}, err
	}
}

func (s *DuelService) UpdateScore(username, id string, score int) (ScoreState, error) {
	var state ScoreState

	err := withDuels(func(duels []models.Duel) ([]models.Duel, error) {
		for i := range duels {
			d := &duels[i]
			if d.ID != id {
				continue
			}
			if d.Status == "finished" || d.Status == "cancelled" {
				return nil, ErrDuelAlreadyFinished
			}
			if d.Status != "active" {
				return nil, ErrDuelNotActive
			}

			switch username {
			case d.Player1:
				d.P1Score = score
				state = ScoreState{
					MyScore:       d.P1Score,
					OpponentScore: d.P2Score,
					OpponentDone:  d.P2Done,
					DuelStatus:    d.Status,
				}
			case d.Player2:
				d.P2Score = score
				state = ScoreState{
					MyScore:       d.P2Score,
					OpponentScore: d.P1Score,
					OpponentDone:  d.P1Done,
					DuelStatus:    d.Status,
				}
			default:
				return nil, ErrNotYourDuel
			}

			return duels, nil
		}
		return nil, ErrDuelNotFound
	})
	if err != nil {
		return ScoreState{}, err
	}

	return state, nil
}

func (s *DuelService) CompleteDuel(username, id string, score int) (CompleteDuelResult, error) {
	var result CompleteDuelResult
	var completed *models.Duel

	err := withDuels(func(duels []models.Duel) ([]models.Duel, error) {
		for i := range duels {
			d := &duels[i]
			if d.ID != id {
				continue
			}

			isPlayer1 := d.Player1 == username
			isPlayer2 := d.Player2 == username
			if !isPlayer1 && !isPlayer2 {
				return nil, ErrNotYourDuel
			}

			if d.Status == "cancelled" {
				return nil, ErrDuelCancelled
			}
			if d.Status == "finished" {
				return nil, ErrAlreadyCompleted
			}
			if d.Status != "active" {
				return nil, ErrDuelNotActive
			}

			now := time.Now().UTC().Format(time.RFC3339)
			if isPlayer1 {
				if d.P1Done {
					return nil, ErrAlreadyCompleted
				}
				if score > 0 {
					d.P1Score = score
				}
				d.P1Done = true
				d.P1DoneAt = now
			} else {
				if d.P2Done {
					return nil, ErrAlreadyCompleted
				}
				if score > 0 {
					d.P2Score = score
				}
				d.P2Done = true
				d.P2DoneAt = now
			}

			bothDone := d.P1Done && d.P2Done
			if bothDone {
				d.Status = "finished"
				d.FinishedAt = now
				CalcWinner(d)

				copyDuel := *d
				completed = &copyDuel
			}

			myScore, opponentScore := d.P2Score, d.P1Score
			if isPlayer1 {
				myScore, opponentScore = d.P1Score, d.P2Score
			}

			result = CompleteDuelResult{
				Result:        ResultFor(username, d),
				MyScore:       myScore,
				OpponentScore: opponentScore,
				Winner:        d.Winner,
				BothDone:      bothDone,
			}

			return duels, nil
		}

		return nil, ErrDuelNotFound
	})
	if err != nil {
		return CompleteDuelResult{}, err
	}

	if completed != nil {
		ApplyRewards(s.app, completed, completed.Player1)
		ApplyRewards(s.app, completed, completed.Player2)
	}

	return result, nil
}

func (s *DuelService) Status(id string) (models.Duel, error) {
	duels, err := ReadDuels()
	if err != nil {
		return models.Duel{}, err
	}

	for _, duel := range duels {
		if duel.ID == id {
			return duel, nil
		}
	}

	return models.Duel{}, ErrDuelNotFound
}

func (s *DuelService) List() (DuelListResult, error) {
	duels, err := ReadDuels()
	if err != nil {
		return nil, err
	}

	return duels, nil
}

func (s *DuelService) LeaveDuel(username, id string) (LeaveDuelResult, error) {
	err := withDuels(func(duels []models.Duel) ([]models.Duel, error) {
		for i := range duels {
			d := &duels[i]
			if d.ID != id {
				continue
			}
			if d.Player1 != username && d.Player2 != username {
				return nil, ErrNotParticipant
			}
			if d.Status == "finished" || d.Status == "cancelled" {
				return nil, ErrDuelAlreadyFinished
			}

			now := time.Now().UTC().Format(time.RFC3339)
			if d.Player1 == username {
				d.Player1Left = true
				if d.Player2 == "" {
					d.Status = "cancelled"
				} else {
					d.Winner = d.Player2
					d.Status = "finished"
					d.FinishedAt = now
				}
			} else {
				d.Player2Left = true
				d.Winner = d.Player1
				d.Status = "finished"
				d.FinishedAt = now
			}

			return duels, nil
		}
		return nil, ErrDuelNotFound
	})
	if err != nil {
		return LeaveDuelResult{}, err
	}

	return LeaveDuelResult{OK: true, Message: "you left the duel"}, nil
}
