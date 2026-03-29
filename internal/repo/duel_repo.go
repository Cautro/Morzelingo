package repo

import "github.com/cautro/morzelingo/internal/models"

type DuelRepository interface {
    GetByIDDuel(duelID string) (*models.Duel, error)
    CreateDuel(duel models.Duel) error
    UpdateDuel(duelID string, fn func(d *models.Duel) error) error
    ListDuel() ([]models.Duel, error)
}