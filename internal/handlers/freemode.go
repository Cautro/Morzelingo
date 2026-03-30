package handlers

import (
	"errors"
	"net/http"
	"strconv"

	// "github.com/cautro/morzelingo/internal/models"
	"github.com/cautro/morzelingo/internal/services"
	"github.com/gin-gonic/gin"
)

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

func MakeFreemodeCompliteHandler(practiceService *services.PracticeService) gin.HandlerFunc {
	return func (c *gin.Context)  {
		err := practiceService.FreemodeComplite(
			c.GetString("username"),
		)

		switch {
		case err == nil:
			c.JSON(http.StatusOK, gin.H{"ok": true})
		default:
			c.JSON(http.StatusInternalServerError, gin.H{"error": "server error", "ok": false})
		}
	}
}