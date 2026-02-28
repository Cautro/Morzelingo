package main

import (
	"encoding/json"
	"os"
	"time"

	"github.com/gin-gonic/gin"
	"github.com/golang-jwt/jwt/v5"
	"golang.org/x/crypto/bcrypt"
	// "github.com/joho/godotenv"
)

var supersecretkey = "IVERYLOVEMORZELINGO"

type User struct {
	Username   string `json:"username"`
	Email      string `json:"email"`
	Password   string `json:"password"`
	XP         int    `json:"xp"`
	LessonDone int    `json:"lesson_done"`
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

func generateToken(username string) (string, error) {
	token := jwt.NewWithClaims(jwt.SigningMethodHS256, jwt.MapClaims{
		"username": username,
		"exp":      time.Now().Add(time.Hour * 24).Unix(),
	})

	return token.SignedString([]byte(supersecretkey))
}

func main() {
	res := gin.Default()
	res.POST("/api/register", func(c *gin.Context) {
		var user User

		if err := c.ShouldBindJSON(&user); err != nil {
			c.JSON(400, gin.H{"error": "Invalid input"})
			return
		}

		users, _ := readUsers()

		// Проверка на существование
		for _, u := range users {
			if u.Username == user.Username {
				c.JSON(400, gin.H{"error": "User exists"})
				return
			}
		}

		hashed, _ := bcrypt.GenerateFromPassword([]byte(user.Password), bcrypt.DefaultCost)
		user.Password = string(hashed)
		users = append(users, user)
		saveUsers(users)

		c.JSON(200, gin.H{"message": "User saved"})
	})

	res.POST("/api/login", func(c *gin.Context) {
		var input User

		if err := c.ShouldBindJSON(&input); err != nil {
			c.JSON(400, gin.H{"error": "Invalid input"})
			return
		}

		users, _ := readUsers()
		var foundUser *User
		for i := range users {
			if users[i].Username == input.Username {
				foundUser = &users[i]
				break
			}
		}

		if foundUser == nil {
			c.JSON(400, gin.H{"error": "User not found"})
			return
		}

		err := bcrypt.CompareHashAndPassword([]byte(foundUser.Password), []byte(input.Password))
		if err != nil {
			c.JSON(400, gin.H{"error": "Incorrect password"})
			return
		}

		token, err := generateToken(foundUser.Username)
		if err != nil {
			c.JSON(500, gin.H{"error": "could not generate token"})
			return
		}

		c.JSON(200, gin.H{
			"token":   token,
			"message": "Login successful",
		})
	})

	res.Run(":8080")
}
