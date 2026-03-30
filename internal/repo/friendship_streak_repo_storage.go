package repo

import (
	"github.com/cautro/morzelingo/internal/models"
	"github.com/cautro/morzelingo/internal/storage"
)

type StorageFriendshipStreakRepo struct {
	st *storage.Storage
}

func NewStorageFriendshipStreakRepo(st *storage.Storage) *StorageFriendshipStreakRepo {
	return &StorageFriendshipStreakRepo{st: st}
}

func (r *StorageFriendshipStreakRepo) List() ([]models.FriendshipStreak, error) {
	return r.st.ReadFriendshipStreaks()
}

func (r *StorageFriendshipStreakRepo) SaveAll(streaks []models.FriendshipStreak) error {
	return r.st.SaveFriendshipStreaks(streaks)
}
