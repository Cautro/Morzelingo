package handlers

import (
	"errors"
	"net/http"

	"github.com/cautro/morzelingo/internal/services"
	"github.com/gin-gonic/gin"
)

func MakeMatchmakeDuelHandler(duelService *services.DuelService) gin.HandlerFunc {
	return func(c *gin.Context) {
		result, err := duelService.MatchmakeDuel(c.GetString("username"))
		if err != nil {
			c.JSON(http.StatusInternalServerError, gin.H{"error": "matchmaking failed"})
			return
		}

		code := http.StatusOK
		if result.Status == "waiting" {
			code = http.StatusCreated
		}

		c.JSON(code, result)
	}
}

func MakeGetTasksHandler(duelService *services.DuelService) gin.HandlerFunc {
	return func(c *gin.Context) {
		result, err := duelService.GetTasks(c.GetString("username"), c.DefaultQuery("lang", "en"), c.Param("id"))
		switch {
		case err == nil:
			c.JSON(http.StatusOK, result)
		case errors.Is(err, services.ErrUnsupportedLanguage):
			c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		case errors.Is(err, services.ErrDuelNotFound):
			c.JSON(http.StatusNotFound, gin.H{"error": "duel not found"})
		case errors.Is(err, services.ErrNotYourDuel):
			c.JSON(http.StatusForbidden, gin.H{"error": "not your duel"})
		case errors.Is(err, services.ErrUserNotFound):
			c.JSON(http.StatusInternalServerError, gin.H{"error": "user not found"})
		default:
			c.JSON(http.StatusInternalServerError, gin.H{"error": "server error"})
		}
	}
}

func MakeUpdateScoreHandler(duelService *services.DuelService) gin.HandlerFunc {
	return func(c *gin.Context) {
		var in struct {
			Score int `json:"score"`
		}
		if err := c.BindJSON(&in); err != nil {
			c.JSON(http.StatusBadRequest, gin.H{"error": "invalid body"})
			return
		}

		result, err := duelService.UpdateScore(c.GetString("username"), c.Param("id"), in.Score)
		switch {
		case err == nil:
			c.JSON(http.StatusOK, result)
		case errors.Is(err, services.ErrDuelNotFound):
			c.JSON(http.StatusNotFound, gin.H{"error": "duel not found"})
		case errors.Is(err, services.ErrNotYourDuel):
			c.JSON(http.StatusForbidden, gin.H{"error": "not your duel"})
		case errors.Is(err, services.ErrDuelAlreadyFinished):
			c.JSON(http.StatusBadRequest, gin.H{"error": "duel already finished"})
		case errors.Is(err, services.ErrDuelNotActive):
			c.JSON(http.StatusBadRequest, gin.H{"error": "duel not active yet"})
		default:
			c.JSON(http.StatusInternalServerError, gin.H{"error": "server error"})
		}
	}
}

func MakeCompleteDuelHandler(duelService *services.DuelService) gin.HandlerFunc {
	return func(c *gin.Context) {
		var in struct {
			Score int `json:"score"`
		}
		_ = c.ShouldBindJSON(&in)

		result, err := duelService.CompleteDuel(c.GetString("username"), c.Param("id"), in.Score)
		switch {
		case err == nil:
			c.JSON(http.StatusOK, result)
		case errors.Is(err, services.ErrDuelNotFound):
			c.JSON(http.StatusNotFound, gin.H{"error": "duel not found"})
		case errors.Is(err, services.ErrNotYourDuel):
			c.JSON(http.StatusForbidden, gin.H{"error": "not your duel"})
		case errors.Is(err, services.ErrDuelCancelled):
			c.JSON(http.StatusBadRequest, gin.H{"error": "duel cancelled"})
		case errors.Is(err, services.ErrAlreadyCompleted):
			c.JSON(http.StatusBadRequest, gin.H{"error": "already completed"})
		case errors.Is(err, services.ErrDuelNotActive):
			c.JSON(http.StatusBadRequest, gin.H{"error": "duel not active yet"})
		default:
			c.JSON(http.StatusInternalServerError, gin.H{"error": "server error"})
		}
	}
}

func MakeStatusDuelHandler(duelService *services.DuelService) gin.HandlerFunc {
	return func(c *gin.Context) {
		result, err := duelService.Status(c.Param("id"))
		switch {
		case err == nil:
			c.JSON(http.StatusOK, result)
		case errors.Is(err, services.ErrDuelNotFound):
			c.JSON(http.StatusNotFound, gin.H{"error": "duel not found"})
		default:
			c.JSON(http.StatusInternalServerError, gin.H{"error": "failed to read duels"})
		}
	}
}

func MakeListDuelHandler(duelService *services.DuelService) gin.HandlerFunc {
	return func(c *gin.Context) {
		result, err := duelService.List()
		if err != nil {
			c.JSON(http.StatusInternalServerError, gin.H{"error": "failed to read duels"})
			return
		}

		c.JSON(http.StatusOK, result)
	}
}

func MakeLeaveDuelsHandler(duelService *services.DuelService) gin.HandlerFunc {
	return func(c *gin.Context) {
		result, err := duelService.LeaveDuel(c.GetString("username"), c.Param("id"))
		switch {
		case err == nil:
			c.JSON(http.StatusOK, result)
		case errors.Is(err, services.ErrDuelNotFound):
			c.JSON(http.StatusNotFound, gin.H{"error": "duel not found"})
		case errors.Is(err, services.ErrNotParticipant):
			c.JSON(http.StatusForbidden, gin.H{"error": "you are not a participant"})
		case errors.Is(err, services.ErrDuelAlreadyFinished):
			c.JSON(http.StatusBadRequest, gin.H{"error": "duel already finished"})
		default:
			c.JSON(http.StatusInternalServerError, gin.H{"error": "failed to save"})
		}
	}
}
