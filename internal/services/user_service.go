package services

import (
	"log"
	"time"

	"github.com/cautro/morzelingo/internal/models"
	"github.com/cautro/morzelingo/internal/repo"
	"github.com/cautro/morzelingo/internal/utils"
)

type UserService struct {
	users   repo.UserRepository
	streaks repo.FriendshipStreakRepository
}

type ProfileResult struct {
	Username             string              `json:"username"`
	Email                string              `json:"email"`
	XP                   int                 `json:"xp"`
	LessonDoneRU         int                 `json:"lesson_done_ru"`
	LessonDoneEN         int                 `json:"lesson_done_en"`
	Level                int                 `json:"level"`
	Coins                int                 `json:"coins"`
	Items                []int               `json:"items"`
	Streak               int                 `json:"streak"`
	ReferralCode         string              `json:"referral_code"`
	ReferredBy           string              `json:"referred_by"`
	ReferralCount        int                 `json:"referred_count"`
	Friends              []string            `json:"friends"`
	SymbolStats          []models.SymbolStat `json:"symbol_stats"`
	NeedXP               int                 `json:"need_xp"`
	UnlockedAchievements []string            `json:"UnlockedAchievements"`
	RegisteredDate       string              `json:"registred_date"`
	LastLogin            string              `json:"LastLogin"`
	Elo                  int                 `json:"elo"`
	MaxScore             int                 `json:"max_score"`
	DuelsWin             int                 `json:"duelswin"`
}

type FriendsListResult struct {
	Friends []string `json:"friends"`
}

type FriendMutationResult struct {
	OK        bool     `json:"ok"`
	FriendsOf string   `json:"friends_of"`
	Friends   []string `json:"friends"`
	Message   string   `json:"message,omitempty"`
}

func NewUserService(users repo.UserRepository, streaks repo.FriendshipStreakRepository) *UserService {
	return &UserService{
		users:   users,
		streaks: streaks,
	}
}

func (s *UserService) ListUsers() []models.User {
	return s.users.ListUser()
}

func (s *UserService) Profile(username string) (ProfileResult, error) {
	u, err := s.users.GetUserCopy(username)
	if err != nil {
		return ProfileResult{}, ErrUserNotFound
	}

	return ProfileResult{
		Username:             u.Username,
		Email:                u.Email,
		XP:                   u.XP,
		LessonDoneRU:         u.LessonDone_RU,
		LessonDoneEN:         u.LessonDone_EN,
		Level:                u.Level,
		Coins:                u.Coins,
		Items:                u.Items,
		Streak:               u.Streak,
		ReferralCode:         u.ReferralCode,
		ReferredBy:           u.ReferredBy,
		ReferralCount:        u.ReferralCount,
		Friends:              u.Friends,
		SymbolStats:          u.SymbolStats,
		NeedXP:               u.NeedXp,
		UnlockedAchievements: u.UnlockedAchievements,
		RegisteredDate:       u.RegisteredDate,
		LastLogin:            u.LastLogin,
		Elo:                  u.Elo,
		MaxScore:             u.MaxScoreInDuel,
		DuelsWin:             u.DuelsWin,
	}, nil
}

func (s *UserService) ListFriends(username string) (FriendsListResult, error) {
	u, err := s.users.GetUserCopy(username)
	if err != nil {
		return FriendsListResult{}, ErrUserNotFound
	}

	return FriendsListResult{Friends: u.Friends}, nil
}

func (s *UserService) AddFriend(username, friend string) (FriendMutationResult, error) {
	if friend == username {
		return FriendMutationResult{}, ErrCannotAddYourself
	}

	if _, err := s.users.GetByUsername(friend); err != nil {
		return FriendMutationResult{}, ErrFriendNotFound
	}

	updated, err := s.users.UpdateUser(username, func(u *models.User) error {
		for _, f := range u.Friends {
			if f == friend {
				return nil
			}
		}
		u.Friends = append(u.Friends, friend)
		return nil
	})
	if err != nil {
		return FriendMutationResult{}, ErrUserNotFound
	}

	_, err = s.users.UpdateUser(friend, func(u *models.User) error {
		for _, f := range u.Friends {
			if f == username {
				return nil
			}
		}
		u.Friends = append(u.Friends, username)
		return nil
	})
	if err != nil {
		return FriendMutationResult{}, ErrFriendNotFound
	}

	if err := s.touchFriendshipStreak(username, friend); err != nil {
		log.Printf("warning: friendship streak update failed: %v", err)
	}

	return FriendMutationResult{
		OK:        true,
		FriendsOf: username,
		Friends:   updated.Friends,
	}, nil
}

func (s *UserService) UpdateFriendshipStreaks(username string) error {
	currentUser, err := s.users.GetUserCopy(username)
	if err != nil {
		return ErrUserNotFound
	}

	streaks, err := s.streaks.List()
	if err != nil {
		return err
	}

	updated, changed := utils.UpdateAllFriendshipStreaks(currentUser, s.users.ListUser(), streaks)
	if !changed {
		return nil
	}

	return s.streaks.SaveAll(updated)
}

func (s *UserService) FriendshipStreaks(username string, meOnly bool) ([]models.FriendshipStreak, error) {
	streaks, err := s.streaks.List()
	if err != nil {
		return nil, err
	}

	if !meOnly {
		return streaks, nil
	}

	filtered := make([]models.FriendshipStreak, 0)
	for _, streak := range streaks {
		if streak.User1 == username || streak.User2 == username {
			filtered = append(filtered, streak)
		}
	}

	return filtered, nil
}

func (s *UserService) DeleteFriend(username, friend string) (FriendMutationResult, error) {
	if friend == username {
		return FriendMutationResult{}, ErrCannotDeleteYourself
	}

	if _, err := s.users.GetByUsername(friend); err != nil {
		return FriendMutationResult{}, ErrFriendNotFound
	}

	updated, err := s.users.UpdateUser(username, func(u *models.User) error {
		u.Friends = utils.RemoveFriend(u.Friends, friend)
		return nil
	})
	if err != nil {
		return FriendMutationResult{}, ErrUserNotFound
	}

	_, err = s.users.UpdateUser(friend, func(u *models.User) error {
		u.Friends = utils.RemoveFriend(u.Friends, username)
		return nil
	})
	if err != nil {
		return FriendMutationResult{}, ErrFriendNotFound
	}

	return FriendMutationResult{
		OK:        true,
		FriendsOf: username,
		Friends:   updated.Friends,
		Message:   "friend deleted",
	}, nil
}

func (s *UserService) touchFriendshipStreak(aUser, bUser string) error {
	streaks, err := s.streaks.List()
	if err != nil {
		return err
	}

	for _, streak := range streaks {
		if (streak.User1 == aUser && streak.User2 == bUser) || (streak.User1 == bUser && streak.User2 == aUser) {
			return nil
		}
	}

	streaks = append(streaks, models.FriendshipStreak{
		User1:      aUser,
		User2:      bUser,
		Streak:     0,
		LastActive: time.Now().UTC().Format("2006-01-02"),
	})

	return s.streaks.SaveAll(streaks)
}
