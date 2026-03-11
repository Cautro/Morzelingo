package handlers

import (
	"encoding/json"
	"fmt"
	"math/rand"
	"net/http"
	"os"
	"strconv"
	"strings"
	"time"

	"github.com/cautro/morzelingo/internal/app"
	"github.com/cautro/morzelingo/internal/models"
	
	"github.com/gin-gonic/gin"
	"github.com/golang-jwt/jwt/v5"
	"golang.org/x/crypto/bcrypt"
)

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

type Lesson struct {
	ID          int
	Title       string
	Theory      string
	Symbols     []string
	XPReward    int
	Practice string
}

type Claims struct {
	Username string `json:"username"`
	jwt.RegisteredClaims
}

func readLessons(lang string) ([]Lesson, error) {
	filename := "lessons-EN.json"
	if lang == "ru" {
		filename = "lessons-RU.json"
	}
	b, err := os.ReadFile(filename)
	if err != nil {
		return nil, err
	}
	var lessons []Lesson
	if err := json.Unmarshal(b, &lessons); err != nil {
		return nil, err
	}
	return lessons, nil
}

func AuthMiddleware(a *app.App) gin.HandlerFunc {
	return func(c *gin.Context) {
		auth := c.GetHeader("Authorization")
		if auth == "" {
			c.JSON(http.StatusUnauthorized, gin.H{"error": "Authorization header missing"})
			c.Abort()
			return
		}
		parts := strings.Split(auth, " ")
		if len(parts) != 2 || parts[0] != "Bearer" {
			c.JSON(http.StatusUnauthorized, gin.H{"error": "Invalid Authorization header"})
			c.Abort()
			return
		}
		tokenStr := parts[1]
		claims := &Claims{}
		tok, err := jwt.ParseWithClaims(tokenStr, claims, func(t *jwt.Token) (interface{}, error) {
			if _, ok := t.Method.(*jwt.SigningMethodHMAC); !ok {
				return nil, fmt.Errorf("unexpected signing method")
			}
			return []byte(a.Secret), nil
		})
		if err != nil || !tok.Valid {
			c.JSON(http.StatusUnauthorized, gin.H{"error": "invalid or expired token"})
			c.Abort()
			return
		}
		c.Set("username", claims.Username)
		c.Next()
	}
}

func MakeRegisterHandler(a *app.App) gin.HandlerFunc {
	return func(c *gin.Context) {
		var in RegisterInput
		if err := c.ShouldBindJSON(&in); err != nil {
			c.JSON(http.StatusBadRequest, gin.H{"error": "invalid json"})
			return
		}
		in.Username = strings.TrimSpace(in.Username)
		in.Email = strings.TrimSpace(in.Email)
		in.Password = strings.TrimSpace(in.Password)
		if in.Username == "" || in.Password == "" {
			c.JSON(http.StatusBadRequest, gin.H{"error": "username/password required"})
			return
		}

		users := a.GetUsers()
		for _, u := range users {
			if u.Username == in.Username {
				c.JSON(http.StatusConflict, gin.H{"error": "username exists"})
				return
			}
			if u.Email == in.Email && in.Email != "" {
				c.JSON(http.StatusConflict, gin.H{"error": "email exists"})
				return
			}
		}

		hashed, err := bcrypt.GenerateFromPassword([]byte(in.Password), bcrypt.DefaultCost)
		if err != nil {
			c.JSON(http.StatusInternalServerError, gin.H{"error": "server error"})
			return
		}

		newUser := models.User{
			Username:    in.Username,
			Email:       in.Email,
			Password:    string(hashed),
			XP:          0,
			ReferralCode: generateReferralCode(users),
			Friends:     []string{},
			Items:       nil,
			SymbolStats: nil,
		}

		if in.ReferralInput != "" {
			_ = a.UpdateUser(newUser.Username, func(u *models.User) error { return nil })
			for i := range users {
				if users[i].ReferralCode == in.ReferralInput {
					_, _ = a.UpdateUser(users[i].Username, func(x *models.User) error {
						x.ReferralCount++
						x.Coins += 50
						x.Friends = append(x.Friends, newUser.Username)
						return nil
					})
					newUser.ReferredBy = users[i].Username
					newUser.Coins += 25
					break
				}
			}
		}

		toSave := a.AddUser(newUser)
		a.Saver.Schedule(toSave)

		c.JSON(http.StatusCreated, gin.H{"ok": true})
	}
}

func MakeLoginHandler(a *app.App) gin.HandlerFunc {
	return func(c *gin.Context) {
		var in LoginInput
		if err := c.ShouldBindJSON(&in); err != nil {
			c.JSON(http.StatusBadRequest, gin.H{"error": "invalid input"})
			return
		}
		users := a.GetUsers()
		var found *models.User
		for i := range users {
			if users[i].Username == in.Username {
				tmp := users[i] 
				found = &tmp
				break
			}
		}
		if found == nil {
			c.JSON(http.StatusUnauthorized, gin.H{"error": "invalid username or password"})
			return
		}
		if err := bcrypt.CompareHashAndPassword([]byte(found.Password), []byte(in.Password)); err != nil {
			c.JSON(http.StatusUnauthorized, gin.H{"error": "invalid username or password"})
			return
		}

		toSave, err := a.UpdateUser(found.Username, func(u *models.User) error {
			today := time.Now().UTC().Format("2006-01-02")
			yesterday := time.Now().UTC().AddDate(0, 0, -1).Format("2006-01-02")
			if u.LastLogin == today {
			} else if u.LastLogin == yesterday {
				u.Streak++
				u.LastLogin = today
			} else {
				u.Streak = 1
				u.LastLogin = today
			}
			if u.ReferralCode == "" {
				u.ReferralCode = generateReferralCode(a.GetUsers())
			}
			return nil
		})
		if err == nil {
			a.Saver.Schedule(toSave)
		}

		claims := Claims{
			Username: in.Username,
			RegisteredClaims: jwt.RegisteredClaims{
				ExpiresAt: jwt.NewNumericDate(time.Now().Add(24 * time.Hour)),
				IssuedAt:  jwt.NewNumericDate(time.Now()),
			},
		}
		tok := jwt.NewWithClaims(jwt.SigningMethodHS256, claims)
		signed, err := tok.SignedString([]byte(a.Secret))
		if err != nil {
			c.JSON(http.StatusInternalServerError, gin.H{"error": "could not generate token"})
			return
		}

		c.JSON(http.StatusOK, gin.H{"token": signed})
	}
}

func MakeListUsersHandler(a *app.App) gin.HandlerFunc {
	return func(c *gin.Context) {
		c.JSON(http.StatusOK, a.GetUsers())
	}
}

func MakeProfileHandler(a *app.App) gin.HandlerFunc {
	return func(c *gin.Context) {
		username := c.GetString("username")
		u, err := a.GetUserCopy(username)
		if err != nil {
			c.JSON(http.StatusNotFound, gin.H{"error": "user not found"})
			return
		}
		c.JSON(http.StatusOK, gin.H{
			"username":              u.Username,
			"email":                 u.Email,
			"xp":                    u.XP,
			"lesson_done_ru":        u.LessonDone_RU,
			"lesson_done_en":        u.LessonDone_EN,
			"level":                 u.Level,
			"coins":                 u.Coins,
			"items":                 u.Items,
			"streak":                u.Streak,
			"referral_code":         u.ReferralCode,
			"referred_by":           u.ReferredBy,
			"referred_count":        u.ReferralCount,
			"friends":               u.Friends,
			"symbol_stats":          u.SymbolStats,
			"need_xp":               u.NeedXp,
			"UnlockedAchievements":  u.UnlockedAchievements,
		})
	}
}

func MakeCompleteLessonHandler(a *app.App) gin.HandlerFunc {
	return func(c *gin.Context) {
		username := c.GetString("username")
		lang := c.DefaultQuery("lang", "en")
		var in struct {
			LessonID int `json:"lesson_id" binding:"required"`
		}
		if err := c.ShouldBindJSON(&in); err != nil {
			c.JSON(http.StatusBadRequest, gin.H{"error": "invalid input"})
			return
		}

		lessons, err := readLessons(lang)
		if err != nil {
			c.JSON(http.StatusInternalServerError, gin.H{"error": "failed to read lessons"})
			return
		}
		if in.LessonID <= 0 || in.LessonID > len(lessons) {
			c.JSON(http.StatusBadRequest, gin.H{"error": "invalid lesson id"})
			return
		}

		toSave, err := a.UpdateUser(username, func(u *models.User) error {
			var done int
			if lang == "ru" {
				done = u.LessonDone_RU
			} else {
				done = u.LessonDone_EN
			}
			if in.LessonID != done+1 {
				return fmt.Errorf("invalid lesson order")
			}

			u.XP += lessons[in.LessonID-1].XPReward
			if lang == "ru" {
				u.LessonDone_RU = done + 1
			} else {
				u.LessonDone_EN = done + 1
			}

			need := 1 + float64(u.Level)*1.5
			u.NeedXp = int(need * 100)
			if u.XP >= 100*int(need) {
				u.Level++
				u.XP = u.XP - 100*int(need)
			}

			mult := 1 + u.Level*2
			if mult > 100 {
				mult = 100
			}
			u.Coins += 10 * mult
			u.LastLogin = time.Now().Format("2006-01-02")
			u.Streak++
			return nil
		})
		if err != nil {
			if strings.Contains(err.Error(), "invalid lesson order") {
				c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
				return
			}
			c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
			return
		}

		a.Saver.Schedule(toSave)
		c.JSON(http.StatusOK, gin.H{"message": "lesson completed"})
	}
}

func MakeLessonsHandler(a *app.App) gin.HandlerFunc {
	return func(c *gin.Context) {
		lang := c.DefaultQuery("lang", "en")
		lessons, err := readLessons(lang)
		if err != nil {
			c.JSON(http.StatusInternalServerError, gin.H{"error": "failed to read lessons"})
			return
		}
		c.JSON(http.StatusOK, lessons)
	}
}

func MakeLessonByIDHandler(a *app.App) gin.HandlerFunc {
	return func(c *gin.Context) {
		lang := c.DefaultQuery("lang", "en")
		lessons, err := readLessons(lang)
		if err != nil {
			c.JSON(http.StatusInternalServerError, gin.H{"error": "failed to read lessons"})
			return
		}
		idStr := c.Param("id")
		for _, l := range lessons {
			if strconv.Itoa(l.ID) == idStr {
				c.JSON(http.StatusOK, l)
				return
			}
		}
		c.JSON(http.StatusNotFound, gin.H{"error": "lesson not found"})
	}
}

func MakePracticeByLessonHandler(a *app.App) gin.HandlerFunc {
	return func(c *gin.Context) {
		lang := c.DefaultQuery("lang", "en")
		username := c.GetString("username")
		idStr := c.Param("id")

		lessons, err := readLessons(lang)
		if err != nil {
			c.JSON(http.StatusInternalServerError, gin.H{"error": "failed to read lessons"})
			return
		}

		var selected *Lesson
		for i := range lessons {
			if strconv.Itoa(lessons[i].ID) == idStr {
				selected = &lessons[i]
				break
			}
		}
		if selected == nil {
			c.JSON(http.StatusNotFound, gin.H{"error": "lesson not found"})
			return
		}

		userCopy, err := a.GetUserCopy(username)
		if err != nil {
			c.JSON(http.StatusNotFound, gin.H{"error": "user not found"})
			return
		}

		hardSymbols := getHardSymbols(userCopy.SymbolStats)
		symbolSet := make(map[string]bool)
		for _, s := range selected.Symbols {
			symbolSet[s] = true
		}
		added := 0
		for _, s := range hardSymbols {
			if !symbolSet[s] && added < 3 {
				symbolSet[s] = true
				added++
			}
		}

		practiceSymbols := make([]string, 0, len(symbolSet))
		for s := range symbolSet {
			practiceSymbols = append(practiceSymbols, s)
		}

		types := []string{"text", "morse", "audio"}
		questions := make([]PracticeQuestion, 0, 20)
		for i := 0; i < 20; i++ {
			randomType := types[rand.Intn(len(types))]
			correctWord := weightedRandom(practiceSymbols, userCopy.SymbolStats)
			switch randomType {
			case "text":
				questions = append(questions, PracticeQuestion{Type: "text", Question: correctWord, Answer: correctWord})
			case "morse", "audio":
				questions = append(questions, PracticeQuestion{Type: randomType, Question: textToMorse(correctWord, lang), Answer: correctWord})
			}
		}
		c.JSON(http.StatusOK, PracticeResponse{Questions: questions})
	}
}

func MakeLettersPracticeHandler(a *app.App) gin.HandlerFunc {
	return func(c *gin.Context) {
		letters := c.Query("letters")
		lang := c.DefaultQuery("lang", "en")
		if lang == "ru" && strings.ContainsAny(letters, "ABCDEFGHIJKLMNOPQRSTUVWXYZ") {
			c.JSON(http.StatusBadRequest, gin.H{"error": "use russian letters for lang=ru"})
			return
		}
		types := []string{"text", "morse", "audio"}
		questions := make([]PracticeQuestion, 0, 20)
		for i := 0; i < 20; i++ {
			randomType := types[rand.Intn(len(types))]
			randomNumberOfSymbols := rand.Intn(3) + 1
			correctWord := generatePractice(strings.Split(letters, ""), randomNumberOfSymbols)
			switch randomType {
			case "text":
				questions = append(questions, PracticeQuestion{Type: "text", Question: correctWord})
			case "morse", "audio":
				questions = append(questions, PracticeQuestion{Type: randomType, Question: textToMorse(correctWord, lang)})
			}
		}
		c.JSON(http.StatusOK, PracticeResponse{Questions: questions})
	}
}

func MakePracticeSubmitHandler(a *app.App) gin.HandlerFunc {
	return func(c *gin.Context) {
		username := c.GetString("username")
		var updates []SymbolUpdate
		if err := c.ShouldBindJSON(&updates); err != nil {
			c.JSON(http.StatusBadRequest, gin.H{"error": "invalid input"})
			return
		}

		toSave, err := a.UpdateUser(username, func(u *models.User) error {
			for _, upd := range updates {
				found := false
				for j := range u.SymbolStats {
					if u.SymbolStats[j].Symbol == upd.Symbol {
						u.SymbolStats[j].Correct += upd.Correct
						u.SymbolStats[j].Wrong += upd.Wrong
						found = true
						break
					}
				}
				if !found {
					u.SymbolStats = append(u.SymbolStats, models.SymbolStat{
						Symbol:  upd.Symbol,
						Correct: upd.Correct,
						Wrong:   upd.Wrong,
					})
				}
			}
			u.XP += 1
			return nil
		})
		if err != nil {
			c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
			return
		}
		a.Saver.Schedule(toSave)
		c.JSON(http.StatusOK, gin.H{"message": "statistics updated"})
	}
}

func MakeFreemodeHandler(a *app.App) gin.HandlerFunc {
	return func(c *gin.Context) {
		lang := c.DefaultQuery("lang", "en")
		letters := c.DefaultQuery("letters", "")
		if letters == "" {
			c.JSON(http.StatusBadRequest, gin.H{"error": "letters query required"})
			return
		}
		countStr := c.DefaultQuery("count", "20")
		cnt, _ := strconv.Atoi(countStr)
		if cnt <= 0 {
			cnt = 20
		}
		questions := make([]PracticeQuestion, 0, cnt)
		for i := 0; i < cnt; i++ {
			randomNumberOfSymbols := rand.Intn(3) + 1
			word := generatePractice(strings.Split(letters, ""), randomNumberOfSymbols)
			questions = append(questions, PracticeQuestion{Type: "morse", Question: textToMorse(word, lang), Answer: word})
		}
		c.JSON(http.StatusOK, PracticeResponse{Questions: questions})
	}
}