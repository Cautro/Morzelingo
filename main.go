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

type User struct {
	Username   string `json:"username"`
	Email      string `json:"email"`
	Password   string `json:"password"`
	XP         int    `json:"xp"`
	LessonDone int    `json:"lesson_done"`
	Level      int    `json:"level"`
	Coins      int    `json:"coins"`
	Items      []int  `json:"items"`
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

		// 🔐 Rate limit по IP
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

		// 🎫 Генерируем JWT
		token, err := generateToken(foundUser.Username)
		if err != nil {
			c.JSON(500, gin.H{
				"message": "Успешный вход, но не удалось создать токен. Попробуйте снова.",
				"error": "Could not generate token",
			})
			return
		}

		// ✅ Успешный ответ
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

		for i, u := range users {
			if u.Username == username {
				if input.LessonID != u.LessonDone+1 {
					c.JSON(400, gin.H{"error": "Invalid lesson order", "message": "Неверный порядок уроков. Убедитесь, что вы завершаете уроки в правильной последовательности."})
					return
				}

				users[i].LessonDone++
				users[i].XP += 50 
				
				multyplayer := 1 + float64(users[i].Level)*1.5

				if users[i].XP >= 100*int(multyplayer) {
					users[i].Level++
					users[i].XP = users[i].XP - 100
				}

				saveUsers(users)

				c.JSON(200, gin.H{
					"message": "Lesson completed",
					"xp":      users[i].XP,
					"level":   users[i].Level,
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
			c.JSON(500, gin.H{
				"message": "Проблема открытия файла с уроками. Убедитесь, что файл существует и имеет правильный формат.",
				"error": "Failed to read lessons",
			})
			return
		}
		
		id := c.Param("id")
		for _, lesson := range lessons {
			if fmt.Sprintf("%d", lesson.ID) == id {
				lesson.Practice = generatePractice(lesson.Symbols, 5)
				c.JSON(200, lesson.Practice)
				return
			}
		}
		c.JSON(404, gin.H{"error": "Lesson not found", "message": "Урок не найден. Пожалуйста, проверьте ID урока."})
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

		c.JSON(200, gin.H{
			"level":   userLevel,
			"question": question,
		})
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

	res.POST("/api/complete-practice", authMiddleware(), func(c *gin.Context) {
		username := c.GetString("username")
		c.JSON(200, gin.H{
			"message": "complete practice"
		})
	})

	res.Run(":8080")
}
