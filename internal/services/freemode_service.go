package services

import "github.com/cautro/morzelingo/internal/models"

func (s *PracticeService) Freemode(username, lang, letters, mode string, count int) (models.PracticeResponse, error) {
	user, err := s.users.GetUserCopy(username)
	if err != nil {
		return models.PracticeResponse{}, ErrUserNotFound
	}

	symbolPool := make([]string, 0)
	if letters != "" {
		for _, r := range letters {
			symbolPool = append(symbolPool, string(r))
		}
	} else {
		if lang == "ru" {
			for k := range models.RussianMorseDictionary {
				symbolPool = append(symbolPool, k)
			}
		} else {
			for k := range models.EnglishMorseDictionary {
				if len(k) == 1 {
					symbolPool = append(symbolPool, k)
				}
			}
		}
	}

	if len(symbolPool) == 0 {
		return models.PracticeResponse{}, ErrNoSymbolsAvailable
	}

	questions := make([]models.PracticeQuestion, 0, count)
	for i := 0; i < count; i++ {
		questions = append(questions, s.buildFreemodeQuestion(user.Level, symbolPool, mode, lang))
	}

	return models.PracticeResponse{Questions: questions}, nil
}

func (s *PracticeService) FreemodeComplite(username string) error {
	_, err := s.users.UpdateUser(username, func(u *models.User) error {
		mult := 1 + float64(u.Level)/100
		u.XP += int(10 * mult)
		u.Coins += int(50 * mult)
		return nil
	})
	if err != nil {
		return err
	}

	return nil
}
