package models

import ("github.com/golang-jwt/jwt/v5")

type User struct {	
	Elo                  int          `json:"elo"`
	Username             string       `json:"username"`
	Email                string       `json:"email"`
	Password             string       `json:"password"`
	XP                   int          `json:"xp"`
	LastLessonDone       int          `json:"lesson_done"`
	LessonDone_RU        int          `json:"lesson_done_ru"`
	LessonDone_EN        int          `json:"lesson_done_en"`
	Level                int          `json:"level"`
	Coins                int          `json:"coins"`
	Items                []int        `json:"items"`
	NeedXp               int          `json:"need_xp"`
	Streak               int          `json:"streak"`
	LastStreak           int          `json:"last_streak"`
	AnswerStreak         int          `json:"answer_streak"`
	LastLogin            string       `json:"last_login"`
	UnlockedAchievements []string     `json:"unlocked_achievements"`
	SymbolStats          []SymbolStat `json:"symbol_stats"`
	ReferralCode         string       `json:"referral_code"`
	ReferredBy           string       `json:"referred_by"`
	ReferralCount        int          `json:"referred_count"`
	Friends              []string     `json:"friends"`
	RegisteredDate       string       `json:"registered_date"`
	MaxScoreInDuel       int          `json:"max_score_in_duel"`
	DuelsWin              int          `json:"duelswin"`
}

type Claims struct {
	Username string `json:"username"`
	jwt.RegisteredClaims
}