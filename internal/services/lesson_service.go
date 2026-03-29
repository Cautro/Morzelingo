package services

import (
	"github.com/cautro/morzelingo/internal/app"
	"github.com/cautro/morzelingo/internal/models"
)

type LessonService struct {
	app *app.App
}

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

func NewLessonService(a *app.App) *LessonService {
	return &LessonService{app: a}
}

func (s *LessonService) ListLessons(lang string) ([]models.Lesson, error) {
	return s.app.Storage.ReadLessons(lang)
}

func (s *LessonService) LessonByID(lang, id string) (models.Lesson, error) {
	lessons, err := s.app.Storage.ReadLessons(lang)
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
	lessons, err := s.app.Storage.ReadLessons(lang)
	if err != nil {
		return CompleteLessonResult{}, err
	}

	if lessonID <= 0 || lessonID > len(lessons) {
		return CompleteLessonResult{}, ErrInvalidLessonID
	}

	toSave, err := s.app.UpdateUser(username, func(u *models.User) error {
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
		if err == ErrInvalidLessonOrder {
			return CompleteLessonResult{}, err
		}
		return CompleteLessonResult{}, ErrUserNotFound
	}

	s.app.Saver.Schedule(toSave)

	updated, ok := findUserSnapshot(toSave, username)
	if !ok {
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
