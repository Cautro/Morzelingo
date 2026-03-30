package services

import (
	"errors"
	"sync"

	"github.com/cautro/morzelingo/internal/models"
)

var errFakeNotFound = errors.New("not found")

type fakeUserRepo struct {
	mu    sync.Mutex
	users map[string]models.User
}

func newFakeUserRepo(users ...models.User) *fakeUserRepo {
	m := make(map[string]models.User, len(users))
	for _, u := range users {
		m[u.Username] = cloneUser(u)
	}
	return &fakeUserRepo{users: m}
}

func (r *fakeUserRepo) GetByUsername(username string) (models.User, error) {
	r.mu.Lock()
	defer r.mu.Unlock()

	u, ok := r.users[username]
	if !ok {
		return models.User{}, errFakeNotFound
	}
	return cloneUser(u), nil
}

func (r *fakeUserRepo) GetUserRaw(username string) (models.User, bool) {
	r.mu.Lock()
	defer r.mu.Unlock()

	u, ok := r.users[username]
	if !ok {
		return models.User{}, false
	}
	return cloneUser(u), true
}

func (r *fakeUserRepo) GetUserCopy(username string) (models.User, error) {
	r.mu.Lock()
	defer r.mu.Unlock()

	u, ok := r.users[username]
	if !ok {
		return models.User{}, errFakeNotFound
	}

	u = cloneUser(u)
	u.Password = ""
	return u, nil
}

func (r *fakeUserRepo) CreateUser(user models.User) error {
	r.mu.Lock()
	defer r.mu.Unlock()

	if _, exists := r.users[user.Username]; exists {
		return errors.New("user already exists")
	}

	r.users[user.Username] = cloneUser(user)
	return nil
}

func (r *fakeUserRepo) UpdateUser(username string, fn func(u *models.User) error) (models.User, error) {
	r.mu.Lock()
	defer r.mu.Unlock()

	u, ok := r.users[username]
	if !ok {
		return models.User{}, errFakeNotFound
	}

	copyUser := cloneUser(u)
	if err := fn(&copyUser); err != nil {
		return models.User{}, err
	}

	r.users[username] = cloneUser(copyUser)
	return cloneUser(copyUser), nil
}

func (r *fakeUserRepo) ListUser() []models.User {
	r.mu.Lock()
	defer r.mu.Unlock()

	out := make([]models.User, 0, len(r.users))
	for _, u := range r.users {
		out = append(out, cloneUser(u))
	}
	return out
}

type fakeStreakRepo struct {
	mu      sync.Mutex
	streaks []models.FriendshipStreak
}

func newFakeStreakRepo(streaks ...models.FriendshipStreak) *fakeStreakRepo {
	cp := make([]models.FriendshipStreak, len(streaks))
	copy(cp, streaks)
	return &fakeStreakRepo{streaks: cp}
}

func (r *fakeStreakRepo) List() ([]models.FriendshipStreak, error) {
	r.mu.Lock()
	defer r.mu.Unlock()

	out := make([]models.FriendshipStreak, len(r.streaks))
	copy(out, r.streaks)
	return out, nil
}

func (r *fakeStreakRepo) SaveAll(streaks []models.FriendshipStreak) error {
	r.mu.Lock()
	defer r.mu.Unlock()

	r.streaks = make([]models.FriendshipStreak, len(streaks))
	copy(r.streaks, streaks)
	return nil
}

func cloneUser(u models.User) models.User {
	c := u

	if u.Items != nil {
		c.Items = append([]int(nil), u.Items...)
	}
	if u.Friends != nil {
		c.Friends = append([]string(nil), u.Friends...)
	}
	if u.SymbolStats != nil {
		c.SymbolStats = append([]models.SymbolStat(nil), u.SymbolStats...)
	}
	if u.UnlockedAchievements != nil {
		c.UnlockedAchievements = append([]string(nil), u.UnlockedAchievements...)
	}

	return c
}