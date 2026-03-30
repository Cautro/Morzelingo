package app

import (
	"errors"
	"github.com/cautro/morzelingo/internal/models"
)

func (a *App) ListLesson() ([]models.Lesson, error) {
	a.mu.RLock()
	defer a.mu.RUnlock()

	out := make([]models.Lesson, len(a.lessons))
	copy(out, a.lessons)
	return out, nil
}

func (a *App) GetByIDLesson(id int, lang string) (*models.Lesson, error) {
	a.mu.RLock()
	defer a.mu.RUnlock()

	for i := range a.lessons {
		if a.lessons[i].ID == id {
			l := a.lessons[i]
			return &l, nil
		}
	}

	return nil, errors.New("lesson not found")
}
