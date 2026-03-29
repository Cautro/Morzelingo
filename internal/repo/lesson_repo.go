package repo

import "github.com/cautro/morzelingo/internal/models"

type LessonRepository interface {
    GetByIDLesson(id int) (*models.Lesson, error)
    ListLesson() ([]models.Lesson, error)
}