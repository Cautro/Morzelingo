package models

import ("github.com/golang-jwt/jwt/v5")

type SymbolStat struct {
	Symbol  string `json:"symbol"`
	Correct int    `json:"correct"`
	Wrong   int    `json:"wrong"`
}

type Duel struct {
    ID string `json:"id"`

    Player1 string `json:"player1"`
    Player2 string `json:"player2"`

    Status string `json:"status"` 
    // waiting
    // active
    // finished

    Tasks []MorseTask `json:"tasks"`

    P1Score int `json:"p1_score"`
    P2Score int `json:"p2_score"`

    P1Time int64 `json:"p1_time"`
    P2Time int64 `json:"p2_time"`

    Winner string `json:"winner"`

    CreatedAt int64 `json:"created_at"`
}

type MorseTask struct {
    Morse string `json:"morse"`
    Answer string `json:"answer"`
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
	RegisteredDate       string       `json:"registered_date"`
}

type FriendshipStreak struct {
    User1          string `json:"user1"`
    User2          string `json:"user2"`
    Streak         int   `json:"streak"`
    LastActive     string `json:"last_active"` 
}

// ----- Request / Response types -----
type LoginInput struct {
	Username string `json:"username" binding:"required"`
	Password string `json:"password" binding:"required"`
}

type RegisterInput struct {
	Username      string `json:"username"`
	Email         string `json:"email"`
	Password      string `json:"password"`
	ReferralInput string `json:"referral_code"`
}

type SymbolUpdate struct {
	Symbol  string `json:"symbol" binding:"required"`
	Correct int    `json:"correct"`
	Wrong   int    `json:"wrong"`
}

type PracticeQuestion struct {
	Type     string `json:"type"`
	Question string `json:"question"`
	Answer   string `json:"answer,omitempty"`
}

type PracticeResponse struct {
	Questions []PracticeQuestion `json:"questions"`
}

// Lessons/claims
type Lesson struct {
	ID       int      `json:"id"`
	Title    string   `json:"title"`
	Theory   string   `json:"theory"`
	Symbols  []string `json:"symbols"`
	XPReward int      `json:"xp_reward"`
	Practice string   `json:"practice"`
}

type Claims struct {
	Username string `json:"username"`
	jwt.RegisteredClaims
}

// ----- Morse dictionaries (simple) -----
var EnglishMorseDictionary = map[string]string{
	"A": ".-", "B": "-...", "C": "-.-.", "D": "-..", "E": ".",
	"F": "..-.", "G": "--.", "H": "....", "I": "..", "J": ".---",
	"K": "-.-", "L": ".-..", "M": "--", "N": "-.", "O": "---",
	"P": ".--.", "Q": "--.-", "R": ".-.", "S": "...", "T": "-",
	"U": "..-", "V": "...-", "W": ".--", "X": "-..-", "Y": "-.--", "Z": "--..",
	"0": "-----", "1": ".----", "2": "..---", "3": "...--", "4": "....-", "5": ".....",
	"6": "-....", "7": "--...", "8": "---..", "9": "----.",
}

var RussianMorseDictionary = map[string]string{
	"А": ".-", "Б": "-...", "В": ".--", "Г": "--.", "Д": "-..", "Е": ".",
	"Ж": "...-", "З": "--..", "И": "..", "Й": ".---", "К": "-.-", "Л": ".-..",
	"М": "--", "Н": "-.", "О": "---", "П": ".--.", "Р": ".-.", "С": "...",
	"Т": "-", "У": "..-", "Ф": "..-.", "Х": "....", "Ц": "-.-.", "Ч": "---.",
	"Ш": "----", "Щ": "--.-", "Ъ": "--.--", "Ы": "-.--", "Ь": "-..-", "Э": "..-..",
	"Ю": "..--", "Я": ".-.-",
	"0": "-----", "1": ".----", "2": "..---", "3": "...--", "4": "....-", "5": ".....",
	"6": "-....", "7": "--...", "8": "---..", "9": "----.",
}