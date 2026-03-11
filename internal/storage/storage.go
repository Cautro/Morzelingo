package storage

import (
	"encoding/json"
	"errors"
	"io"
	"os"
	"path/filepath"
	"sync"

	"github.com/cautro/morzelingo/internal/models"
)

type Storage struct {
	path string
	mu   sync.Mutex
}

func New(path string) *Storage { return &Storage{path: path} }

func (s *Storage) ReadUsers() ([]models.User, error) {
	s.mu.Lock()
	defer s.mu.Unlock()
	f, err := os.Open(s.path)
	if errors.Is(err, os.ErrNotExist) {
		return []models.User{}, nil
	}
	if err != nil {
		return nil, err
	}
	defer f.Close()

	var users []models.User
	dec := json.NewDecoder(f)
	if err := dec.Decode(&users); err != nil {
		if err == io.EOF {
			return []models.User{}, nil
		}
		return nil, err
	}
	return users, nil
}

func (s *Storage) SaveUsers(users []models.User) error {
	s.mu.Lock()
	defer s.mu.Unlock()

	dir := filepath.Dir(s.path)
	if err := os.MkdirAll(dir, 0o755); err != nil {
		return err
	}

	b, err := json.MarshalIndent(users, "", "  ")
	if err != nil {
		return err
	}

	tmp := s.path + ".tmp"
	if err := os.WriteFile(tmp, b, 0o644); err != nil {
		return err
	}

	tf, err := os.OpenFile(tmp, os.O_RDWR, 0)
	if err == nil {
		_ = tf.Sync()
		tf.Close()
	}

	if err := os.Rename(tmp, s.path); err != nil {
		return err
	}

	dirf, err := os.Open(dir)
	if err == nil {
		_ = dirf.Sync()
		dirf.Close()
	}

	// _ = syscall.Sync
	return nil
}