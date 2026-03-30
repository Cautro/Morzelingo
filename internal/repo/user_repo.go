package repo

import "github.com/cautro/morzelingo/internal/models"

type UserRepository interface {
	GetByUsername(username string) (models.User, error)
	GetUserRaw(username string) (models.User, bool)
	GetUserCopy(username string) (models.User, error)
	CreateUser(user models.User) error
	UpdateUser(username string, fn func(u *models.User) error) (models.User, error)
	ListUser() []models.User
}
