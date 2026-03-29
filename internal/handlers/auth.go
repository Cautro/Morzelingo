package handlers

import (
	// "encoding/json"
	"fmt"
	"log"
	"math/rand"
	"net/http"
	// "os"
	// "path/filepath"
	"strconv"
	"strings"
	// "sync"
	"time"

	"github.com/cautro/morzelingo/internal/app"
	"github.com/cautro/morzelingo/internal/models"
	"github.com/gin-gonic/gin"
	"github.com/golang-jwt/jwt/v5"
	"golang.org/x/crypto/bcrypt"
)





func MakeRegisterHandler(a *app.App) gin.HandlerFunc {
	return func(c *gin.Context) {
		var in models.RegisterInput
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

		_, err := a.GetByUsername(in.Username); 
		if err != nil {
			c.JSON(http.StatusConflict, gin.H{"error": "username exists"})
			return
		}

		users := a.ListUser()

		if in.Email != "" {
			for _, u := range users {
				if u.Email == in.Email {
					c.JSON(http.StatusConflict, gin.H{"error": "email exists"})
					return
				}
			}
		}

		hashed, err := bcrypt.GenerateFromPassword([]byte(in.Password), bcrypt.DefaultCost)
		if err != nil {
			c.JSON(http.StatusInternalServerError, gin.H{"error": "server error"})
			return
		}

		newUser := models.User{
			Username:       in.Username,
			Email:          in.Email,
			Password:       string(hashed),
			XP:             0,
			ReferralCode:   generateReferralCode(users),
			Friends:        []string{},
			Items:          nil,
			SymbolStats:    nil,
			RegisteredDate: time.Now().UTC().Format("2006-01-02"),
		}

		if in.ReferralInput != "" {
			for _, u := range a.ListUser() {
				if u.ReferralCode == in.ReferralInput {
					_, _ = a.UpdateUser(u.Username, func(x *models.User) error {
						x.ReferralCount++
						x.Coins += 50

						alreadyFriend := false
						for _, f := range x.Friends {
							if f == newUser.Username {
								alreadyFriend = true
								break
							}
						}
						if !alreadyFriend {
							x.Friends = append(x.Friends, newUser.Username)
						}
						return nil
					})

					newUser.ReferredBy = u.Username
					newUser.Coins += 25
					break
				}
			}
		}

		toSave := a.CreateUser(newUser)
		a.Saver.Schedule(toSave)

		claims := models.Claims{
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

		c.JSON(http.StatusCreated, gin.H{"ok": true, "token": signed})
	}
}

func MakeLoginHandler(a *app.App) gin.HandlerFunc {
	return func(c *gin.Context) {
		var in models.LoginInput
		if err := c.ShouldBindJSON(&in); err != nil {
			c.JSON(http.StatusBadRequest, gin.H{"error": "invalid input"})
			return
		}

		user, ok := a.GetUserRaw(in.Username)
		if !ok {
			c.JSON(http.StatusUnauthorized, gin.H{"error": "invalid username or password"})
			return
		}

		if err := bcrypt.CompareHashAndPassword([]byte(user.Password), []byte(in.Password)); err != nil {
			c.JSON(http.StatusUnauthorized, gin.H{"error": "invalid username or password"})
			return
		}

		toSave, err := a.UpdateUser(user.Username, func(u *models.User) error {
			today := time.Now().UTC().Format("2006-01-02")
			yesterday := time.Now().UTC().AddDate(0, 0, -1).Format("2006-01-02")

			if u.LastLogin == today {
				// ничего не меняем
			} else if u.LastLogin == yesterday {
				u.Streak++
				u.LastLogin = today
			} else {
				u.Streak = 1
				u.LastLogin = today
			}

			if u.ReferralCode == "" {
				u.ReferralCode = generateReferralCode(a.ListUser())
			}

			return nil
		})

		a.Saver.Schedule(toSave)

		claims := models.Claims{
			Username: in.Username,
			RegisteredClaims: jwt.RegisteredClaims{
				ExpiresAt: jwt.NewNumericDate(time.Now().Add(168 * time.Hour)),
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
		c.JSON(http.StatusOK, a.ListUser())
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
			"username":             u.Username,
			"email":                u.Email,
			"xp":                   u.XP,
			"lesson_done_ru":       u.LessonDone_RU,
			"lesson_done_en":       u.LessonDone_EN,
			"level":                u.Level,
			"coins":                u.Coins,
			"items":                u.Items,
			"streak":               u.Streak,
			"referral_code":        u.ReferralCode,
			"referred_by":          u.ReferredBy,
			"referred_count":       u.ReferralCount,
			"friends":              u.Friends,
			"symbol_stats":         u.SymbolStats,
			"need_xp":              u.NeedXp,
			"UnlockedAchievements": u.UnlockedAchievements,
			"registred_date":       u.RegisteredDate,
			"LastLogin":            u.LastLogin,
			"elo":                  u.Elo,
			"max_score":            u.MaxScoreInDuel,
			"duelswin":             u.DuelsWin,
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

			if u.XP >= u.NeedXp {
				u.Level++
				u.XP -= u.NeedXp
			}

			mult := 1 + u.Level*2
			if mult > 100 {
				mult = 100
			}

			u.Coins += 10 * mult
			u.LastLogin = time.Now().Format("2006-01-02")
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

		var updated models.User
		for _, u := range toSave {
			if u.Username == username {
				updated = u
				break
			}
		}

		a.Saver.Schedule(toSave)

		c.JSON(http.StatusOK, gin.H{
			"message":        "lesson completed",
			"lesson_done_EN": updated.LessonDone_EN,
			"lesson_done_RU": updated.LessonDone_RU,
			"streak":         updated.Streak,
			"last_login":     updated.LastLogin,
			"xp":             updated.XP,
			"level":          updated.Level,
			"coins":          updated.Coins,
		})
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

		var selected *models.Lesson
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

		if len(practiceSymbols) == 0 {
			practiceSymbols = selected.Symbols
		}

		types := []string{"text", "morse", "audio"}
		questions := make([]models.PracticeQuestion, 0, 20)

		for i := 0; i < 20; i++ {
			randomType := types[rand.Intn(len(types))]
			correctWord := weightedRandom(practiceSymbols, userCopy.SymbolStats)

			switch randomType {
			case "text":
				questions = append(questions, models.PracticeQuestion{
					Type:     "text",
					Question: correctWord,
					Answer:   correctWord,
				})
			case "morse", "audio":
				questions = append(questions, models.PracticeQuestion{
					Type:     randomType,
					Question: textToMorse(correctWord, lang),
					Answer:   correctWord,
				})
			}
		}

		c.JSON(http.StatusOK, models.PracticeResponse{Questions: questions})
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
		questions := make([]models.PracticeQuestion, 0, 20)

		symbols := []string{}
		if letters != "" {
			symbols = strings.Split(letters, "")
		}

		for i := 0; i < 20; i++ {
			randomType := types[rand.Intn(len(types))]
			randomNumberOfSymbols := rand.Intn(3) + 1
			correctWord := GeneratePractice(symbols, randomNumberOfSymbols)

			switch randomType {
			case "text":
				questions = append(questions, models.PracticeQuestion{
					Type:     "text",
					Question: correctWord,
				})
			case "morse", "audio":
				questions = append(questions, models.PracticeQuestion{
					Type:     randomType,
					Question: textToMorse(correctWord, lang),
				})
			}
		}

		c.JSON(http.StatusOK, models.PracticeResponse{Questions: questions})
	}
}

func MakePracticeSubmitHandler(a *app.App) gin.HandlerFunc {
	return func(c *gin.Context) {
		username := c.GetString("username")

		var updates []models.SymbolUpdate
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
		mode := c.DefaultQuery("mode", "text")
		countStr := c.DefaultQuery("count", "20")

		cnt, _ := strconv.Atoi(countStr)
		if cnt <= 0 {
			cnt = 20
		}

		username := c.GetString("username")
		user, _ := a.GetUserCopy(username)

		var symbolPool []string

		if letters != "" {
			for _, r := range letters {
				symbolPool = append(symbolPool, string(r))
			}
		} else {
			if lang == "ru" {
				for k := range models.RussianMorseDictionary {
					symbolPool = append(symbolPool, k)
				}
			} else {
				for k := range models.EnglishMorseDictionary {
					if len(k) == 1 {
						symbolPool = append(symbolPool, k)
					}
				}
			}
		}

		if len(symbolPool) == 0 {
			c.JSON(http.StatusBadRequest, gin.H{"error": "no symbols available"})
			return
		}

		questions := make([]models.PracticeQuestion, 0, cnt)

		for i := 0; i < cnt; i++ {
			if user.Level <= 10 {
				switch mode {
				case "text":
					n := 1 + rand.Intn(2)
					word := GeneratePractice(symbolPool, n)
					questions = append(questions, models.PracticeQuestion{Type: "text", Question: word, Answer: word})
				case "morse":
					n := 1 + rand.Intn(2)
					word := GeneratePractice(symbolPool, n)
					questions = append(questions, models.PracticeQuestion{Type: "morse", Question: textToMorse(word, lang), Answer: word})
				case "audio":
					n := 1 + rand.Intn(2)
					word := GeneratePractice(symbolPool, n)
					questions = append(questions, models.PracticeQuestion{Type: "audio", Question: textToMorse(word, lang), Answer: word})
				}
			} else if user.Level <= 20 {
				switch mode {
				case "text":
					n := 2 + rand.Intn(4)
					word := GeneratePractice(symbolPool, n)
					questions = append(questions, models.PracticeQuestion{Type: "text", Question: word, Answer: word})
				case "morse":
					n := 2 + rand.Intn(4)
					word := GeneratePractice(symbolPool, n)
					questions = append(questions, models.PracticeQuestion{Type: "morse", Question: textToMorse(word, lang), Answer: word})
				case "audio":
					n := 2 + rand.Intn(4)
					word := GeneratePractice(symbolPool, n)
					questions = append(questions, models.PracticeQuestion{Type: "audio", Question: textToMorse(word, lang), Answer: word})
				}
			} else {
				switch mode {
				case "text":
					wordsCount := 2 + rand.Intn(3)
					parts := make([]string, 0, wordsCount)
					for w := 0; w < wordsCount; w++ {
						n := 2 + rand.Intn(4)
						parts = append(parts, GeneratePractice(symbolPool, n))
					}
					sentence := strings.Join(parts, " ")
					questions = append(questions, models.PracticeQuestion{Type: "text", Question: sentence, Answer: sentence})

				case "morse":
					wordsCount := 2 + rand.Intn(3)
					parts := make([]string, 0, wordsCount)
					for w := 0; w < wordsCount; w++ {
						n := 2 + rand.Intn(4)
						parts = append(parts, GeneratePractice(symbolPool, n))
					}
					sentence := strings.Join(parts, " ")
					questions = append(questions, models.PracticeQuestion{Type: "morse", Question: textToMorse(sentence, lang), Answer: sentence})

				case "audio":
					wordsCount := 2 + rand.Intn(3)
					parts := make([]string, 0, wordsCount)
					for w := 0; w < wordsCount; w++ {
						n := 2 + rand.Intn(4)
						parts = append(parts, GeneratePractice(symbolPool, n))
					}
					sentence := strings.Join(parts, " ")
					questions = append(questions, models.PracticeQuestion{Type: "audio", Question: textToMorse(sentence, lang), Answer: sentence})
				}
			}
		}

		c.JSON(http.StatusOK, models.PracticeResponse{Questions: questions})
	}
}

func MakeListFriendHandler(a *app.App) gin.HandlerFunc {
	return func(c *gin.Context) {
		username := c.GetString("username")

		u, err := a.GetUserCopy(username)
		if err != nil {
			c.JSON(http.StatusNotFound, gin.H{"error": "user not found"})
			return
		}

		c.JSON(http.StatusOK, gin.H{"friends": u.Friends})
	}
}

func MakeAddFriendHandler(a *app.App) gin.HandlerFunc {
	return func(c *gin.Context) {
		username := c.GetString("username")

		var body struct {
			Friend string `json:"friend" binding:"required"`
		}
		if err := c.ShouldBindJSON(&body); err != nil {
			c.JSON(http.StatusBadRequest, gin.H{"error": "friend required"})
			return
		}

		friend := body.Friend
		if friend == username {
			c.JSON(http.StatusBadRequest, gin.H{"error": "cannot add yourself"})
			return
		}

		_, err := a.GetByUsername(username); 
		if err != nil {
			c.JSON(http.StatusConflict, gin.H{"error": "username exists"})
			return
		}

		toSave, err := a.UpdateUser(username, func(u *models.User) error {
			for _, f := range u.Friends {
				if f == friend {
					return nil
				}
			}
			u.Friends = append(u.Friends, friend)
			return nil
		})
		if err != nil {
			c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
			return
		}

		toSave, err = a.UpdateUser(friend, func(u *models.User) error {
			for _, f := range u.Friends {
				if f == username {
					return nil
				}
			}
			u.Friends = append(u.Friends, username)
			return nil
		})
		if err != nil {
			c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
			return
		}

		a.Saver.Schedule(toSave)

		if err := touchFriendshipStreak(username, friend); err != nil {
			log.Printf("warning: friendship streak update failed: %v", err)
		}

		var u models.User
		for _, up := range toSave {
			if up.Username == username {
				u = up
				break
			}
		}

		c.JSON(http.StatusOK, gin.H{
			"ok":         true,
			"friends_of": username,
			"friends":    u.Friends,
		})
	}
}

func MakeUpdateStreakHandler(a *app.App) gin.HandlerFunc {
	return func(c *gin.Context) {
		username := c.GetString("username")

		if err := updateAllFriendshipStreaks(a, username); err != nil {
			c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
			return
		}

		c.JSON(http.StatusOK, gin.H{"ok": true})
	}
}

func MakeFriendShipStreakHandler(a *app.App) gin.HandlerFunc {
	return func(c *gin.Context) {
		meOnly := c.DefaultQuery("me", "false")
		username := c.GetString("username")

		streaks, err := readFriendshipStreaks()
		if err != nil {
			c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
			return
		}

		if meOnly == "true" {
			filter := make([]models.FriendshipStreak, 0)
			for _, s := range streaks {
				if s.User1 == username || s.User2 == username {
					filter = append(filter, s)
				}
			}
			c.JSON(http.StatusOK, filter)
			return
		}

		c.JSON(http.StatusOK, streaks)
	}
}

func MakeDeleteFriendHandler(a *app.App) gin.HandlerFunc {
	return func(c *gin.Context) {
		username := c.GetString("username")

		var body struct {
			Friend string `json:"friend" binding:"required"`
		}
		if err := c.ShouldBindJSON(&body); err != nil {
			c.JSON(http.StatusBadRequest, gin.H{"error": "friend required"})
			return
		}

		friend := body.Friend
		if friend == username {
			c.JSON(http.StatusBadRequest, gin.H{"error": "cannot add yourself"})
			return
		}

		_, err := a.GetByUsername(username); 
		if err != nil {
			c.JSON(http.StatusConflict, gin.H{"error": "username exists"})
			return
		}

		toSave, err := a.UpdateUser(username, func(u *models.User) error {
			u.Friends = removeFriend(u.Friends, friend)
			return nil
		})
		if err != nil {
			c.JSON(http.StatusInternalServerError, gin.H{"error": "failed to update"})
			return
		}

		toSave, err = a.UpdateUser(friend, func(u *models.User) error {
			u.Friends = removeFriend(u.Friends, username)
			return nil
		})
		if err != nil {
			c.JSON(http.StatusInternalServerError, gin.H{"error": "failed to update"})
			return
		}

		a.Saver.Schedule(toSave)

		var u models.User
		for _, up := range toSave {
			if up.Username == username {
				u = up
				break
			}
		}

		c.JSON(http.StatusOK, gin.H{
			"ok":         true,
			"friends_of": username,
			"friends":    u.Friends,
			"message":    "friend deleted",
		})
	}
}

func MakeReplayLessonHandler(a *app.App) gin.HandlerFunc {
	return func(c *gin.Context) {
		lang := c.DefaultQuery("lang", "en")
		idStr := c.Param("id")

		lessons, err := readLessons(lang)
		if err != nil {
			c.JSON(http.StatusInternalServerError, gin.H{"error": "failed to read lessons"})
			return
		}

		var selected *models.Lesson
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

		types := []string{"text", "morse", "audio"}
		questions := make([]models.PracticeQuestion, 0, 20)
		symbols := selected.Symbols

		for i := 0; i < 20; i++ {
			randomType := types[rand.Intn(len(types))]
			randomNumberOfSymbols := rand.Intn(3) + 1
			correctWord := GeneratePractice(symbols, randomNumberOfSymbols)

			switch randomType {
			case "text":
				questions = append(questions, models.PracticeQuestion{Type: "text", Question: correctWord})
			case "morse", "audio":
				questions = append(questions, models.PracticeQuestion{Type: randomType, Question: textToMorse(correctWord, lang)})
			}
		}

		c.JSON(http.StatusOK, models.PracticeResponse{Questions: questions})
	}
}