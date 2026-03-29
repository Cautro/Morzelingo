package services

import (
	"errors"
	"sync"

	"github.com/cautro/morzelingo/internal/models"
	"github.com/cautro/morzelingo/internal/storage"
)

var duelMu sync.Mutex
var duelStorage *storage.Storage

type MatchmakeResult struct {
	DuelID string `json:"duel_id"`
	Status string `json:"status"`
	Role   string `json:"role"`
}

type TasksResult = models.PracticeResponse

type ScoreState struct {
	MyScore       int    `json:"my_score"`
	OpponentScore int    `json:"opponent_score"`
	OpponentDone  bool   `json:"opponent_done"`
	DuelStatus    string `json:"duel_status"`
}

type CompleteDuelResult struct {
	Result        string `json:"result"`
	MyScore       int    `json:"my_score"`
	OpponentScore int    `json:"opponent_score"`
	Winner        string `json:"winner"`
	BothDone      bool   `json:"both_done"`
}

type LeaveDuelResult struct {
	OK      bool   `json:"ok"`
	Message string `json:"message"`
}

type DuelListResult []models.Duel

func SetDuelStorage(st *storage.Storage) {
	duelStorage = st
}

func readDuelLocked() ([]models.Duel, error) {
	if duelStorage == nil {
		return nil, errors.New("duel storage is not initialized")
	}

	return duelStorage.ReadDuels()
}

func saveDuelLocked(duels []models.Duel) error {
	if duelStorage == nil {
		return errors.New("duel storage is not initialized")
	}

	return duelStorage.SaveDuels(duels)
}

func withDuels(fn func(duels []models.Duel) ([]models.Duel, error)) error {
	duelMu.Lock()
	defer duelMu.Unlock()

	duels, err := readDuelLocked()
	if err != nil {
		return err
	}

	updated, err := fn(duels)
	if err != nil {
		return err
	}
	if updated != nil {
		return saveDuelLocked(updated)
	}
	return nil
}

func ReadDuels() ([]models.Duel, error) {
	duelMu.Lock()
	defer duelMu.Unlock()

	return readDuelLocked()
}

func WithDuels(fn func(duels []models.Duel) ([]models.Duel, error)) error {
	return withDuels(fn)
}
