package utils

import (
	"fmt"
	"math/rand"
	"net/http"
	"strings"
	"time"

	"github.com/cautro/morzelingo/internal/app"
	"github.com/cautro/morzelingo/internal/models"
	"github.com/gin-gonic/gin"
	"github.com/golang-jwt/jwt/v5"
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

func TextToMorse(text string, lang string) string {
	var dict map[string]string
	if lang == "ru" {
		dict = models.RussianMorseDictionary
	} else {
		dict = models.EnglishMorseDictionary
	}

	out := make([]string, 0, len(text))
	for _, ch := range text {
		upper := strings.ToUpper(string(ch))
		if m, ok := dict[upper]; ok {
			out = append(out, m)
		}
	}

	return strings.Join(out, " ")
}

func GeneratePractice(symbols []string, length int) string {
	if len(symbols) == 0 {
		return ""
	}

	sb := make([]string, length)
	for i := 0; i < length; i++ {
		sb[i] = symbols[rand.Intn(len(symbols))]
	}

	return strings.Join(sb, "")
}

func GetHardSymbols(stats []models.SymbolStat) []string {
	hard := make([]string, 0)
	for _, s := range stats {
		if s.Wrong >= 2 {
			hard = append(hard, s.Symbol)
		}
	}
	return hard
}

func WeightedRandom(symbols []string, stats []models.SymbolStat) string {
	if len(symbols) == 0 {
		return ""
	}

	weights := make([]int, len(symbols))
	total := 0

	for i, sym := range symbols {
		w := 10
		for _, st := range stats {
			if st.Symbol == sym {
				w = 10 + st.Wrong*5 - st.Correct*3
				break
			}
		}
		if w < 1 {
			w = 1
		}
		weights[i] = w
		total += w
	}

	r := rand.Intn(total)
	acc := 0
	for i, w := range weights {
		acc += w
		if r < acc {
			return symbols[i]
		}
	}

	return symbols[rand.Intn(len(symbols))]
}

func AuthMiddleware(a *app.App) gin.HandlerFunc {
	return func(c *gin.Context) {
		auth := c.GetHeader("Authorization")
		if auth == "" {
			c.JSON(http.StatusUnauthorized, gin.H{"error": "Authorization header missing"})
			c.Abort()
			return
		}

		parts := strings.Split(auth, " ")
		if len(parts) != 2 || parts[0] != "Bearer" {
			c.JSON(http.StatusUnauthorized, gin.H{"error": "Invalid Authorization header"})
			c.Abort()
			return
		}

		tokenStr := parts[1]
		claims := &models.Claims{}

		tok, err := jwt.ParseWithClaims(tokenStr, claims, func(t *jwt.Token) (interface{}, error) {
			if _, ok := t.Method.(*jwt.SigningMethodHMAC); !ok {
				return nil, fmt.Errorf("unexpected signing method")
			}
			return []byte(a.Secret), nil
		})
		if err != nil || !tok.Valid {
			c.JSON(http.StatusUnauthorized, gin.H{"error": "invalid or expired token"})
			c.Abort()
			return
		}

		c.Set("username", claims.Username)
		c.Next()
	}
}
