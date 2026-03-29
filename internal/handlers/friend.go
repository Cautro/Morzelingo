package handlers

import (
	"errors"
	"net/http"
	
	"github.com/cautro/morzelingo/internal/services"
	"github.com/gin-gonic/gin"
)

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

