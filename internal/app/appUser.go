package app

import (
	"errors"
	"fmt"
	"github.com/cautro/morzelingo/internal/models"
)

func (a *App) GetUserCopy(username string) (models.User, error) {
	a.mu.RLock()
	defer a.mu.RUnlock()
	for i := range a.users {
		if a.users[i].Username == username {
			copyu := a.users[i]
			copyu.Password = ""
			return copyu, nil
		}
	}
	return models.User{}, fmt.Errorf("user %s not found", username)
}

func (a *App) GetByUsername(username string) (*models.User, error) {
	a.mu.RLock()
	defer a.mu.RUnlock()

	for i := range a.users {
		if a.users[i].Username == username {
			u := a.users[i]
			return &u, nil
		}
	}

	return nil, errors.New("user not found")
}

func (a *App) GetUserRaw(username string) (models.User, bool) {
	a.mu.RLock()
	defer a.mu.RUnlock()
	for i := range a.users {
		if a.users[i].Username == username {
			return a.users[i], true
		}
	}
	return models.User{}, false
}

func (a *App) UpdateUser(username string, fn func(u *models.User) error) ([]models.User, error) {
	a.mu.Lock()
	defer a.mu.Unlock()

	for i := range a.users {
		if a.users[i].Username == username {
			err := fn(&a.users[i])
			if err != nil {
				return nil, err
			}
			out := make([]models.User, len(a.users))
			copy(out, a.users)

			return out, nil
		}
	}

	return nil, errors.New("user not found")
}

func (a *App) CreateUser(user models.User) []models.User {
	a.mu.Lock()
	defer a.mu.Unlock()

	a.users = append(a.users, user)
	cop := make([]models.User, len(a.users))
	copy(cop, a.users)

	return cop
}

func (a *App) ListUser() []models.User {
	a.mu.RLock()
	defer a.mu.RUnlock()

	out := make([]models.User, len(a.users))
	copy(out, a.users)
	return out
}