package main

import (
	"log"
	"os"

	"github.com/cautro/morzelingo/internal/app"
	"github.com/cautro/morzelingo/internal/handlers"
	"github.com/cautro/morzelingo/internal/repo"
	"github.com/cautro/morzelingo/internal/services"
	"github.com/cautro/morzelingo/internal/storage"
	"github.com/cautro/morzelingo/internal/utils"
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

	if _, err := os.Stat("data"); os.IsNotExist(err) {
		if err := os.Mkdir("data", 0o755); err != nil {
			log.Fatalf("create data dir: %v", err)
		}
	}

	dbPath := "data/app.db"
	st, err := storage.New(dbPath)
	if err != nil {
		log.Fatalf("open sqlite storage: %v", err)
	}
	defer st.Close()

	users, err := st.ReadUsers()
	if err != nil {
		log.Fatalf("read users: %v", err)
	}

	saver := worker.NewSaver(st, worker.DefaultDebounce)
	a := app.NewApp(users, st, saver, jwtSecret)

	userRepo := repo.NewAppUserRepo(a)
	lessonRepo := repo.NewStorageLessonRepo(st)
	streakRepo := repo.NewStorageFriendshipStreakRepo(st)

	authService := services.NewAuthService(userRepo, jwtSecret)
	userService := services.NewUserService(userRepo, streakRepo)
	lessonService := services.NewLessonService(userRepo, lessonRepo)
	practiceService := services.NewPracticeService(userRepo, lessonRepo)
	duelService := services.NewDuelService(a)
	saver.Start()
	defer saver.Stop()

	r := gin.Default()

	r.POST("/api/register", handlers.MakeRegisterHandler(authService))
	r.POST("/api/login", handlers.MakeLoginHandler(authService))
	r.POST("/api/practice", handlers.MakeLettersPracticeHandler(practiceService))

	auth := r.Group("/api", utils.AuthMiddleware(a))
	{
		auth.GET("/users", handlers.MakeListUsersHandler(userService))
		auth.GET("/profile", handlers.MakeProfileHandler(userService))

		auth.GET("/lessons", handlers.MakeLessonsHandler(lessonService))
		auth.GET("/lessons/:id", handlers.MakeLessonByIDHandler(lessonService))
		auth.POST("/complete-lesson", handlers.MakeCompleteLessonHandler(lessonService))

		auth.GET("/practice/:id", handlers.MakePracticeByLessonHandler(practiceService))
		auth.GET("/practice/replay/:id", handlers.MakeReplayLessonHandler(practiceService))
		auth.POST("/practice/submit", handlers.MakePracticeSubmitHandler(practiceService))

		auth.GET("/freemode", handlers.MakeFreemodeHandler(practiceService))
		auth.POST("/freemode/complite", handlers.MakeFreemodeCompliteHandler(practiceService))

		auth.GET("/friends", handlers.MakeListFriendHandler(userService))
		auth.POST("/friends/add", handlers.MakeAddFriendHandler(userService))
		auth.POST("/friends/update-streaks", handlers.MakeUpdateStreakHandler(userService))
		auth.GET("/friendship-streaks", handlers.MakeFriendShipStreakHandler(userService))
		auth.POST("/friends/delete", handlers.MakeDeleteFriendHandler(userService))

		auth.POST("/duel/matchmake", handlers.MakeMatchmakeDuelHandler(duelService))
		auth.GET("/duels", handlers.MakeListDuelHandler(duelService))
		auth.GET("/duels/status/:id", handlers.MakeStatusDuelHandler(duelService))
		auth.POST("/duels/get-tasks/:id", handlers.MakeGetTasksHandler(duelService))
		auth.POST("/duels/leave/:id", handlers.MakeLeaveDuelsHandler(duelService))
		auth.POST("/duels/update-score/:id", handlers.MakeUpdateScoreHandler(duelService))
		auth.POST("/duels/complete/:id", handlers.MakeCompleteDuelHandler(duelService))
	}

	addr := ":8080"
	log.Printf("Server listening on %s", addr)
	if err := r.Run(addr); err != nil {
		log.Fatalf("server failed: %v", err)
	}
}
