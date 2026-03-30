package repo

import (
	"errors"

	"github.com/cautro/morzelingo/internal/models"
	"github.com/cautro/morzelingo/internal/storage"
)

var ErrLessonNotFound = errors.New("lesson not found")

type StorageLessonRepo struct {
	st *storage.Storage
}

func NewStorageLessonRepo(st *storage.Storage) *StorageLessonRepo {
	return &StorageLessonRepo{st: st}
}

func (r *StorageLessonRepo) ListByLang(lang string) ([]models.Lesson, error) {
	return r.st.ReadLessons(lang)
}

func (r *StorageLessonRepo) GetByID(lang string, id int) (models.Lesson, error) {
	lessons, err := r.st.ReadLessons(lang)
	if err != nil {
		return models.Lesson{}, err
	}

	for _, lesson := range lessons {
		if lesson.ID == id {
			return lesson, nil
		}
	}

	return models.Lesson{}, ErrLessonNotFound
}
