package models

type SymbolStat struct {
	Symbol  string `json:"symbol"`
	Correct int    `json:"correct"`
	Wrong   int    `json:"wrong"`
}

type User struct {
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
	UnlockedAchievements []string     `json:"UnlockedAchievements"`
	SymbolStats          []SymbolStat `json:"symbol_stats"`
	ReferralCode         string       `json:"referral_code"`
	ReferredBy           string       `json:"referred_by"`
	ReferralCount        int          `json:"referred_count"`
	Friends              []string     `json:"friends"`
}