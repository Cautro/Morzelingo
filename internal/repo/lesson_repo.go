package repo

import "github.com/cautro/morzelingo/internal/models"

type LessonRepository interface {
	ListByLang(lang string) ([]models.Lesson, error)
	GetByID(lang string, id int) (models.Lesson, error)
}
