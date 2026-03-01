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
	Username   string `json:"username" binding:"required,min=3"`
	Email      string `json:"email" binding:"required,email"`
	Password   string `json:"password" binding:"required,min=6"`
	XP         int    `json:"xp"`
	LessonDone int    `json:"lesson_done"`
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
			c.JSON(500, gin.H{"error": "Failed to read users"})
			return
		}

		// Проверка на существование
		for _, u := range users {
			if u.Username == user.Username {
				c.JSON(400, gin.H{"error": "User exists"})
				return
			}
		}

		for _, u := range users {
			if u.Email == user.Email {
				c.JSON(400, gin.H{"error": "Email already exists"})
				return
			}
		}

		hashed, _ := bcrypt.GenerateFromPassword([]byte(user.Password), bcrypt.DefaultCost)
		user.Password = string(hashed)
		users = append(users, user)

		if err := saveUsers(users); err != nil {
			c.JSON(500, gin.H{"error": "Failed to save users"})
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

		// 🎫 Генерируем JWT
		token, err := generateToken(foundUser.Username)
		if err != nil {
			c.JSON(500, gin.H{
				"error": "Could not generate token",
			})
			return
		}

		// ✅ Успешный ответ
		c.JSON(200, gin.H{
			"message": "Login successful",
			"token":   token,
		})
	})


	res.GET("/api/profile", authMiddleware(), func(c *gin.Context) {

		username, exists := c.Get("username")
		if !exists {
			c.JSON(500, gin.H{"error": "username not found in context"})
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
				})
				return
			}
		}

		c.JSON(404, gin.H{"error": "user not found"})
	})

	res.POST("/api/complete-lesson", authMiddleware(), func(c *gin.Context) {

		username := c.GetString("username")

		var input struct {
			LessonID int `json:"lesson_id" binding:"required"`
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

		for i, u := range users {
			if u.Username == username {
				if input.LessonID != u.LessonDone+1 {
					c.JSON(400, gin.H{"error": "Invalid lesson order"})
					return
				}

				users[i].LessonDone++
				users[i].XP += 50 

				saveUsers(users)

				c.JSON(200, gin.H{
					"message": "Lesson completed",
					"xp":      users[i].XP,
				})
				return
			}
		}

		c.JSON(404, gin.H{"error": "User not found"})
	})

	res.GET("/api/lessons", func(c *gin.Context) {
		lessons, err := readLessons()
		if err != nil {
			c.JSON(500, gin.H{
				"error": "Failed to read lessons",
			})
			return
		}
		c.JSON(200, lessons)
	})

	res.GET("/api/lessons/:id", func(c *gin.Context) {
		lessons, err := readLessons()
		if err != nil {
			c.JSON(500, gin.H{
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
		c.JSON(404, gin.H{"error": "Lesson not found"})
	})

	res.GET("/api/practice/:id", func(c *gin.Context) {
		lessons, err := readLessons()
		if err != nil {
			c.JSON(500, gin.H{
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
		c.JSON(404, gin.H{"error": "Lesson not found"})
	})

	res.Run(":8080")
}
