package handlers

import (
	"errors"
	"net/http"
	// "strconv"

	"github.com/cautro/morzelingo/internal/models"
	"github.com/cautro/morzelingo/internal/services"
	"github.com/gin-gonic/gin"
)

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

