package utils

import (
	"math/rand"
	"time"
	
	"github.com/cautro/morzelingo/internal/models"
)

func RemoveFriend(slice []string, name string) []string {
	for i, v := range slice {
		if v == name {
			return append(slice[:i], slice[i+1:]...)
		}
	}
	return slice
}

func UpdateAllFriendshipStreaks(currentUser models.User, allUsers []models.User, streaks []models.FriendshipStreak) ([]models.FriendshipStreak, bool) {
	if len(currentUser.Friends) == 0 {
		return nil, false
	}

	today := time.Now().UTC().Format("2006-01-02")
	changed := false

	for _, friendName := range currentUser.Friends {
		var foundFriend models.User
		var isFound bool

		for i := range allUsers {
			if allUsers[i].Username == friendName {
				foundFriend = allUsers[i]
				isFound = true
				break
			}
		}

		if !isFound {
			continue
		}

		if foundFriend.LastLogin == today {
			updated := false
			for i := range streaks {
				if (streaks[i].User1 == currentUser.Username && streaks[i].User2 == friendName) ||
					(streaks[i].User1 == friendName && streaks[i].User2 == currentUser.Username) {

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
					User1:      currentUser.Username,
					User2:      friendName,
					Streak:     1,
					LastActive: today,
				})
				changed = true
			}
		}
	}

	return streaks, changed
}

func GenerateReferralCode(users []models.User) string {
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