package services

import (
	"strconv"
	"strings"

	"github.com/cautro/morzelingo/internal/models"
	"github.com/cautro/morzelingo/internal/repo"
	"github.com/cautro/morzelingo/internal/utils"
)

type PracticeService struct {
	users   repo.UserRepository
	lessons repo.LessonRepository
}

type PracticeSubmitResult struct {
	Message string `json:"message"`
}

func NewPracticeService(users repo.UserRepository, lessons repo.LessonRepository) *PracticeService {
	return &PracticeService{
		users:   users,
		lessons: lessons,
	}
}

func (s *PracticeService) PracticeByLesson(username, lang, lessonID string) (models.PracticeResponse, error) {
	lesson, err := s.lessonByID(lang, lessonID)
	if err != nil {
		return models.PracticeResponse{}, err
	}

	userCopy, err := s.users.GetUserCopy(username)
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
	_, err := s.users.UpdateUser(username, func(u *models.User) error {
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

	return PracticeSubmitResult{Message: "statistics updated"}, nil
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
	id, err := strconv.Atoi(lessonID)
	if err != nil {
		return models.Lesson{}, ErrLessonNotFound
	}

	lesson, err := s.lessons.GetByID(lang, id)
	if err != nil {
		return models.Lesson{}, ErrLessonNotFound
	}

	return lesson, nil
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
