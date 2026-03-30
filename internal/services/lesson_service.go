package services

import (
	"errors"

	"github.com/cautro/morzelingo/internal/models"
	"github.com/cautro/morzelingo/internal/repo"
)

type CompleteLessonResult struct {
	Message      string `json:"message"`
	LessonDoneEN int    `json:"lesson_done_EN"`
	LessonDoneRU int    `json:"lesson_done_RU"`
	Streak       int    `json:"streak"`
	LastLogin    string `json:"last_login"`
	XP           int    `json:"xp"`
	Level        int    `json:"level"`
	Coins        int    `json:"coins"`
}

type LessonService struct {
	users   repo.UserRepository
	lessons repo.LessonRepository
}

func NewLessonService(users repo.UserRepository, lessons repo.LessonRepository) *LessonService {
	return &LessonService{
		users:   users,
		lessons: lessons,
	}
}

func (s *LessonService) ListLessons(lang string) ([]models.Lesson, error) {
	return s.lessons.ListByLang(lang)
}

func (s *LessonService) LessonByID(lang, id string) (models.Lesson, error) {
	lessons, err := s.lessons.ListByLang(lang)
	if err != nil {
		return models.Lesson{}, err
	}

	for _, lesson := range lessons {
		if id == stringInt(lesson.ID) {
			return lesson, nil
		}
	}

	return models.Lesson{}, ErrLessonNotFound
}

func (s *LessonService) CompleteLesson(username, lang string, lessonID int) (CompleteLessonResult, error) {
	lessons, err := s.lessons.ListByLang(lang)
	if err != nil {
		return CompleteLessonResult{}, err
	}

	if lessonID <= 0 || lessonID > len(lessons) {
		return CompleteLessonResult{}, ErrInvalidLessonID
	}

	updated, err := s.users.UpdateUser(username, func(u *models.User) error {
		var done int
		if lang == "ru" {
			done = u.LessonDone_RU
		} else {
			done = u.LessonDone_EN
		}

		if lessonID != done+1 {
			return ErrInvalidLessonOrder
		}

		u.XP += lessons[lessonID-1].XPReward

		if lang == "ru" {
			u.LessonDone_RU = done + 1
		} else {
			u.LessonDone_EN = done + 1
		}

		need := 1 + float64(u.Level)*1.5
		u.NeedXp = int(need * 100)

		if u.XP >= u.NeedXp {
			u.Level++
			u.XP -= u.NeedXp
		}

		mult := 1 + u.Level*2
		if mult > 100 {
			mult = 100
		}

		u.Coins += 10 * mult
		u.LastLogin = nowDate()
		return nil
	})
	if err != nil {
		if errors.Is(err, ErrInvalidLessonOrder) {
			return CompleteLessonResult{}, err
		}
		return CompleteLessonResult{}, ErrUserNotFound
	}

	return CompleteLessonResult{
		Message:      "lesson completed",
		LessonDoneEN: updated.LessonDone_EN,
		LessonDoneRU: updated.LessonDone_RU,
		Streak:       updated.Streak,
		LastLogin:    updated.LastLogin,
		XP:           updated.XP,
		Level:        updated.Level,
		Coins:        updated.Coins,
	}, nil
}
