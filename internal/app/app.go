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

	mu      sync.RWMutex
	users   []models.User
	duels   []models.Duel
	lessons []models.Lesson
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

func (a *App) ListUser() ([]models.User) {
    a.mu.RLock()
    defer a.mu.RUnlock()

    out := make([]models.User, len(a.users))
    copy(out, a.users)
    return out
}

func (a *App) ListDuel() ([]models.Duel, error) {
	a.mu.RLock()
    defer a.mu.RUnlock()

    out := make([]models.Duel, len(a.duels))
    copy(out, a.duels)
    return out, nil
}

func (a *App) ListLesson() ([]models.Lesson, error) {
	a.mu.RLock()
    defer a.mu.RUnlock()

    out := make([]models.Lesson, len(a.lessons))
    copy(out, a.lessons)
    return out, nil
}

func (a *App) GetByIDDuel(duelID string) (*models.Duel, error) {
	a.mu.RLock()
    defer a.mu.RUnlock()

    for i := range a.duels {
        if a.duels[i].ID == duelID {
            d := a.duels[i]
            return &d, nil
        }
    }

    return nil, errors.New("duel not found")
}

func (a *App) GetByIDLesson(id int) (*models.Lesson, error) {
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

func (a *App) CreateUser(user models.User) []models.User {
    a.mu.Lock()
	defer a.mu.Unlock()

	a.users = append(a.users, user)
	cop := make([]models.User, len(a.users))
	copy(cop, a.users)
	
	return cop
}

func (a *App) CreateDuel(duel models.Duel) error {
	a.mu.Lock()
    defer a.mu.Unlock()

    a.duels = append(a.duels, duel)
    return nil
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

func (a *App) UpdateDuel(duelID string, fn func(d *models.Duel) error) error {
	a.mu.Lock()
    defer a.mu.Unlock()

    for i := range a.duels {
        if a.duels[i].ID == duelID {
            return fn(&a.duels[i])
        }
    }

    return errors.New("duel not found")
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

