package repo

import "github.com/cautro/morzelingo/internal/models"

type FriendshipStreakRepository interface {
	List() ([]models.FriendshipStreak, error)
	SaveAll([]models.FriendshipStreak) error
}
