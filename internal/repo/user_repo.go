package repo

import "github.com/cautro/morzelingo/internal/models"

type UserRepository interface {
    GetByUsername(username string) (*models.User, error)
    CreateUser(user models.User) error
    UpdateUser(username string, fn func(u *models.User) error) error
    ListUser() ([]models.User, error)
}