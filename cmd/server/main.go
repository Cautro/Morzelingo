package main

import (
	// "encoding/json"
	// "fmt"
	"log"
	// "net/http"
	"os"
	// "path/filepath"
	"sync"
	// "time"

	"github.com/cautro/morzelingo/internal/app"
	"github.com/cautro/morzelingo/internal/handlers"
	// "github.com/cautro/morzelingo/internal/models"
	"github.com/cautro/morzelingo/internal/storage"
	"github.com/cautro/morzelingo/internal/worker"
	"github.com/gin-gonic/gin"
	"github.com/joho/godotenv"
)

const friendshipFile = "data/friendship_streaks.json"

var fsMu sync.Mutex 

func main() {
	_ = godotenv.Load()
	jwtSecret := os.Getenv("JWT_SECRET")
	if jwtSecret == "" {
		log.Fatal("JWT_SECRET not set in environment")
	}

	if _, err := os.Stat("data"); os.IsNotExist(err) {
		if err := os.Mkdir("data", 0o755); err != nil {
			log.Fatalf("create data dir: %v", err)
		}
	}

	usersPath := "data/users.json"
	st := storage.New(usersPath)
	users, err := st.ReadUsers()
	if err != nil {
		log.Fatalf("read users: %v", err)
	}

	saver := worker.NewSaver(st, worker.DefaultDebounce)
	a := app.NewApp(users, st, saver, jwtSecret)
	saver.Start()
	defer saver.Stop()

	r := gin.Default()

	r.POST("/api/register", handlers.MakeRegisterHandler(a))
	r.POST("/api/login", handlers.MakeLoginHandler(a))
	r.POST("/api/practice", handlers.MakeLettersPracticeHandler(a)) 

	auth := r.Group("/api", handlers.AuthMiddleware(a))
	{
		auth.GET("/users", handlers.MakeListUsersHandler(a))
		auth.GET("/profile", handlers.MakeProfileHandler(a))

		auth.POST("/complete-lesson", handlers.MakeCompleteLessonHandler(a))
		auth.GET("/lessons", handlers.MakeLessonsHandler(a))
		auth.GET("/lessons/:id", handlers.MakeLessonByIDHandler(a))
		auth.GET("/practice/:id", handlers.MakePracticeByLessonHandler(a))
		auth.POST("/practice/submit", handlers.MakePracticeSubmitHandler(a))
		auth.GET("/freemode", handlers.MakeFreemodeHandler(a))
		auth.GET("/friends", handlers.MakeListFriendHandler(a)) 
		auth.POST("/friends/add", handlers.MakeAddFriendHandler(a))
		auth.POST("/friends/update-streaks", handlers.MakeUpdateStreakHandler(a))
		auth.GET("/friendship-streaks", handlers.MakeFriendShipStreakHandler(a))
		auth.POST("/friends/delete", handlers.MakeDeleteFriendHandler(a))
	}

	addr := ":8080"
	log.Printf("Server listening on %s", addr)
	if err := r.Run(addr); err != nil {
		log.Fatalf("server failed: %v", err)
	}
}