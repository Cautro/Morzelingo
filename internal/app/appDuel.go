package app

import (
	"errors"
	"github.com/cautro/morzelingo/internal/models"
)


func (a *App) ListDuel() ([]models.Duel, error) {
	a.mu.RLock()
	defer a.mu.RUnlock()

	out := make([]models.Duel, len(a.duels))
	copy(out, a.duels)
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

func (a *App) CreateDuel(duel models.Duel) error {
	a.mu.Lock()
	defer a.mu.Unlock()

	a.duels = append(a.duels, duel)
	return nil
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

