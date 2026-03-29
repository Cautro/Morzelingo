package handlers

import (
	"errors"
	"net/http"
	"strconv"

	"github.com/cautro/morzelingo/internal/models"
	"github.com/cautro/morzelingo/internal/services"
	"github.com/gin-gonic/gin"
)

func MakeRegisterHandler(authService *services.AuthService) gin.HandlerFunc {
	return func(c *gin.Context) {
		var in models.RegisterInput
		if err := c.ShouldBindJSON(&in); err != nil {
			c.JSON(http.StatusBadRequest, gin.H{"error": "invalid json"})
			return
		}

		result, err := authService.Register(in)
		switch {
		case err == nil:
			c.JSON(http.StatusCreated, result)
		case errors.Is(err, services.ErrUsernamePasswordRequired):
			c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		case errors.Is(err, services.ErrUsernameExists), errors.Is(err, services.ErrEmailExists):
			c.JSON(http.StatusConflict, gin.H{"error": err.Error()})
		case errors.Is(err, services.ErrTokenGeneration):
			c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		default:
			c.JSON(http.StatusInternalServerError, gin.H{"error": "server error"})
		}
	}
}

func MakeLoginHandler(authService *services.AuthService) gin.HandlerFunc {
	return func(c *gin.Context) {
		var in models.LoginInput
		if err := c.ShouldBindJSON(&in); err != nil {
			c.JSON(http.StatusBadRequest, gin.H{"error": "invalid input"})
			return
		}

		result, err := authService.Login(in)
		switch {
		case err == nil:
			c.JSON(http.StatusOK, result)
		case errors.Is(err, services.ErrInvalidCredentials):
			c.JSON(http.StatusUnauthorized, gin.H{"error": err.Error()})
		case errors.Is(err, services.ErrTokenGeneration):
			c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		default:
			c.JSON(http.StatusInternalServerError, gin.H{"error": "server error"})
		}
	}
}

func MakeListUsersHandler(userService *services.UserService) gin.HandlerFunc {
	return func(c *gin.Context) {
		c.JSON(http.StatusOK, userService.ListUsers())
	}
}

func MakeProfileHandler(userService *services.UserService) gin.HandlerFunc {
	return func(c *gin.Context) {
		result, err := userService.Profile(c.GetString("username"))
		if err != nil {
			c.JSON(http.StatusNotFound, gin.H{"error": "user not found"})
			return
		}

		c.JSON(http.StatusOK, result)
	}
}

func MakeCompleteLessonHandler(lessonService *services.LessonService) gin.HandlerFunc {
	return func(c *gin.Context) {
		var in struct {
			LessonID int `json:"lesson_id" binding:"required"`
		}
		if err := c.ShouldBindJSON(&in); err != nil {
			c.JSON(http.StatusBadRequest, gin.H{"error": "invalid input"})
			return
		}

		result, err := lessonService.CompleteLesson(c.GetString("username"), c.DefaultQuery("lang", "en"), in.LessonID)
		switch {
		case err == nil:
			c.JSON(http.StatusOK, result)
		case errors.Is(err, services.ErrInvalidLessonID), errors.Is(err, services.ErrInvalidLessonOrder):
			c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		case errors.Is(err, services.ErrUserNotFound):
			c.JSON(http.StatusNotFound, gin.H{"error": "user not found"})
		default:
			c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		}
	}
}

func MakeLessonsHandler(lessonService *services.LessonService) gin.HandlerFunc {
	return func(c *gin.Context) {
		lessons, err := lessonService.ListLessons(c.DefaultQuery("lang", "en"))
		if err != nil {
			c.JSON(http.StatusInternalServerError, gin.H{"error": "failed to read lessons"})
			return
		}

		c.JSON(http.StatusOK, lessons)
	}
}

func MakeLessonByIDHandler(lessonService *services.LessonService) gin.HandlerFunc {
	return func(c *gin.Context) {
		lesson, err := lessonService.LessonByID(c.DefaultQuery("lang", "en"), c.Param("id"))
		switch {
		case err == nil:
			c.JSON(http.StatusOK, lesson)
		case errors.Is(err, services.ErrLessonNotFound):
			c.JSON(http.StatusNotFound, gin.H{"error": "lesson not found"})
		default:
			c.JSON(http.StatusInternalServerError, gin.H{"error": "failed to read lessons"})
		}
	}
}

func MakePracticeByLessonHandler(practiceService *services.PracticeService) gin.HandlerFunc {
	return func(c *gin.Context) {
		result, err := practiceService.PracticeByLesson(c.GetString("username"), c.DefaultQuery("lang", "en"), c.Param("id"))
		switch {
		case err == nil:
			c.JSON(http.StatusOK, result)
		case errors.Is(err, services.ErrLessonNotFound):
			c.JSON(http.StatusNotFound, gin.H{"error": "lesson not found"})
		case errors.Is(err, services.ErrUserNotFound):
			c.JSON(http.StatusNotFound, gin.H{"error": "user not found"})
		default:
			c.JSON(http.StatusInternalServerError, gin.H{"error": "failed to read lessons"})
		}
	}
}

func MakeLettersPracticeHandler(practiceService *services.PracticeService) gin.HandlerFunc {
	return func(c *gin.Context) {
		result, err := practiceService.LettersPractice(c.Query("letters"), c.DefaultQuery("lang", "en"))
		switch {
		case err == nil:
			c.JSON(http.StatusOK, result)
		case errors.Is(err, services.ErrUseRussianLetters):
			c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		default:
			c.JSON(http.StatusInternalServerError, gin.H{"error": "server error"})
		}
	}
}

func MakePracticeSubmitHandler(practiceService *services.PracticeService) gin.HandlerFunc {
	return func(c *gin.Context) {
		var updates []models.SymbolUpdate
		if err := c.ShouldBindJSON(&updates); err != nil {
			c.JSON(http.StatusBadRequest, gin.H{"error": "invalid input"})
			return
		}

		result, err := practiceService.Submit(c.GetString("username"), updates)
		switch {
		case err == nil:
			c.JSON(http.StatusOK, result)
		case errors.Is(err, services.ErrUserNotFound):
			c.JSON(http.StatusNotFound, gin.H{"error": "user not found"})
		default:
			c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		}
	}
}

func MakeFreemodeHandler(practiceService *services.PracticeService) gin.HandlerFunc {
	return func(c *gin.Context) {
		count, _ := strconv.Atoi(c.DefaultQuery("count", "20"))
		if count <= 0 {
			count = 20
		}

		result, err := practiceService.Freemode(
			c.GetString("username"),
			c.DefaultQuery("lang", "en"),
			c.DefaultQuery("letters", ""),
			c.DefaultQuery("mode", "text"),
			count,
		)
		switch {
		case err == nil:
			c.JSON(http.StatusOK, result)
		case errors.Is(err, services.ErrNoSymbolsAvailable):
			c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		case errors.Is(err, services.ErrUserNotFound):
			c.JSON(http.StatusNotFound, gin.H{"error": "user not found"})
		default:
			c.JSON(http.StatusInternalServerError, gin.H{"error": "server error"})
		}
	}
}

func MakeListFriendHandler(userService *services.UserService) gin.HandlerFunc {
	return func(c *gin.Context) {
		result, err := userService.ListFriends(c.GetString("username"))
		if err != nil {
			c.JSON(http.StatusNotFound, gin.H{"error": "user not found"})
			return
		}

		c.JSON(http.StatusOK, result)
	}
}

func MakeAddFriendHandler(userService *services.UserService) gin.HandlerFunc {
	return func(c *gin.Context) {
		var body struct {
			Friend string `json:"friend" binding:"required"`
		}
		if err := c.ShouldBindJSON(&body); err != nil {
			c.JSON(http.StatusBadRequest, gin.H{"error": "friend required"})
			return
		}

		result, err := userService.AddFriend(c.GetString("username"), body.Friend)
		switch {
		case err == nil:
			c.JSON(http.StatusOK, result)
		case errors.Is(err, services.ErrCannotAddYourself):
			c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		case errors.Is(err, services.ErrFriendNotFound):
			c.JSON(http.StatusNotFound, gin.H{"error": err.Error()})
		default:
			c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		}
	}
}

func MakeUpdateStreakHandler(userService *services.UserService) gin.HandlerFunc {
	return func(c *gin.Context) {
		err := userService.UpdateFriendshipStreaks(c.GetString("username"))
		switch {
		case err == nil:
			c.JSON(http.StatusOK, gin.H{"ok": true})
		case errors.Is(err, services.ErrUserNotFound):
			c.JSON(http.StatusNotFound, gin.H{"error": "user not found"})
		default:
			c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		}
	}
}

func MakeFriendShipStreakHandler(userService *services.UserService) gin.HandlerFunc {
	return func(c *gin.Context) {
		result, err := userService.FriendshipStreaks(c.GetString("username"), c.DefaultQuery("me", "false") == "true")
		if err != nil {
			c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
			return
		}

		c.JSON(http.StatusOK, result)
	}
}

func MakeDeleteFriendHandler(userService *services.UserService) gin.HandlerFunc {
	return func(c *gin.Context) {
		var body struct {
			Friend string `json:"friend" binding:"required"`
		}
		if err := c.ShouldBindJSON(&body); err != nil {
			c.JSON(http.StatusBadRequest, gin.H{"error": "friend required"})
			return
		}

		result, err := userService.DeleteFriend(c.GetString("username"), body.Friend)
		switch {
		case err == nil:
			c.JSON(http.StatusOK, result)
		case errors.Is(err, services.ErrCannotDeleteYourself):
			c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		case errors.Is(err, services.ErrFriendNotFound):
			c.JSON(http.StatusNotFound, gin.H{"error": err.Error()})
		default:
			c.JSON(http.StatusInternalServerError, gin.H{"error": "failed to update"})
		}
	}
}

func MakeReplayLessonHandler(practiceService *services.PracticeService) gin.HandlerFunc {
	return func(c *gin.Context) {
		result, err := practiceService.ReplayLesson(c.DefaultQuery("lang", "en"), c.Param("id"))
		switch {
		case err == nil:
			c.JSON(http.StatusOK, result)
		case errors.Is(err, services.ErrLessonNotFound):
			c.JSON(http.StatusNotFound, gin.H{"error": "lesson not found"})
		default:
			c.JSON(http.StatusInternalServerError, gin.H{"error": "failed to read lessons"})
		}
	}
}
