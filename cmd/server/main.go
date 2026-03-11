package main

import (
	"log"
	"os"

	"github.com/cautro/morzelingo/internal/app"
	"github.com/cautro/morzelingo/internal/handlers"
	"github.com/cautro/morzelingo/internal/storage"
	"github.com/cautro/morzelingo/internal/worker"
	"github.com/gin-gonic/gin"
	"github.com/joho/godotenv"
)

func main() {
	_ = godotenv.Load()
	jwtSecret := os.Getenv("JWT_SECRET")
	if jwtSecret == "" {
		log.Fatal("JWT_SECRET not set in environment")
	}

	usersPath := "data/users.json"
	if _, err := os.Stat("data"); os.IsNotExist(err) {
		if err := os.Mkdir("data", 0o755); err != nil {
			log.Fatalf("create data dir: %v", err)
		}
	}

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
	}

	addr := ":8080"
	log.Printf("Server listening on %s", addr)
	if err := r.Run(addr); err != nil {
		log.Fatalf("server failed: %v", err)
	}
}