package main

import (
	"encoding/json"
	"fmt"
	"math/rand"
	"os"
	"strings"
	"sync"
	"time"

	"github.com/gin-gonic/gin"
	"github.com/golang-jwt/jwt/v5"
	"github.com/joho/godotenv"
	"golang.org/x/crypto/bcrypt"
	"golang.org/x/time/rate"
)

var supersecretkey string
var loginLimiters = make(map[string]*rate.Limiter)

var morseDictionary = map[string]string{
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


var defaultLessons = []Lesson{
	{ID: 1, Title: "Буквы A и B", Theory: "A = .- , B = -...", Symbols: []string{"A","B"}, XPReward: 50},
	{ID: 2, Title: "Добавляем C", Theory: "C = -.-.", Symbols: []string{"A","B","C"}, XPReward: 50},
}

type SymbolUpdate struct {
    Symbol  string `json:"symbol" binding:"required"`
    Correct int    `json:"correct"`
    Wrong   int    `json:"wrong"`
}

type AnswerCheck struct {
	Correct bool `json:"correct"`
}

type PracticeQuestion struct {
	Type     string   `json:"type"`
	Question string `json:"question"`
	Answer   string   `json:"answer"`
}

type LettersQuestion struct {
	Type     string   `json:"type"`
	Question string `json:"question"`
}

type PracticeResponse struct {
	Questions []PracticeQuestion `json:"questions"`
}

type LettersResponse struct {
	Questions []LettersQuestion `json:"questions"`
}


type User struct {
	Username             string `json:"username"`
	Email                string `json:"email"`
	Password             string `json:"password"`
	XP                   int    `json:"xp"`
	LessonDone           int    `json:"lesson_done"`
	Level                int    `json:"level"`
	Coins                int    `json:"coins"`
	Items                []int  `json:"items"`
	NeedXp               int    `json:"need_xp"`
	Streak               int `json:"streak"`
	LastStreak           int `json:"last_streak"`
	AnswerStreak         int `json:"answer_streak"`
	LastLogin            string `json:"last_login"`
	UnlockedAchievements []string `json:"UnlockedAchievements"`
	SymbolStats          []SymbolStat `json:"symbol_stats"`
	ReferralCode         string `json:"referral_code"`
	ReferredBy           string `json:"referred_by"`
	ReferralCount        int `json:"referred_count"`
	Friends 			 []string `json:"friends"`
}

type FriendshipStreak struct {
    User1          string `json:"user1"`
    User2          string `json:"user2"`
    Streak         int   `json:"streak"`
    LastActive     string `json:"last_active"` 
}

type LoginInput struct {
	Username string `json:"username" binding:"required"`
	Password string `json:"password" binding:"required"`
}

type RegisterInput struct {
    Username string `json:"username"`
    Email string `json:"email"`
    Password string `json:"password"`
    ReferralInput string `json:"referral_code"`
}

type Claims struct {
	Username string `json:"username"`
	jwt.RegisteredClaims
}

type Lesson struct {
	ID          int
	Title       string
	Theory      string
	Symbols     []string
	XPReward    int
	Practice string
}

type ShopItem struct {
	ID    int
	Name  string
	Price int
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

var usersMutex sync.Mutex
var userIndex map[string]int

func buildUserIndex(users []User) {
	userIndex = make(map[string]int)

	for i, u := range users {
		userIndex[u.Username] = i
	}
}

func safeSaveUsers(users []User) error {
	usersMutex.Lock()
	defer usersMutex.Unlock()

	return saveUsers(users)
}

func checkAchievements(user *User) ([]Achievement, error) {

	achievements, err := readAchi()
	if err != nil {
		return nil, err
	}

	var unlockedNow []Achievement

	for _, ach := range achievements {
		if contains(user.UnlockedAchievements, ach.Name) {
			continue
		}

		unlock := false

		switch ach.ID {

		case 1:
			if user.LessonDone >= 1 {
				unlock = true
			}

		case 2:
			if user.LessonDone >= 5 {
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

func textToMorse(text string) string {
	var result []string

	for _, char := range text {
		upper := strings.ToUpper(string(char))
		if morse, ok := morseDictionary[upper]; ok {
			result = append(result, morse)
		}
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

func readUsers() ([]User, error) {
	file, err := os.ReadFile("users.json")
	if err != nil {
		return nil, err
	}

	var users []User
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

func readLessons() ([]Lesson, error) {
	if _, err := os.Stat("lessons.json"); err != nil {
		return defaultLessons, nil
	}
	file, err := os.ReadFile("lessons.json")
	if err != nil {
		return nil, err
	}
	var lessons []Lesson
	err = json.Unmarshal(file, &lessons)
	return lessons, err
}

func saveLessons(lessons []Lesson) error {
	data, err := json.MarshalIndent(lessons, "", "  ")
	if err != nil {
		return err
	}
	return os.WriteFile("lessons.json", data, 0644)
}

func saveUsers(users []User) error {
	data, err := json.MarshalIndent(users, "", "  ")
	if err != nil {
		return err
	}

	return os.WriteFile("users.json", data, 0644)
}

func addUser(newUser User) error {
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

func registerWrong(user *User, symbol string) {
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

func updateStreak(user *User) {
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

func generateReferralCode(users []User) string {
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
	var currentUser *User
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
		return nil // не с кем обновлять
	}

	// Для каждого друга проверяем, был ли он сегодня активен
	today := time.Now().UTC().Format("2006-01-02")
	for _, friend := range currentUser.Friends {
		var friendUser *User
		for i := range users {
			if users[i].Username == friend {
				friendUser = &users[i]
				break
			}
		}
		if friendUser == nil {
			continue
		}
		// Если друг тоже сегодня заходил (LastLogin == today)
		if friendUser.LastLogin == today {
			// обновляем совместный стрик
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

	var currentUser *User
	var inviter *User

	// находим текущего пользователя
	for i := range users {
		if users[i].Username == username {
			currentUser = &users[i]
			break
		}
	}

	if currentUser == nil {
		return fmt.Errorf("user not found")
	}

	// если нет реферала — выходим
	if currentUser.ReferredBy == "" {
		return nil
	}

	// ищем пригласившего по коду
	for i := range users {
		if users[i].Username == currentUser.ReferredBy {
			inviter = &users[i]
			break
		}
	}

	if inviter == nil {
		return fmt.Errorf("inviter not found")
	}

	// добавляем текущего пользователя в друзья пригласившего
	inviter.Friends = append(inviter.Friends, currentUser.Username)

	// добавляем пригласившего в друзья текущего пользователя
	currentUser.Friends = append(currentUser.Friends, inviter.Username)

	// сохраняем
	err = safeSaveUsers(users)
	if err != nil {
		return err
	}

	return nil
}

func main() {
	rand.Seed(time.Now().UnixNano())
	godotenv.Load()
	supersecretkey = os.Getenv("JWT_SECRET")
	if supersecretkey == "" {
		panic("JWT_SECRET not set")
	}	

	res := gin.Default()

	res.POST("/api/register", func(c *gin.Context) {
		var input RegisterInput

		if err := c.ShouldBindJSON(&input); err != nil {
			return
		}

		user := User{
			Username: input.Username,
			Email: input.Email,
			Password: input.Password,
		}

		users, err := readUsers()
		if err != nil {
			c.JSON(500, gin.H{"error": "Failed to read users", "details": err.Error(), "message": "Проблема открытия файла users.json. Убедитесь, что файл существует и имеет правильный формат."})
			return
		}

		if input.ReferralInput != "" {

		var inviter *User

		for i := range users {
			if users[i].ReferralCode == input.ReferralInput {
				inviter = &users[i]
				break
			}
		}

		if inviter == nil {
			c.JSON(400, gin.H{"error": "Invalid referral code"})
			return
		}

		user.ReferredBy = inviter.Username
		inviter.ReferralCount++
		inviter.Coins += 50
		user.Coins += 25
	}

	user.ReferralCode = generateReferralCode(users)
	
		// Проверка на существование
		for _, u := range users {
			if u.Username == user.Username {
				c.JSON(400, gin.H{"error": "User exists", "message": "Пользователь с таким именем уже существует. Пожалуйста, выберите другое имя."})
				return
			}
		}

		for _, u := range users {
			if u.Email == user.Email {
				c.JSON(400, gin.H{"error": "Email already exists", "message": "Электронная почта уже используется. Пожалуйста, выберите другую."})
				return
			}
		}

		hashedPassword, _ := bcrypt.GenerateFromPassword([]byte(user.Password), bcrypt.DefaultCost)
		user.Password = string(hashedPassword)
		users = append(users, user)

		if err := safeSaveUsers(users); err != nil {
			c.JSON(500, gin.H{"error": "Failed to save users", "details": err.Error(), "message": "Проблема сохранения файла users.json. Убедитесь, что файл доступен для записи."})
			return
		}

		addToFriends(user.Username)

		c.JSON(200, gin.H{"message": "User saved"})
	})

	res.POST("/api/login", func(c *gin.Context) {
		ip := c.ClientIP()
		limiter := getLimiter(ip)

		if !limiter.Allow() {
			c.JSON(429, gin.H{
				"error": "Too many login attempts. Try again later.",
				"message": "Слишком много попыток входа. Попробуйте позже.",
			})
			return
		}

		var input LoginInput

		if err := c.ShouldBindJSON(&input); err != nil {
			c.JSON(400, gin.H{
				"error": err.Error(),
			})
			return
		}

		users, err := readUsers()
		if err != nil {
			c.JSON(500, gin.H{
				"message": "Проблема открытия файла users.json. Убедитесь, что файл существует и имеет правильный формат.",
				"error": "Failed to read users",
			})
			return
		}

		var foundUser *User
		for i := range users {
			if users[i].Username == input.Username {
				foundUser = &users[i]
				break
			}
		}

		if foundUser == nil {
			c.JSON(401, gin.H{
				"message": "Неверные имя пользователя или пароль. Убедитесь, что вы вводите правильные данные.",
				"error": "Invalid username or password",
			})
			return
		}

		if err := bcrypt.CompareHashAndPassword(
			[]byte(foundUser.Password),
			[]byte(input.Password),
		); err != nil {

			c.JSON(401, gin.H{
				"error": "Invalid username or password",
			})
			return
		}

		updateStreak(foundUser)
		updateAllFriendshipStreaks(foundUser.Username)
		if foundUser.ReferralCode == "" {
			foundUser.ReferralCode = generateReferralCode(users)
		}

		safeSaveUsers(users)

		token, err := generateToken(foundUser.Username)
		if err != nil {
			c.JSON(500, gin.H{
				"message": "Успешный вход, но не удалось создать токен. Попробуйте снова.",
				"error": "Could not generate token",
			})
			return
		}

		c.JSON(200, gin.H{
			"message": "Успешный вход.",
			"token":   token,
		})
	})

	res.GET("/api/profile", authMiddleware(), func(c *gin.Context) {

		username, exists := c.Get("username")
		if !exists {
			c.JSON(500, gin.H{"error": "username not found in context", "message": "Внутренняя ошибка сервера. Попробуйте снова."})
			return
		}

		users, err := readUsers()
		if err != nil {
			c.JSON(500, gin.H{"error": "Failed to read users", "details": err.Error(), "message": "Проблема открытия файла users.json. Убедитесь, что файл существует и имеет правильный формат."})
			return
		}

		streaks, err := readFriendshipStreaks()
		if err != nil {
			c.JSON(500, gin.H{"error": "failed"})
			return
		}

		var result FriendshipStreak

		fmt.Println("result", result)
		fmt.Println("streaks", streaks)

		for _, s := range streaks {
			if s.User1 == username || s.User2 == username {
				result = s
			}
		}

		fmt.Println("result", result)

		for _, u := range users {
			if u.Username == username {
				c.JSON(200, gin.H{
					"username":             u.Username,
					"email":                u.Email,
					"xp":                   u.XP,
					"lesson_done":          u.LessonDone,
					"level":                u.Level,
					"coins":                u.Coins,
					"items":                u.Items,
					"message":              "Профиль успешно загружен.",
					"streak":               u.Streak,
					"refferal_code":        u.ReferralCode,
					"reffered_by":          u.ReferredBy,
					"referred_count":       u.ReferralCount,
					"friends":              u.Friends,
					"symbol_stats":         u.SymbolStats,
					"need_xp":              u.NeedXp,
					"UnlockedAchievements": u.UnlockedAchievements,
					"TogetherStreak":       result.Streak,
					"User1":                result.User1,
					"User2":                result.User2,
				})
				return
			}
		}

		c.JSON(404, gin.H{"error": "user not found", "message": "Пользователь не найден. Убедитесь, что вы используете правильный токен и что пользователь существует."})
	})

	res.POST("/api/complete-lesson", authMiddleware(), func(c *gin.Context) {

		username := c.GetString("username")

		var input struct {
			LessonID int `json:"lesson_id" binding:"required"`
		}

		if err := c.ShouldBindJSON(&input); err != nil {
			c.JSON(400, gin.H{"error": "Invalid input", "details": err.Error(), "message": "Неверные данные. Убедитесь, что вы отправляете правильный JSON с полем lesson_id."})
			return
		}

		users, err := readUsers()
		if err != nil {
			c.JSON(500, gin.H{"error": "Failed to read users", "details": err.Error(), "message": "Проблема открытия файла users.json. Убедитесь, что файл существует и имеет правильный формат."})
			return
		}

		Lessons, err := readLessons()
		if err != nil {
			c.JSON(500, gin.H{"error": "Failed to read lessons", "details": err.Error(), "message": "Проблема открытия файла lessons.json. Убедитесь, что файл существует и имеет правильный формат."})
			return
		}

		for i, u := range users {
			if u.Username == username {
				if input.LessonID != u.LessonDone+1 {
					c.JSON(400, gin.H{"error": "Invalid lesson order", "message": "Неверный порядок уроков. Убедитесь, что вы завершаете уроки в правильной последовательности."})
					return
				}

				newAchievements, err := checkAchievements(&users[i])
				if err != nil {
					c.JSON(500, gin.H{"error": "Failed to check achievements"})
					return
				}

				users[i].LessonDone++
				users[i].XP += Lessons[input.LessonID-1].XPReward 
				
				needXpForNewLevel := 1 + float64(users[i].Level)*1.5
				users[i].NeedXp = int(needXpForNewLevel * 100)
				updateStreak(&users[i])

				if users[i].XP >= 100*int(needXpForNewLevel) {
					users[i].Level++
					users[i].XP = users[i].XP - 100*int(needXpForNewLevel)
				}

				var myltiplier = 1 + int(users[i].Level)*2

				if myltiplier > 100 {
					myltiplier = 100
				}

				users[i].Coins += 10 * myltiplier

				users[i].Streak++
				users[i].LastLogin = time.Now().Format("2006-01-02")

				if err := safeSaveUsers(users); err != nil {
					c.JSON(500, gin.H{"error": "Failed to save users", "details": err.Error(), "message": "Проблема сохранения файла users.json. Убедитесь, что файл доступен для записи."})
					return
				}

				if err := updateAllFriendshipStreaks(username); err != nil {
					// логируем ошибку, но не прерываем ответ
					fmt.Println("Error updating friendship streaks:", err)
				}

				c.JSON(200, gin.H{
					"message": "Lesson completed",
					"xp":      users[i].XP,
					"level":   users[i].Level,
					"coins":   users[i].Coins,
					"need_xp": users[i].NeedXp,
					"new_achievements": newAchievements,
					"streak": users[i].Streak,
				})
				return
			}
		}

		c.JSON(404, gin.H{"error": "User not found", "message": "Пользователь не найден. Убедитесь, что вы используете правильный токен и что пользователь существует."})
	})

	res.GET("/api/lessons", authMiddleware(), func(c *gin.Context) {
		lessons, err := readLessons()
		if err != nil {
			c.JSON(500, gin.H{
				"message": "Проблема открытия файла с уроками. Убедитесь, что файл существует и имеет правильный формат.",
				"error": "Failed to read lessons",
			})
			return
		}
		c.JSON(200, lessons)
	})

	res.GET("/api/lessons/:id", authMiddleware(), func(c *gin.Context) {
		lessons, err := readLessons()
		if err != nil {
			c.JSON(500, gin.H{
				"message": "Проблема открытия файла с уроками. Убедитесь, что файл существует и имеет правильный формат.",
				"error": "Failed to read lessons",
			})
			return
		}
		
		id := c.Param("id")
		for _, lesson := range lessons {
			if fmt.Sprintf("%d", lesson.ID) == id {
				c.JSON(200, lesson)
				return
			}
		}
		c.JSON(404, gin.H{"error": "Lesson not found", "message": "Урок не найден. Пожалуйста, проверьте ID урока."})
	})

	res.GET("/api/practice/:id", authMiddleware(), func(c *gin.Context) {
		username := c.GetString("username")

		lessons, err := readLessons()
		if err != nil {
			c.JSON(500, gin.H{"error": "Failed to read lessons"})
			return
		}

		id := c.Param("id")

		var user *User
		users, err := readUsers()
		if err != nil {
			c.JSON(500, gin.H{"error": "Failed to read users"})
			return
		}
		for i := range users {
			if users[i].Username == username {
				user = &users[i]
				break
			}
		}

		if user == nil {
			c.JSON(404, gin.H{"error": "User not found"})
			return
		}

		var selectedLesson *Lesson

		for i := range lessons {
			if fmt.Sprintf("%d", lessons[i].ID) == id {
				selectedLesson = &lessons[i]
				break
			}
		}

		if selectedLesson == nil {
			c.JSON(404, gin.H{"error": "Lesson not found"})
			return
		}

		hardSymbols := getHardSymbols(user.SymbolStats)
		symbolSet := make(map[string]bool)
		for _, s := range selectedLesson.Symbols {
			symbolSet[s] = true
		}

		added := 0
		for _, s := range hardSymbols {
			if !symbolSet[s] {
				symbolSet[s] = true
				added++
			}
		}

		practiceSymbols := make([]string, 0, len(symbolSet))
		for s := range symbolSet {
			practiceSymbols = append(practiceSymbols, s)
		}


		types := []string{"text", "morse", "audio"}
		
		var questions []PracticeQuestion
		for i := 0; i < 20; i++ {

			randomType := types[rand.Intn(len(types))]

			correctWord := weightedRandom(practiceSymbols, user.SymbolStats)
			fmt.Println("Selected word:", correctWord)
			fmt.Println("User stats:", user.SymbolStats)

			switch randomType {

			case "text":
				questions = append(questions, PracticeQuestion{
					Type:     "text",
					Question: correctWord,
					Answer:   correctWord,
				})

			case "morse":
				correctWordMorse := textToMorse(correctWord)

				questions = append(questions, PracticeQuestion{
					Type:     "morse",
					Question: correctWordMorse,
					Answer:   correctWord,
				})

			case "audio":
				correctWordMorse := textToMorse(correctWord)

				questions = append(questions, PracticeQuestion{
					Type:     "audio",
					Question: correctWordMorse,
					Answer:   correctWord,
				})
			}
		}

		response := PracticeResponse{
			Questions: questions,
		}

		c.JSON(200, response)
	})

	res.POST("/api/practice", authMiddleware(), func(c *gin.Context) {
		letters := c.Query("letters")

		types := []string{"text", "morse", "audio"}

		var questions []LettersQuestion
		for i := 0; i < 20; i++ {

			randomType := types[rand.Intn(len(types))]
			randomNumberOfSymbols := rand.Intn(3) + 1

			correctWord := generatePractice([]string{letters}, randomNumberOfSymbols)

			switch randomType {

			case "text":
				questions = append(questions, LettersQuestion{
					Type:     "text",
					Question: correctWord,
				})

			case "morse":
				correctWordMorse := textToMorse(correctWord)

				questions = append(questions, LettersQuestion{
					Type:     "morse",
					Question: correctWordMorse,
				})

			case "audio":
				correctWordMorse := textToMorse(correctWord)

				questions = append(questions, LettersQuestion{
					Type:     "audio",
					Question: correctWordMorse,
				})
			}
		}

		response := LettersResponse{
			Questions: questions,
		}
		c.JSON(200, response)
	})

	res.POST("/api/practice/submit", authMiddleware(), func(c *gin.Context) {
		username := c.GetString("username")
		var updates []SymbolUpdate

		if err := c.ShouldBindJSON(&updates); err != nil {
			c.JSON(400, gin.H{"error": "Invalid input"})
			return
		}

		users, err := readUsers()
		if err != nil {
			c.JSON(500, gin.H{"error": "Failed to read users"})
			return
		}

		for i, u := range users {
			if u.Username == username {
				for _, upd := range updates {
					found := false
					for j, stat := range users[i].SymbolStats {
						if stat.Symbol == upd.Symbol {
							users[i].SymbolStats[j].Correct += upd.Correct
							users[i].SymbolStats[j].Wrong += upd.Wrong
							found = true
							break
						}
					}
					if !found {
						users[i].SymbolStats = append(users[i].SymbolStats, SymbolStat{
							Symbol:  upd.Symbol,
							Correct: upd.Correct,
							Wrong:   upd.Wrong,
						})
					}
				}

				if err := safeSaveUsers(users); err != nil {
					c.JSON(500, gin.H{"error": "Failed to save users"})
					return
				}

				if err := updateAllFriendshipStreaks(username); err != nil {
					// логируем ошибку, но не прерываем ответ
					fmt.Println("Error updating friendship streaks:", err)
				}

				c.JSON(200, gin.H{"message": "Statistics updated"})
				return
			}
		}
		c.JSON(404, gin.H{"error": "User not found"})
	})

	res.GET("/api/freemode", authMiddleware(), func(c *gin.Context) {

		username := c.GetString("username")

		users, err := readUsers()
		if err != nil {
			c.JSON(500, gin.H{"error": "Failed to read users", "details": err.Error(), "message": "Проблема открытия файла users.json. Убедитесь, что файл существует и имеет правильный формат."})
			return
		}

		var userLevel int

		for _, u := range users {
			if u.Username == username {
				userLevel = u.Level
				break
			}
		}

		if userLevel == 0 {
			userLevel = 1
		}

		var symbols []string
		symbols = []string{"A","B","C","D","E","F","G","H","I","J","K","L","M","N","O","P","Q","R","S","T","U","V","W","X","Y","Z"}
		var simplesymbols []string
		simplesymbols = []string{"A","B","C", "D", "E", "T", "M", "N"}
		var question string
		var simplewords []string
		var words []string
		simplewords = []string{"BAD", "BED", "CAB", "DAD", "DEED", "BEE", "TEA", "EAT"}
		words = []string{"HELLO", "WORLD", "MORSE", "CODE", "PRACTICE", "LEARN", "GOOGLE", "COMPUTER"}


		switch userLevel {
		case 1:
			question = generatePractice(simplesymbols, 5)
		case 10:
			question = generatePractice(simplewords, 1)
		case 20:
			question = generatePractice(words, 1)
		default:
			question = generatePractice(symbols, 5)
		}

		mode := c.DefaultQuery("mode", "text")

		switch mode {

		case "text":
			c.JSON(200, gin.H{
				"level": userLevel,
				"type": "text",
				"question": question,
				"answer": question,
			})

		case "morse":
			morse := textToMorse(question)
			c.JSON(200, gin.H{
				"level": userLevel,
				"type": "morse",
				"question": morse,
				"answer": question,
			})

		default:
			c.JSON(400, gin.H{
				"error": "Invalid mode",
				"message": "Неверный режим. Пожалуйста, выберите 'text' или 'morse'.",
			})
		}
	})

	res.POST("/api/freemode/complete", authMiddleware(), func(c *gin.Context) {
		username := c.GetString("username")

		users, err := readUsers()
		if err != nil {
			c.JSON(500, gin.H{"error": "Failed to read users", "details": err.Error(), "message": "Проблема открытия файла users.json. Убедитесь, что файл существует и имеет правильный формат."})
			return
		}
		
		for i, u := range users {
			if u.Username == username {

				users[i].Coins += 5

				users[i].XP += 10

				

				needXpForNewLevel := 1 + float64(users[i].Level)*1.5
				users[i].NeedXp = int(needXpForNewLevel * 100)

				if users[i].XP >= 100*int(needXpForNewLevel) {
					users[i].Level++
					users[i].XP = users[i].XP - 100*int(needXpForNewLevel)
				}

				updateStreak(&users[i])


				if err := safeSaveUsers(users); err != nil {
					c.JSON(500, gin.H{"error": "Failed to save users", "details": err.Error(), "message": "Проблема сохранения файла users.json. Убедитесь, что файл доступен для записи."})
					return
				}

				if err := updateAllFriendshipStreaks(username); err != nil {
					// логируем ошибку, но не прерываем ответ
					fmt.Println("Error updating friendship streaks:", err)
				}

				c.JSON(200, gin.H{
					"message": "Correct answer! You've earned 5 coins and 10 XP.",
					"coins":   users[i].Coins,
					"xp":      users[i].XP,
					"level":   users[i].Level,
					"need_xp": users[i].NeedXp,
					"streak":  users[i].Streak,
				})
				return
			}}
		c.JSON(404, gin.H{"error": "User not found", "message": "Пользователь не найден. Убедитесь, что вы используете правильный токен и что пользователь существует."})
	})

	res.GET("/api/shop", authMiddleware(), func(c *gin.Context) {
		shop, err := readShop()
		if err != nil {
			c.JSON(500, gin.H{
				"message": "Проблема открытия файла магазина. Убедитесь, что файл существует и имеет правильный формат.",
				"error": "Failed to read shop",
			})
			return
		}
		c.JSON(200, shop)
	})

	res.POST("/api/shop/buy", authMiddleware(), func(c *gin.Context) {

		username := c.GetString("username")

		var input struct {
			ID int `json:"id" binding:"required"`
		}

		if err := c.ShouldBindJSON(&input); err != nil {
			c.JSON(400, gin.H{"error": "Invalid input"})
			return
		}

		users, err := readUsers()
		if err != nil {
			c.JSON(500, gin.H{"error": "Failed to read users"})
			return
		}

		shop, err := readShop()
		if err != nil {
			c.JSON(500, gin.H{"error": "Failed to read shop"})
			return
		}

		userIndex := -1
		for i, u := range users {
			if u.Username == username {
				userIndex = i
				break
			}
		}

		if userIndex == -1 {
			c.JSON(404, gin.H{"error": "User not found"})
			return
		}

		var selectedItem *ShopItem
		for i := range shop {
			if shop[i].ID == input.ID {
				selectedItem = &shop[i]
				break
			}
		}

		if selectedItem == nil {
			c.JSON(404, gin.H{"error": "Item not found"})
			return
		}

		if users[userIndex].Coins < selectedItem.Price {
			c.JSON(400, gin.H{"error": "Not enough coins"})
			return
		}

		users[userIndex].Coins -= selectedItem.Price
		users[userIndex].Items = append(users[userIndex].Items, selectedItem.ID)

		if err := safeSaveUsers(users); err != nil {
			c.JSON(500, gin.H{"error": "Failed to save users"})
			return
		}

		c.JSON(200, gin.H{
			"message": "Item purchased",
			"item":    selectedItem,
			"coins":   users[userIndex].Coins,
		})


	})

	res.GET("/api/achievements", authMiddleware(), func(c *gin.Context) {
		achievements, err := readAchi()
		if err != nil {
			c.JSON(500, gin.H{
				"message": "Проблема открытия файла достижений. Убедитесь, что файл существует и имеет правильный формат.",
				"error": "Failed to read achievements",
			})
			return
		}
		c.JSON(200, achievements)
	})

	res.POST("/api/checker-practice", authMiddleware(), func(c *gin.Context) {

		var input AnswerCheck

		if err := c.ShouldBindJSON(&input); err != nil {
			c.JSON(400, gin.H{"error": "invalid input"})
			return
		}

		username := c.MustGet("username").(string)

		users, err := readUsers()
		if err != nil {
			c.JSON(500, gin.H{"error": "Failed to read users"})
			return
		}

		for i := range users {

			if users[i].Username == username {

				if input.Correct {
					users[i].AnswerStreak++
				} else {
					users[i].AnswerStreak = 0
				}

				safeSaveUsers(users)

				c.JSON(200, gin.H{
					"answer_streak": users[i].AnswerStreak,
				})

				return
			}
		}

		c.JSON(404, gin.H{"error": "user not found"})
	})

	res.GET("/api/referral", authMiddleware(), func(c *gin.Context) {
		username := c.GetString("username")

		users, err := readUsers()
		if err != nil {
			c.JSON(500, gin.H{"error": "Failed to read users", "details": err.Error(), "message": "Проблема открытия файла users.json. Убедитесь, что файл существует и имеет правильный формат."})
			return
		}

		for i := range users {

		if users[i].Username == username {

			if users[i].ReferralCode == "" {
				users[i].ReferralCode = generateReferralCode(users)
				safeSaveUsers(users)
			}

			c.JSON(200, gin.H{
				"referral_code":  users[i].ReferralCode,
				"referred_by":    users[i].ReferredBy,
				"referral_count": users[i].ReferralCount,
			})
			return
		}
	}		
		c.JSON(404, gin.H{"error": "user not found", "message": "Пользователь не найден. Убедитесь, что вы используете правильный токен и что пользователь существует."})
	})

	res.GET("/api/friends", authMiddleware(), func(c *gin.Context) {
		username := c.GetString("username")

		users, err := readUsers()
		if err != nil {
			c.JSON(500, gin.H{"error": "Failed to read users"})
			return
		}
		streaks, err := readFriendshipStreaks()
		if err != nil {
			c.JSON(500, gin.H{"error": "Failed to read streaks"})
			return
		}

		var currentUser *User
		for _, u := range users {
			if u.Username == username {
				currentUser = &u
				break
			}
		}
		if currentUser == nil {
			c.JSON(404, gin.H{"error": "User not found"})
			return
		}

		type friendInfo struct {
			Username      string `json:"username"`
			Streak        int    `json:"streak"`
			LastActive    string `json:"last_active"`
			IndividualStreak int `json:"individual_streak"`
		}
		friendsList := []friendInfo{}

		for _, friend := range currentUser.Friends {
			// найдём пользователя-друга
			var friendUser *User
			for _, u := range users {
				if u.Username == friend {
					friendUser = &u
					break
				}
			}
			if friendUser == nil {
				continue
			}
			// найдём совместный стрик
			streak := 0
			lastActive := ""
			for _, s := range streaks {
				if (s.User1 == username && s.User2 == friend) || (s.User1 == friend && s.User2 == username) {
					streak = s.Streak
					lastActive = s.LastActive
					break
				}
			}
			friendsList = append(friendsList, friendInfo{
				Username:      friend,
				Streak:        streak,
				LastActive:    lastActive,
				IndividualStreak: friendUser.Streak,
			})
		}

		c.JSON(200, gin.H{"friends": friendsList})
	})

	res.GET("/api/friendship-streaks", authMiddleware(), func(c *gin.Context) {

		username := c.GetString("username")

		streaks, err := readFriendshipStreaks()
		if err != nil {
			c.JSON(500, gin.H{"error": "failed"})
			return
		}

		var result []FriendshipStreak

		for _, s := range streaks {
			if s.User1 == username || s.User2 == username {
				result = append(result, s)
			}
		}

		c.JSON(200, result)
	})

	res.Run(":8080")
}
