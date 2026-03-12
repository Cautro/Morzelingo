package handlers

import (
	"math/rand"
	"sync"
	// "strings"
	// "fmt"
	"time"
	"os"
	// "golang.org/x/time/rate"
	"encoding/json"
	"path/filepath"

	// "golang.org/x/crypto/bcrypt"
	// "github.com/gin-gonic/gin"
	// "github.com/golang-jwt/jwt/v5"
	"github.com/cautro/morzelingo/internal/models"
	"github.com/cautro/morzelingo/internal/app"
)

var fsMu sync.Mutex 
const friendshipFile = "data/friendship_streaks.json"

func removeFriend(slice []string, name string) []string {
    for i, v := range slice {
        if v == name {
            return append(slice[:i], slice[i+1:]...)
        }
    }
    return slice
}

func readFriendshipStreaks() ([]models.FriendshipStreak, error) {
	fsMu.Lock()
	defer fsMu.Unlock()

	if _, err := os.Stat(friendshipFile); os.IsNotExist(err) {
		return []models.FriendshipStreak{}, nil
	}
	b, err := os.ReadFile(friendshipFile)
	if err != nil {
		return nil, err
	}
	var s []models.FriendshipStreak
	if err := json.Unmarshal(b, &s); err != nil {
		return nil, err
	}
	return s, nil
}

func saveFriendshipStreaks(streaks []models.FriendshipStreak) error {
	fsMu.Lock()
	defer fsMu.Unlock()

	dir := filepath.Dir(friendshipFile)
	if err := os.MkdirAll(dir, 0o755); err != nil {
		return err
	}
	b, err := json.MarshalIndent(streaks, "", "  ")
	if err != nil {
		return err
	}
	return os.WriteFile(friendshipFile, b, 0o644)
}

func touchFriendshipStreak(aUser, bUser string) error {
	streaks, err := readFriendshipStreaks()
	if err != nil {
		return err
	}
	for _, s := range streaks {
		if (s.User1 == aUser && s.User2 == bUser) || (s.User1 == bUser && s.User2 == aUser) {
			return nil 
		}
	}
	// create
	today := time.Now().UTC().Format("2006-01-02")
	streaks = append(streaks, models.FriendshipStreak{
		User1:      aUser,
		User2:      bUser,
		Streak:     0,
		LastActive: today,
	})
	return saveFriendshipStreaks(streaks)
}

func updateAllFriendshipStreaks(a *app.App, username string) error {
	// get user copy
	u, err := a.GetUserCopy(username)
	if err != nil {
		return err
	}
	if len(u.Friends) == 0 {
		return nil
	}
	users := a.GetUsers()

	// load streaks
	streaks, err := readFriendshipStreaks()
	if err != nil {
		return err
	}
	today := time.Now().UTC().Format("2006-01-02")
	changed := false

	for _, friend := range u.Friends {
		var friendUser *models.User
		for i := range users {
			if users[i].Username == friend {
				friendUser = &users[i]
				break
			}
		}
		if friendUser == nil {
			continue
		}
		if friendUser.LastLogin == today {
			updated := false
			for i := range streaks {
				if (streaks[i].User1 == username && streaks[i].User2 == friend) ||
					(streaks[i].User1 == friend && streaks[i].User2 == username) {

					if streaks[i].LastActive == today {
						updated = true
						break
					}

					yesterday := time.Now().UTC().AddDate(0, 0, -1).Format("2006-01-02")
					if streaks[i].LastActive == yesterday {
						streaks[i].Streak++
					} else {
						streaks[i].Streak = 1
					}
					streaks[i].LastActive = today
					updated = true
					changed = true
					break
				}
			}
			if !updated {
				streaks = append(streaks, models.FriendshipStreak{
					User1:      username,
					User2:      friend,
					Streak:     1,
					LastActive: today,
				})
				changed = true
			}
		}
	}

	if changed {
		if err := saveFriendshipStreaks(streaks); err != nil {
			return err
		}
	}
	return nil
}

func generateReferralCode(users []models.User) string {
	const charset = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
	for {

		b := make([]byte, 6)
		for i := range b {
			b[i] = charset[rand.Intn(len(charset))]
		}

		code := string(b)

		exists := false

		for _, u := range users {
			if u.ReferralCode == code {
				exists = true
				break
			}
		}

		if !exists {
			return code
		}
	}
}

