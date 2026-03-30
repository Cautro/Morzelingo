package repo

import (
	"errors"

	"github.com/cautro/morzelingo/internal/app"
	"github.com/cautro/morzelingo/internal/models"
)

var ErrUserNotFound = errors.New("user not found")

type AppUserRepo struct {
	app *app.App
}

func NewAppUserRepo(a *app.App) *AppUserRepo {
	return &AppUserRepo{app: a}
}

func (r *AppUserRepo) GetUserRaw(username string) (models.User, bool) {
	return r.app.GetUserRaw(username)
}

func (r *AppUserRepo) GetByUsername(username string) (models.User, error) {
	u, err := r.app.GetByUsername(username)
	if err != nil {
		return models.User{}, ErrUserNotFound
	}
	return *u, nil
}

func (r *AppUserRepo) GetUserCopy(username string) (models.User, error) {
	return r.app.GetUserCopy(username)
}

func (r *AppUserRepo) CreateUser(user models.User) error {
	users := r.app.CreateUser(user)
	r.app.Saver.Schedule(users)
	return nil
}

func (r *AppUserRepo) UpdateUser(username string, fn func(*models.User) error) (models.User, error) {
	users, err := r.app.UpdateUser(username, fn)
	if err != nil {
		return models.User{}, err
	}

	r.app.Saver.Schedule(users)

	for _, u := range users {
		if u.Username == username {
			return u, nil
		}
	}

	return models.User{}, ErrUserNotFound
}

func (r *AppUserRepo) ListUser() []models.User {
	return r.app.ListUser()
}
