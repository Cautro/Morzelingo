package app

import (
	"errors"
	"fmt"
	"sync"

	"github.com/cautro/morzelingo/internal/models"
	"github.com/cautro/morzelingo/internal/storage"
	"github.com/cautro/morzelingo/internal/worker"
)

type App struct {
	Storage *storage.Storage
	Saver   *worker.Saver
	Secret  string

	mu    sync.RWMutex
	users []models.User
	duels []models.Duel
}

func NewApp(initial []models.User, st *storage.Storage, saver *worker.Saver, secret string) *App {
	cop := make([]models.User, len(initial))
	copy(cop, initial)
	return &App{
		Storage: st,
		Saver:   saver,
		Secret:  secret,
		users:   cop,
	}
}

func (a *App) GetUsers() []models.User {
	a.mu.RLock()
	defer a.mu.RUnlock()
	out := make([]models.User, len(a.users))
	copy(out, a.users)
	for i := range out {
		out[i].Password = ""
	}
	return out
}

func (a *App) GetAllDuels() []models.Duel {
	a.mu.RLock()
	defer a.mu.RUnlock()
	out := make([]models.Duel, len(a.duels))
	copy(out, a.duels)
	return out
}

func (a *App) AddUser(u models.User) []models.User {
	a.mu.Lock()
	defer a.mu.Unlock()
	a.users = append(a.users, u)
	cop := make([]models.User, len(a.users))
	copy(cop, a.users)
	return cop
}

func (a *App) GetUserRaw(username string) (models.User, bool) { 
	a.mu.RLock() 
	defer a.mu.RUnlock() 
	for i := range a.users { 
		if a.users[i].Username == username { 
			return a.users[i], true } 
		} 
		return models.User{}, false
	}

func (a *App) FindUserByUsername(username string) (int, bool) {
	a.mu.RLock()
	defer a.mu.RUnlock()
	for i := range a.users {
		if a.users[i].Username == username {
			return i, true
		}
	}
	return -1, false
}

func (a *App) UpdateUser(username string, fn func(u *models.User) error) ([]models.User, error) {
	a.mu.Lock()
	defer a.mu.Unlock()
	for i := range a.users {
		if a.users[i].Username == username {
			if err := fn(&a.users[i]); err != nil {
				return nil, err
			}
			cop := make([]models.User, len(a.users))
			copy(cop, a.users)
			return cop, nil
		}
	}
	return nil, errors.New("user not found")
}

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
