package services

import (
    "encoding/json"
    "os"
    "sync"
    "github.com/cautro/morzelingo/internal/models"
)

var duelMu sync.Mutex

type MatchmakeResult struct {
	DuelID string `json:"duel_id"`
	Status string `json:"status"`
	Role   string `json:"role"`
}

type TasksResult struct {
    Type     string `json:"type"`
	Question string `json:"question"`
	Answer   string `json:"answer,omitempty"`
}

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

type DuelListResult []models.Duel


func readDuelLocked() ([]models.Duel, error) {
    b, err := os.ReadFile("data/duel.json")
    if err != nil {
        if os.IsNotExist(err) {
            return []models.Duel{}, nil
        }
        return nil, err
    }
    var duels []models.Duel
    if err := json.Unmarshal(b, &duels); err != nil {
        return nil, err
    }
    return duels, nil
}

func saveDuelLocked(duels []models.Duel) error {
    data, err := json.MarshalIndent(duels, "", "  ")
    if err != nil {
        return err
    }
    return os.WriteFile("data/duel.json", data, 0o644)
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

