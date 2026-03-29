package utils

import (
	"sync"
	"os"
	"path/filepath"
	"encoding/json"
	"github.com/cautro/morzelingo/internal/app"
	"github.com/cautro/morzelingo/internal/models"
	"time"
	"math/rand"
	"strings"
	"github.com/gin-gonic/gin"
	"github.com/golang-jwt/jwt/v5"
	"net/http"
	"fmt"
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
	u, err := a.GetUserCopy(username)
	if err != nil {
		return err
	}
	if len(u.Friends) == 0 {
		return nil
	}

	users := a.ListUser()

	streaks, err := readFriendshipStreaks()
	if err != nil {
		return err
	}

	today := time.Now().UTC().Format("2006-01-02")
	changed := false

	for _, friend := range u.Friends {
		var friendUser *models.User

		for _, friend := range u.Friends {
			for i := range users {
				if users[i].Username == friend {
					foundFriend = users[i]
					isFound = true
					break
				}
			}

			if !isFound {
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

func readLessons(lang string) ([]models.Lesson, error) {
	filename := "data/lessons-EN.json"
	if lang == "ru" {
		filename = "data/lessons-RU.json"
	}

	b, err := osReadFile(filename)
	if err != nil {
		return nil, err
	}

	var lessons []models.Lesson
	if err := json.Unmarshal(b, &lessons); err != nil {
		return nil, err
	}

	return lessons, nil
}

func osReadFile(path string) ([]byte, error) {
	return os.ReadFile(path)
}

func textToMorse(text string, lang string) string {
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

func getHardSymbols(stats []models.SymbolStat) []string {
	hard := make([]string, 0)
	for _, s := range stats {
		if s.Wrong >= 2 {
			hard = append(hard, s.Symbol)
		}
	}
	return hard
}

func weightedRandom(symbols []string, stats []models.SymbolStat) string {
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