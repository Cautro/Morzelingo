package handlers

import (
	"net/http"

	"github.com/cautro/morzelingo/internal/services"
	"github.com/gin-gonic/gin"
)

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

