package app

import (
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