package services

import "github.com/cautro/morzelingo/internal/models"

type UserRepository interface {
    GetByUsername(username string) (*models.User, error)
    GetUserRaw(username string) (models.User, bool)
    GetUserCopy(username string) (models.User, error)
    CreateUser(user models.User) []models.User
    UpdateUser(username string, fn func(u *models.User) error) ([]models.User, error)
    ListUser() []models.User
}

type LessonRepository interface {
    GetByIDLesson(id int, lang string) (*models.Lesson, error)
    ListLesson() ([]models.Lesson, error)
}

type FriendshipStreakRepo interface {
	List() ([]models.FriendshipStreak, error)
	SaveAll([]models.FriendshipStreak) error
}

type DuelRepo interface {
	List() ([]models.Duel, error)
	GetByID(id string) (models.Duel, error)
	Create(duel models.Duel) error
	Update(id string, fn func(*models.Duel) error) (models.Duel, error)
}