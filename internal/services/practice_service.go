package services

import (
	"strconv"
	"strings"

	"github.com/cautro/morzelingo/internal/app"
	"github.com/cautro/morzelingo/internal/models"
	"github.com/cautro/morzelingo/internal/utils"
)

type PracticeService struct {
	app *app.App
}

type PracticeSubmitResult struct {
	Message string `json:"message"`
}

func NewPracticeService(a *app.App) *PracticeService {
	return &PracticeService{app: a}
}

func (s *PracticeService) PracticeByLesson(username, lang, lessonID string) (models.PracticeResponse, error) {
	lesson, err := s.lessonByID(lang, lessonID)
	if err != nil {
		return models.PracticeResponse{}, err
	}

	userCopy, err := s.app.GetUserCopy(username)
	if err != nil {
		return models.PracticeResponse{}, ErrUserNotFound
	}

	hardSymbols := utils.GetHardSymbols(userCopy.SymbolStats)
	symbolSet := make(map[string]bool)

	for _, symbol := range lesson.Symbols {
		symbolSet[symbol] = true
	}

	added := 0
	for _, symbol := range hardSymbols {
		if !symbolSet[symbol] && added < 3 {
			symbolSet[symbol] = true
			added++
		}
	}

	practiceSymbols := make([]string, 0, len(symbolSet))
	for symbol := range symbolSet {
		practiceSymbols = append(practiceSymbols, symbol)
	}

	if len(practiceSymbols) == 0 {
		practiceSymbols = lesson.Symbols
	}

	types := []string{"text", "morse", "audio"}
	questions := make([]models.PracticeQuestion, 0, 20)

	for i := 0; i < 20; i++ {
		randomType := types[randomInt(len(types))]
		correctWord := utils.WeightedRandom(practiceSymbols, userCopy.SymbolStats)

		switch randomType {
		case "text":
			questions = append(questions, models.PracticeQuestion{
				Type:     "text",
				Question: correctWord,
				Answer:   correctWord,
			})
		case "morse", "audio":
			questions = append(questions, models.PracticeQuestion{
				Type:     randomType,
				Question: utils.TextToMorse(correctWord, lang),
				Answer:   correctWord,
			})
		}
	}

	return models.PracticeResponse{Questions: questions}, nil
}

func (s *PracticeService) LettersPractice(letters, lang string) (models.PracticeResponse, error) {
	if lang == "ru" && strings.ContainsAny(letters, "ABCDEFGHIJKLMNOPQRSTUVWXYZ") {
		return models.PracticeResponse{}, ErrUseRussianLetters
	}

	types := []string{"text", "morse", "audio"}
	questions := make([]models.PracticeQuestion, 0, 20)

	symbols := []string{}
	if letters != "" {
		symbols = strings.Split(letters, "")
	}

	for i := 0; i < 20; i++ {
		randomType := types[randomInt(len(types))]
		randomNumberOfSymbols := randomInt(3) + 1
		correctWord := utils.GeneratePractice(symbols, randomNumberOfSymbols)

		switch randomType {
		case "text":
			questions = append(questions, models.PracticeQuestion{
				Type:     "text",
				Question: correctWord,
			})
		case "morse", "audio":
			questions = append(questions, models.PracticeQuestion{
				Type:     randomType,
				Question: utils.TextToMorse(correctWord, lang),
			})
		}
	}

	return models.PracticeResponse{Questions: questions}, nil
}

func (s *PracticeService) Submit(username string, updates []models.SymbolUpdate) (PracticeSubmitResult, error) {
	toSave, err := s.app.UpdateUser(username, func(u *models.User) error {
		for _, upd := range updates {
			found := false

			for i := range u.SymbolStats {
				if u.SymbolStats[i].Symbol == upd.Symbol {
					u.SymbolStats[i].Correct += upd.Correct
					u.SymbolStats[i].Wrong += upd.Wrong
					found = true
					break
				}
			}

			if !found {
				u.SymbolStats = append(u.SymbolStats, models.SymbolStat{
					Symbol:  upd.Symbol,
					Correct: upd.Correct,
					Wrong:   upd.Wrong,
				})
			}
		}

		u.XP += 1
		return nil
	})
	if err != nil {
		return PracticeSubmitResult{}, ErrUserNotFound
	}

	s.app.Saver.Schedule(toSave)
	return PracticeSubmitResult{Message: "statistics updated"}, nil
}

func (s *PracticeService) Freemode(username, lang, letters, mode string, count int) (models.PracticeResponse, error) {
	user, err := s.app.GetUserCopy(username)
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

func (s *PracticeService) ReplayLesson(lang, lessonID string) (models.PracticeResponse, error) {
	lesson, err := s.lessonByID(lang, lessonID)
	if err != nil {
		return models.PracticeResponse{}, err
	}

	types := []string{"text", "morse", "audio"}
	questions := make([]models.PracticeQuestion, 0, 20)

	for i := 0; i < 20; i++ {
		randomType := types[randomInt(len(types))]
		randomNumberOfSymbols := randomInt(3) + 1
		correctWord := utils.GeneratePractice(lesson.Symbols, randomNumberOfSymbols)

		switch randomType {
		case "text":
			questions = append(questions, models.PracticeQuestion{
				Type:     "text",
				Question: correctWord,
			})
		case "morse", "audio":
			questions = append(questions, models.PracticeQuestion{
				Type:     randomType,
				Question: utils.TextToMorse(correctWord, lang),
			})
		}
	}

	return models.PracticeResponse{Questions: questions}, nil
}

func (s *PracticeService) lessonByID(lang, lessonID string) (models.Lesson, error) {
	lessons, err := s.app.Storage.ReadLessons(lang)
	if err != nil {
		return models.Lesson{}, err
	}

	for _, lesson := range lessons {
		if strconv.Itoa(lesson.ID) == lessonID {
			return lesson, nil
		}
	}

	return models.Lesson{}, ErrLessonNotFound
}

func (s *PracticeService) buildFreemodeQuestion(level int, symbolPool []string, mode, lang string) models.PracticeQuestion {
	if level <= 10 {
		word := utils.GeneratePractice(symbolPool, 1+randomInt(2))
		return practiceQuestion(mode, word, lang)
	}

	if level <= 20 {
		word := utils.GeneratePractice(symbolPool, 2+randomInt(4))
		return practiceQuestion(mode, word, lang)
	}

	wordsCount := 2 + randomInt(3)
	parts := make([]string, 0, wordsCount)
	for i := 0; i < wordsCount; i++ {
		parts = append(parts, utils.GeneratePractice(symbolPool, 2+randomInt(4)))
	}

	return practiceQuestion(mode, strings.Join(parts, " "), lang)
}

func practiceQuestion(mode, text, lang string) models.PracticeQuestion {
	switch mode {
	case "morse":
		return models.PracticeQuestion{Type: "morse", Question: utils.TextToMorse(text, lang), Answer: text}
	case "audio":
		return models.PracticeQuestion{Type: "audio", Question: utils.TextToMorse(text, lang), Answer: text}
	default:
		return models.PracticeQuestion{Type: "text", Question: text, Answer: text}
	}
}
