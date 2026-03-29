package handlers

import (
	"errors"
	"net/http"
	// "strconv"

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


