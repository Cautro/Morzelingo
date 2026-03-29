package handlers

import (
	"errors"
	"net/http"

	"github.com/cautro/morzelingo/internal/services"
	"github.com/gin-gonic/gin"
)


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