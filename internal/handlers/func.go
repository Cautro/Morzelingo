package handlers

import (
	"math/rand"
	"sync"
	"strings"
	"fmt"
	"time"
	"os"
	"golang.org/x/time/rate"
	"encoding/json"

	// "golang.org/x/crypto/bcrypt"
	"github.com/gin-gonic/gin"
	"github.com/golang-jwt/jwt/v5"
	"github.com/cautro/morzelingo/internal/models"
)

var supersecretkey string
var usersMutex sync.Mutex
var userIndex map[string]int
var loginLimiters = make(map[string]*rate.Limiter)

type ShopItem struct {
	ID    int
	Name  string
	Price int
}

type FriendshipStreak struct {
    User1          string `json:"user1"`
    User2          string `json:"user2"`
    Streak         int   `json:"streak"`
    LastActive     string `json:"last_active"` 
}

type Achievement struct {
    ID int
    Name string
    Description string
    Reward int
}

type SymbolStat struct {
	Symbol  string `json:"symbol"`
	Correct int    `json:"correct"`
	Wrong   int    `json:"wrong"`
}


var englishMorseDictionary = map[string]string{
	"A": "•—",
	"B": "—•••",
	"C": "—•—•",
	"D": "—••",
	"E": "•",
	"F": "••—•",
	"G": "——•",
	"H": "••••",
	"I": "••",
	"J": "•———",
	"K": "—•—",
	"L": "•—••",
	"M": "——",
	"N": "—•",
	"O": "———",
	"P": "•——•",
	"Q": "——•—",
	"R": "•—•",
	"S": "•••",
	"T": "—",
	"U": "••—",
	"V": "•••—",
	"W": "•——",
	"X": "—••—",
	"Y": "—•——",
	"Z": "——••",
}

var russianMorseDictionary = map[string]string{
	"А": "•—",
	"Б": "—•••",
	"В": "•——",
	"Г": "——•",
	"Д": "—••",
	"Е": "•",
	"Ж": "•••—",
	"З": "——••",
	"И": "••",
	"Й": "•———",
	"К": "—•—",
	"Л": "•—••",
	"М": "——",
	"Н": "—•",
	"О": "———",
	"П": "•——•",
	"Р": "•—•",
	"С": "•••",
	"Т": "—",
	"У": "••—",
	"Ф": "••—•",
	"Х": "••••",
	"Ц": "—•—•",
	"Ч": "———•",
	"Ш": "————",
	"Щ": "——•—",
	"Ъ": "——•——",
	"Ы": "—•——",
	"Ь": "—••—",
	"Э": "••—••",
	"Ю": "••——",
	"Я": "•—•—",
	"0": "—————",
	"1": "•————",
	"2": "••———",
	"3": "•••——",
	"4": "••••—",
	"5": "•••••",
	"6": "—••••",
	"7": "——•••",
	"8": "———••",
	"9": "————•",
}

var defaultLessons = []Lesson{
	{ID: 1, Title: "Буквы A и B", Theory: "A = .- , B = -...", Symbols: []string{"A","B"}, XPReward: 50},
	{ID: 2, Title: "Добавляем C", Theory: "C = -.-.", Symbols: []string{"A","B","C"}, XPReward: 50},
}

func removeFriend(slice []string, name string) []string {
    for i, v := range slice {
        if v == name {
            return append(slice[:i], slice[i+1:]...)
        }
    }
    return slice
}

func buildUserIndex(users []models.User) {
	userIndex = make(map[string]int)

	for i, u := range users {
		userIndex[u.Username] = i
	}
}

func safeSaveUsers(users []models.User) error {
	usersMutex.Lock()
	defer usersMutex.Unlock()

	return saveUsers(users)
}

func checkAchievements(user []models.User, lang string) ([]Achievement, error) {
	achievements, err := readAchi()
	if err != nil {
		return nil, err
	}

	var LessonDone int
	if lang == "ru" {
		LessonDone = user.LessonDone_RU
	} else if lang == "en" {
		LessonDone = user.LessonDone_EN
	}

	var unlockedNow []Achievement
	for _, ach := range achievements {
		if contains(user.UnlockedAchievements, ach.Name) {
			continue
		}

		unlock := false

		switch ach.ID {

		case 1:
			if LessonDone >= 1 {
				unlock = true
			}

		case 2:
			if LessonDone >= 5 {
				unlock = true
			}

		case 3:
			if user.XP >= 100 {
				unlock = true
			}

		case 4:
			if user.Level >= 5 {
				unlock = true
			}

		case 5:
			if user.Streak >= 7 {
				unlock = true
			}
		}

		if unlock {
			user.UnlockedAchievements = append(user.UnlockedAchievements, ach.Name)
			user.Coins += ach.Reward
			unlockedNow = append(unlockedNow, ach)
		}
	}

	return unlockedNow, nil
}

func contains(slice []string, item string) bool {
	for _, v := range slice {
		if v == item {
			return true
		}
	}
	return false
}

func generateRandomWord(symbols []string, length int) string {
	var result string
	for i := 0; i < length; i++ {
		randomIndex := rand.Intn(len(symbols))
		result += symbols[randomIndex]
	}
	return result
}

func textToMorse(text string, lang string) string {
	fmt.Println("text:", text)
	var result []string

	if lang == "ru" {
		morseDictionary := russianMorseDictionary
		for _, char := range text {
			upper := strings.ToUpper(string(char))
			if morse, ok := morseDictionary[upper]; ok {
				result = append(result, morse)
			}
		}
		return strings.Join(result, " ")

	} else if lang == "en" {
		morseDictionary := englishMorseDictionary
		for _, char := range text {
			upper := strings.ToUpper(string(char))
			if morse, ok := morseDictionary[upper]; ok {
				result = append(result, morse)
			}
		}

		return strings.Join(result, " ")
	}
	return strings.Join(result, " ")
}

func generateToken(username string) (string, error) {

	claims := Claims{
		Username: username,
		RegisteredClaims: jwt.RegisteredClaims{
			ExpiresAt: jwt.NewNumericDate(time.Now().Add(time.Hour * 24)),
			IssuedAt:  jwt.NewNumericDate(time.Now()),
		},
	}

	token := jwt.NewWithClaims(jwt.SigningMethodHS256, claims)

	return token.SignedString([]byte(supersecretkey))
}

func authMiddleware() gin.HandlerFunc {
	return func(c *gin.Context) {

		authHeader := c.GetHeader("Authorization")
		if authHeader == "" {
			c.JSON(401, gin.H{"error": "Authorization header missing"})
			c.Abort()
			return
		}

		parts := strings.Split(authHeader, " ")
		if len(parts) != 2 || parts[0] != "Bearer" {
			c.JSON(401, gin.H{"error": "Invalid authorization format"})
			c.Abort()
			return
		}

		tokenString := parts[1]

		claims := &Claims{}

		token, err := jwt.ParseWithClaims(tokenString, claims, func(token *jwt.Token) (interface{}, error) {

			if _, ok := token.Method.(*jwt.SigningMethodHMAC); !ok {
				return nil, fmt.Errorf("unexpected signing method")
			}

			return []byte(supersecretkey), nil
		})

		if err != nil || !token.Valid {
			c.JSON(401, gin.H{"error": "Invalid or expired token"})
			c.Abort()
			return
		}

		c.Set("username", claims.Username)
		c.Next()
	}
}

func readUsers() ([]models.User, error) {
	file, err := os.ReadFile("users.json")
	if err != nil {
		return nil, err
	}

	var users []models.User
	err = json.Unmarshal(file, &users)
	return users, err
}

func readAchi() ([]Achievement, error) {
	file, err := os.ReadFile("achievements.json")
	if err != nil {
		return nil, err
	}

	var achievements []Achievement
	err = json.Unmarshal(file, &achievements)
	return achievements, err
}

func readShop() ([]ShopItem, error) {
	file, err := os.ReadFile("shop.json")
	if err != nil {
		return nil, err
	}

	var shop []ShopItem
	err = json.Unmarshal(file, &shop)
	return shop, err
}

func saveLessons(lessons []Lesson) error {
	data, err := json.MarshalIndent(lessons, "", "  ")
	if err != nil {
		return err
	}
	return os.WriteFile("lessons.json", data, 0644)
}

func saveUsers(users []models.User) error {
	data, err := json.MarshalIndent(users, "", "  ")
	if err != nil {
		return err
	}

	return os.WriteFile("users.json", data, 0644)
}

func addUser(newUser []models.User) error {
	users, err := readUsers()
	if err != nil {
		return err
	}

	users = append(users, newUser)

	return safeSaveUsers(users)
}

func getLimiter(ip string) *rate.Limiter {
	limiter, exists := loginLimiters[ip]
	if !exists {
		limiter = rate.NewLimiter(1, 5)
		loginLimiters[ip] = limiter
	}
	return limiter
}

func generatePractice(symbols []string, length int) string {
	var result string

	for i := 0; i < length; i++ {
		randomIndex := rand.Intn(len(symbols))
		result += symbols[randomIndex]
	}

	return result
}

func getHardSymbols(stats []SymbolStat) []string {
    var hard []string
    for _, s := range stats {
        if s.Wrong >= 2 {
            hard = append(hard, s.Symbol)
        }
    }
    return hard
}

func registerWrong(user []models.User, symbol string) {
	for i := range user.SymbolStats {
		if user.SymbolStats[i].Symbol == symbol {
			user.SymbolStats[i].Wrong++
			return
		}
	}

	user.SymbolStats = append(user.SymbolStats, SymbolStat{
		Symbol: symbol,
		Wrong:  1,
	})
}

func weightedRandom(symbols []string, stats []SymbolStat) string {

	weights := make(map[string]int)
	totalWeight := 0

	for _, symbol := range symbols {

		weight := 10

		for _, stat := range stats {
			if stat.Symbol == symbol {

				weight = 10 + stat.Wrong*5 - stat.Correct*3

			}
		}

		if weight < 1 {
			weight = 1
		}

		if weight > 5 {
			weight = 5
		}

		weights[symbol] = weight
		totalWeight += weight
	}

	r := rand.Intn(totalWeight)

	current := 0

	for symbol, weight := range weights {

		current += weight

		if r < current {
			return symbol
		}
	}

	return symbols[rand.Intn(len(symbols))]
}

func updateStreak(user []models.User) {
	user.LastStreak = user.Streak
	today := time.Now().UTC().Format("2006-01-02")

	if user.LastLogin == today {
		return
	}

	yesterday := time.Now().UTC().AddDate(0, 0, -1).Format("2006-01-02")

	if user.LastLogin == yesterday {
		user.Streak++
	} else {
		user.Streak = 1
	}

	user.LastLogin = today
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

func updateFriendshipStreak(user1, user2 string) error {
	streaks, err := readFriendshipStreaks()
	if err != nil {
		return err
	}

	today := time.Now().UTC().Format("2006-01-02")
	var found *int
	for i, s := range streaks {
		if (s.User1 == user1 && s.User2 == user2) || (s.User1 == user2 && s.User2 == user1) {
			found = &i
			break
		}
	}

	if found != nil {
		// уже есть запись
		s := &streaks[*found]
		if s.LastActive == today {
			// уже обновляли сегодня
			return nil
		}
		yesterday := time.Now().UTC().AddDate(0, 0, -1).Format("2006-01-02")
		if s.LastActive == yesterday {
			s.Streak++
		} else {
			s.Streak = 1
		}
		s.LastActive = today
	} else {
		// новая пара
		streaks = append(streaks, FriendshipStreak{
			User1:      user1,
			User2:      user2,
			Streak:     1,
			LastActive: today,
		})
	}

	return saveFriendshipStreaks(streaks)
}

func readFriendshipStreaks() ([]FriendshipStreak, error) {
	file, err := os.ReadFile("friendship_streaks.json")
	if err != nil {
		if os.IsNotExist(err) {
			return []FriendshipStreak{}, nil
		}
		return nil, err
	}
	var streaks []FriendshipStreak
	err = json.Unmarshal(file, &streaks)
	return streaks, err
}

func saveFriendshipStreaks(streaks []FriendshipStreak) error {
	data, err := json.MarshalIndent(streaks, "", "  ")
	if err != nil {
		return err
	}
	return os.WriteFile("friendship_streaks.json", data, 0644)
}

func updateAllFriendshipStreaks(username string) error {
	users, err := readUsers()
	if err != nil {
		return err
	}
	var currentUser []models.User
	for i := range users {
		if users[i].Username == username {
			currentUser = &users[i]
			break
		}
	}
	if currentUser == nil {
		return fmt.Errorf("user not found")
	}
	if len(currentUser.Friends) == 0 {
		return nil 
	}

	today := time.Now().UTC().Format("2006-01-02")
	for _, friend := range currentUser.Friends {
		var friendUser []models.User
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
			if err := updateFriendshipStreak(username, friend); err != nil {
				return err
			}
		}
	}
	return nil
}

func addToFriends(username string) error {

	users, err := readUsers()
	if err != nil {
		return err
	}

	var currentUser []models.User
	var inviter []models.User

	for i := range users {
		if users[i].Username == username {
			currentUser = &users[i]
			break
		}
	}

	if currentUser == nil {
		return fmt.Errorf("user not found")
	}

	if currentUser.ReferredBy == "" {
		return nil
	}

	for i := range users {
		if users[i].Username == currentUser.ReferredBy {
			inviter = &users[i]
			break
		}
	}

	if inviter == nil {
		return fmt.Errorf("inviter not found")
	}

	inviter.Friends = append(inviter.Friends, currentUser.Username)
	currentUser.Friends = append(currentUser.Friends, inviter.Username)

	err = safeSaveUsers(users)
	if err != nil {
		return err
	}

	return nil
}

func checkAndUpdateParameters(username string) error {
	users, err := readUsers()
	if err != nil {
		return err
	}
	updated := false
	for i := range users {
		if users[i].Username == username {
			if users[i].LessonDone_EN == 0 {
				users[i].LessonDone_EN = users[i].lastLessonDone
				users[i].lastLessonDone = 0
				updated = true
			}
		}
	}

	if updated {
		err := safeSaveUsers(users)
		if err != nil {
			return err
		}
	}

	return nil
}