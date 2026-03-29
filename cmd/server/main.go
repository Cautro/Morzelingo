package main

import (
	"log"
	"os"
	"sync"

	"github.com/cautro/morzelingo/internal/app"
	"github.com/cautro/morzelingo/internal/handlers"
	"github.com/cautro/morzelingo/internal/services"
	"github.com/cautro/morzelingo/internal/storage"
	"github.com/cautro/morzelingo/internal/utils"
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
	s := services.NewDuelService(a)
	saver.Start()
	defer saver.Stop()

	r := gin.Default()

	// Without middleware
	r.POST("/api/register", handlers.MakeRegisterHandler(a))
	r.POST("/api/login", handlers.MakeLoginHandler(a))
	r.POST("/api/practice", handlers.MakeLettersPracticeHandler(a)) 

	auth := r.Group("/api", utils.AuthMiddleware(a))
	{
		// User
		auth.GET("/users", handlers.MakeListUsersHandler(a))
		auth.GET("/profile", handlers.MakeProfileHandler(a))

		// Lesson
		auth.GET("/lessons", handlers.MakeLessonsHandler(a))
		auth.GET("/lessons/:id", handlers.MakeLessonByIDHandler(a))
		auth.POST("/complete-lesson", handlers.MakeCompleteLessonHandler(a))

		// Practice
		auth.GET("/practice/:id", handlers.MakePracticeByLessonHandler(a))
		auth.GET("/practice/replay/:id", handlers.MakeReplayLessonHandler(a))
		auth.POST("/practice/submit", handlers.MakePracticeSubmitHandler(a))
	
		// Freemode
		auth.GET("/freemode", handlers.MakeFreemodeHandler(a))
		
		// Friends
		auth.GET("/friends", handlers.MakeListFriendHandler(a)) 
		auth.POST("/friends/add", handlers.MakeAddFriendHandler(a))
		auth.POST("/friends/update-streaks", handlers.MakeUpdateStreakHandler(a))
		auth.GET("/friendship-streaks", handlers.MakeFriendShipStreakHandler(a))
		auth.POST("/friends/delete", handlers.MakeDeleteFriendHandler(a))
		

		// Duels
		auth.POST("/duel/matchmake", handlers.MakeMatchmakeDuelHandler(s))
		auth.GET("/duels", handlers.MakeListDuelHandler(a))
		auth.GET("/duels/status/:id", handlers.MakeStatusDuelHandler(a))
		auth.POST("/duels/get-tasks/:id", handlers.MakeGetTasksHandler(a))
		auth.POST("/duels/leave/:id", handlers.MakeLeaveDuelsHandler(a))
		auth.POST("/duels/update-score/:id", handlers.MakeUpdateScoreHandler(a))
		auth.POST("/duels/complete/:id",     handlers.MakeCompleteDuelHandler(a))
	}

	addr := ":8080"
	log.Printf("Server listening on %s", addr)
	if err := r.Run(addr); err != nil {
		log.Fatalf("server failed: %v", err)
	}
}