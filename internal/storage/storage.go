package storage

import (
	"bytes"
	"database/sql"
	"encoding/json"
	"os"
	"path/filepath"
	"sync"

	"github.com/cautro/morzelingo/internal/models"
	_ "modernc.org/sqlite"
)

type Storage struct {
	db *sql.DB
	mu sync.Mutex
}

func New(path string) (*Storage, error) {
	if err := os.MkdirAll(filepath.Dir(path), 0o755); err != nil {
		return nil, err
	}

	db, err := sql.Open("sqlite", path)
	if err != nil {
		return nil, err
	}

	db.SetMaxOpenConns(1)

	st := &Storage{db: db}
	if err := st.init(); err != nil {
		_ = db.Close()
		return nil, err
	}

	return st, nil
}

func (s *Storage) Close() error {
	return s.db.Close()
}

func (s *Storage) ReadUsers() ([]models.User, error) {
	s.mu.Lock()
	defer s.mu.Unlock()

	rows, err := s.db.Query(`SELECT payload FROM users ORDER BY position`)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	users := make([]models.User, 0)
	for rows.Next() {
		var payload []byte
		if err := rows.Scan(&payload); err != nil {
			return nil, err
		}

		var user models.User
		if err := json.Unmarshal(payload, &user); err != nil {
			return nil, err
		}
		users = append(users, user)
	}

	return users, rows.Err()
}

func (s *Storage) SaveUsers(users []models.User) error {
	s.mu.Lock()
	defer s.mu.Unlock()

	tx, err := s.db.Begin()
	if err != nil {
		return err
	}
	defer tx.Rollback()

	if _, err := tx.Exec(`DELETE FROM users`); err != nil {
		return err
	}

	stmt, err := tx.Prepare(`INSERT INTO users(position, username, payload) VALUES(?, ?, ?)`)
	if err != nil {
		return err
	}
	defer stmt.Close()

	for i, user := range users {
		payload, err := json.Marshal(user)
		if err != nil {
			return err
		}
		if _, err := stmt.Exec(i, user.Username, payload); err != nil {
			return err
		}
	}

	return tx.Commit()
}

func (s *Storage) ReadDuels() ([]models.Duel, error) {
	s.mu.Lock()
	defer s.mu.Unlock()

	rows, err := s.db.Query(`SELECT payload FROM duels ORDER BY position`)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	duels := make([]models.Duel, 0)
	for rows.Next() {
		var payload []byte
		if err := rows.Scan(&payload); err != nil {
			return nil, err
		}

		var duel models.Duel
		if err := json.Unmarshal(payload, &duel); err != nil {
			return nil, err
		}
		duels = append(duels, duel)
	}

	return duels, rows.Err()
}

func (s *Storage) SaveDuels(duels []models.Duel) error {
	s.mu.Lock()
	defer s.mu.Unlock()

	tx, err := s.db.Begin()
	if err != nil {
		return err
	}
	defer tx.Rollback()

	if _, err := tx.Exec(`DELETE FROM duels`); err != nil {
		return err
	}

	stmt, err := tx.Prepare(`INSERT INTO duels(position, id, payload) VALUES(?, ?, ?)`)
	if err != nil {
		return err
	}
	defer stmt.Close()

	for i, duel := range duels {
		payload, err := json.Marshal(duel)
		if err != nil {
			return err
		}
		if _, err := stmt.Exec(i, duel.ID, payload); err != nil {
			return err
		}
	}

	return tx.Commit()
}

func (s *Storage) ReadFriendshipStreaks() ([]models.FriendshipStreak, error) {
	s.mu.Lock()
	defer s.mu.Unlock()

	rows, err := s.db.Query(`SELECT payload FROM friendship_streaks ORDER BY position`)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	streaks := make([]models.FriendshipStreak, 0)
	for rows.Next() {
		var payload []byte
		if err := rows.Scan(&payload); err != nil {
			return nil, err
		}

		var streak models.FriendshipStreak
		if err := json.Unmarshal(payload, &streak); err != nil {
			return nil, err
		}
		streaks = append(streaks, streak)
	}

	return streaks, rows.Err()
}

func (s *Storage) SaveFriendshipStreaks(streaks []models.FriendshipStreak) error {
	s.mu.Lock()
	defer s.mu.Unlock()

	tx, err := s.db.Begin()
	if err != nil {
		return err
	}
	defer tx.Rollback()

	if _, err := tx.Exec(`DELETE FROM friendship_streaks`); err != nil {
		return err
	}

	stmt, err := tx.Prepare(`INSERT INTO friendship_streaks(position, pair_key, payload) VALUES(?, ?, ?)`)
	if err != nil {
		return err
	}
	defer stmt.Close()

	for i, streak := range streaks {
		payload, err := json.Marshal(streak)
		if err != nil {
			return err
		}
		if _, err := stmt.Exec(i, friendshipPairKey(streak.User1, streak.User2), payload); err != nil {
			return err
		}
	}

	return tx.Commit()
}

func (s *Storage) ReadLessons(lang string) ([]models.Lesson, error) {
	s.mu.Lock()
	defer s.mu.Unlock()

	rows, err := s.db.Query(`SELECT payload FROM lessons WHERE lang = ? ORDER BY position`, lang)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	lessons := make([]models.Lesson, 0)
	for rows.Next() {
		var payload []byte
		if err := rows.Scan(&payload); err != nil {
			return nil, err
		}

		var lesson models.Lesson
		if err := json.Unmarshal(payload, &lesson); err != nil {
			return nil, err
		}
		lessons = append(lessons, lesson)
	}

	return lessons, rows.Err()
}

func (s *Storage) init() error {
	stmts := []string{
		`PRAGMA journal_mode = WAL`,
		`CREATE TABLE IF NOT EXISTS users (
			position INTEGER NOT NULL,
			username TEXT PRIMARY KEY,
			payload BLOB NOT NULL
		)`,
		`CREATE TABLE IF NOT EXISTS duels (
			position INTEGER NOT NULL,
			id TEXT PRIMARY KEY,
			payload BLOB NOT NULL
		)`,
		`CREATE TABLE IF NOT EXISTS friendship_streaks (
			position INTEGER NOT NULL,
			pair_key TEXT PRIMARY KEY,
			payload BLOB NOT NULL
		)`,
		`CREATE TABLE IF NOT EXISTS lessons (
			lang TEXT NOT NULL,
			position INTEGER NOT NULL,
			id INTEGER NOT NULL,
			payload BLOB NOT NULL,
			PRIMARY KEY(lang, id)
		)`,
	}

	for _, stmt := range stmts {
		if _, err := s.db.Exec(stmt); err != nil {
			return err
		}
	}

	return s.importLegacyData()
}

func (s *Storage) importLegacyData() error {
	if err := s.importUsersIfEmpty("data/users.json"); err != nil {
		return err
	}
	if err := s.importDuelsIfEmpty("data/duel.json"); err != nil {
		return err
	}
	if err := s.importFriendshipStreaksIfEmpty("data/friendship_streaks.json"); err != nil {
		return err
	}
	if err := s.importLessonsIfEmpty("en", "data/lessons-EN.json"); err != nil {
		return err
	}
	if err := s.importLessonsIfEmpty("ru", "data/lessons-RU.json"); err != nil {
		return err
	}

	return nil
}

func (s *Storage) importUsersIfEmpty(path string) error {
	count, err := s.rowCount(`SELECT COUNT(*) FROM users`)
	if err != nil || count > 0 {
		return err
	}

	users, err := readLegacySlice[models.User](path)
	if err != nil {
		return err
	}

	return s.SaveUsers(users)
}

func (s *Storage) importDuelsIfEmpty(path string) error {
	count, err := s.rowCount(`SELECT COUNT(*) FROM duels`)
	if err != nil || count > 0 {
		return err
	}

	duels, err := readLegacySlice[models.Duel](path)
	if err != nil {
		return err
	}

	return s.SaveDuels(duels)
}

func (s *Storage) importFriendshipStreaksIfEmpty(path string) error {
	count, err := s.rowCount(`SELECT COUNT(*) FROM friendship_streaks`)
	if err != nil || count > 0 {
		return err
	}

	streaks, err := readLegacySlice[models.FriendshipStreak](path)
	if err != nil {
		return err
	}

	return s.SaveFriendshipStreaks(streaks)
}

func (s *Storage) importLessonsIfEmpty(lang, path string) error {
	count, err := s.rowCount(`SELECT COUNT(*) FROM lessons WHERE lang = ?`, lang)
	if err != nil || count > 0 {
		return err
	}

	lessons, err := readLegacySlice[models.Lesson](path)
	if err != nil {
		return err
	}

	s.mu.Lock()
	defer s.mu.Unlock()

	tx, err := s.db.Begin()
	if err != nil {
		return err
	}
	defer tx.Rollback()

	stmt, err := tx.Prepare(`INSERT INTO lessons(lang, position, id, payload) VALUES(?, ?, ?, ?)`)
	if err != nil {
		return err
	}
	defer stmt.Close()

	for i, lesson := range lessons {
		payload, err := json.Marshal(lesson)
		if err != nil {
			return err
		}
		if _, err := stmt.Exec(lang, i, lesson.ID, payload); err != nil {
			return err
		}
	}

	return tx.Commit()
}

func (s *Storage) rowCount(query string, args ...any) (int, error) {
	var count int
	err := s.db.QueryRow(query, args...).Scan(&count)
	return count, err
}

func friendshipPairKey(a, b string) string {
	if a > b {
		a, b = b, a
	}
	return a + "::" + b
}

func readLegacySlice[T any](path string) ([]T, error) {
	data, err := os.ReadFile(path)
	if err != nil {
		if os.IsNotExist(err) {
			return []T{}, nil
		}
		return nil, err
	}

	if len(bytes.TrimSpace(data)) == 0 {
		return []T{}, nil
	}

	var items []T
	if err := json.Unmarshal(data, &items); err != nil {
		return nil, err
	}

	return items, nil
}
