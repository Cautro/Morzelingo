package main

import (
	"encoding/json"
	"fmt"
	"math/rand"
	"os"
	"strings"
	"time"

	"github.com/gin-gonic/gin"
	"github.com/golang-jwt/jwt/v5"
	"golang.org/x/crypto/bcrypt"
	"github.com/joho/godotenv"
	"golang.org/x/time/rate"
)

var supersecretkey string
var loginLimiters = make(map[string]*rate.Limiter)

var morseDictionary = map[string]string{
	"A": ".-",
	"B": "-...",
	"C": "-.-.",
	"D": "-..",
	"E": ".",
	"F": "..-.",
	"G": "--.",
	"H": "....",
	"I": "..",
	"J": ".---",
	"K": "-.-",
	"L": ".-..",
	"M": "--",
	"N": "-.",
	"O": "---",
	"P": ".--.",
	"Q": "--.-",
	"R": ".-.",
	"S": "...",
	"T": "-",
	"U": "..-",
	"V": "...-",
	"W": ".--",
	"X": "-..-",
	"Y": "-.--",
	"Z": "--..",
}


var defaultLessons = []Lesson{
	{ID: 1, Title: "Буквы A и B", Theory: "A = .- , B = -...", Symbols: []string{"A","B"}, XPReward: 50},
	{ID: 2, Title: "Добавляем C", Theory: "C = -.-.", Symbols: []string{"A","B","C"}, XPReward: 50},
}

type PracticeQuestion struct {
	Type     string   `json:"type"`
	Question string `json:"question"`
	Answer   string   `json:"answer"`
}

type PracticeResponse struct {
	Questions []PracticeQuestion `json:"questions"`
}

type User struct {
	Username   string `json:"username"`
	Email      string `json:"email"`
	Password   string `json:"password"`
	XP         int    `json:"xp"`
	LessonDone int    `json:"lesson_done"`
	Level      int    `json:"level"`
	Coins      int    `json:"coins"`
	Items      []int  `json:"items"`
	needXp     int    `json:"need_xp"`
	Streak     int `json:"streak"`
	LastLogin  string `json:"last_login"`
	UnlockedAchievements []string `json:"UnlockedAchievements"`
}

type LoginInput struct {
	Username string `json:"username" binding:"required"`
	Password string `json:"password" binding:"required"`
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

	return saveUsers(users)
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

func main() {
	rand.Seed(time.Now().UnixNano())
	godotenv.Load()
	supersecretkey = os.Getenv("JWT_SECRET")
	if supersecretkey == "" {
		panic("JWT_SECRET not set")
	}	

	res := gin.Default()

	res.POST("/api/register", func(c *gin.Context) {
		var user User

		if err := c.ShouldBindJSON(&user); err != nil {
			c.JSON(400, gin.H{
				"error": err.Error(),
			})
			return
		}

		users, err := readUsers()
		if err != nil {
			c.JSON(500, gin.H{"error": "Failed to read users", "details": err.Error(), "message": "Проблема открытия файла users.json. Убедитесь, что файл существует и имеет правильный формат."})
			return
		}

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

		if err := saveUsers(users); err != nil {
			c.JSON(500, gin.H{"error": "Failed to save users", "details": err.Error(), "message": "Проблема сохранения файла users.json. Убедитесь, что файл доступен для записи."})
			return
		}

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
				"message": "Неверные имя пользователя или пароль. Убедитесь, что вы вводите правильные данные.",
				"error": "Invalid username or password",
			})
			return
		}

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

		users, _ := readUsers()

		for _, u := range users {
			if u.Username == username {
				c.JSON(200, gin.H{
					"username":    u.Username,
					"email":       u.Email,
					"xp":          u.XP,
					"lesson_done": u.LessonDone,
					"level":       u.Level,
					"coins":       u.Coins,
					"items":       u.Items,
					"message":     "Профиль успешно загружен.",
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
				users[i].needXp = int(needXpForNewLevel * 100)

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

				if err := saveUsers(users); err != nil {
					c.JSON(500, gin.H{"error": "Failed to save users", "details": err.Error(), "message": "Проблема сохранения файла users.json. Убедитесь, что файл доступен для записи."})
					return
				}

				c.JSON(200, gin.H{
					"message": "Lesson completed",
					"xp":      users[i].XP,
					"level":   users[i].Level,
					"coins":   users[i].Coins,
					"need_xp": users[i].needXp,
					"new_achievements": newAchievements,
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

		lessons, err := readLessons()
		if err != nil {
			c.JSON(500, gin.H{"error": "Failed to read lessons"})
			return
		}

		id := c.Param("id")

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

		types := []string{"text", "morse", "audio"}

		var questions []PracticeQuestion
		for i := 0; i < 20; i++ {

			randomType := types[rand.Intn(len(types))]

			correctWord := generateRandomWord(selectedLesson.Symbols, 1)

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
				questions = append(questions, PracticeQuestion{
					Type:     "audio",
					Question: correctWord,
					Answer:   correctWord,
				})
			}
		}

		response := PracticeResponse{
			Questions: questions,
		}

		c.JSON(200, response)
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
				users[i].needXp = int(needXpForNewLevel * 100)

				if users[i].XP >= 100*int(needXpForNewLevel) {
					users[i].Level++
					users[i].XP = users[i].XP - 100*int(needXpForNewLevel)
				}

				users[i].Streak++
				users[i].LastLogin = time.Now().Format("2006-01-02")

				if err := saveUsers(users); err != nil {
					c.JSON(500, gin.H{"error": "Failed to save users", "details": err.Error(), "message": "Проблема сохранения файла users.json. Убедитесь, что файл доступен для записи."})
					return
				}

				c.JSON(200, gin.H{
					"message": "Correct answer! You've earned 5 coins and 10 XP.",
					"coins":   users[i].Coins,
					"xp":      users[i].XP,
					"level":   users[i].Level,
					"need_xp": users[i].needXp,
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

		if err := saveUsers(users); err != nil {
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

	res.Run(":8080")
}
