package models

type FriendshipStreak struct {
    User1          string `json:"user1"`
    User2          string `json:"user2"`
    Streak         int   `json:"streak"`
    LastActive     string `json:"last_active"` 
}