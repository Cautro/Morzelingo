package handlers

import (
    "encoding/json"
    "math/rand"
    "math"
    "net/http"
    "os"
    "sync"
    "time"

    "github.com/cautro/morzelingo/internal/app"
    "github.com/cautro/morzelingo/internal/models"
    "github.com/gin-gonic/gin"
    "github.com/google/uuid"
)

var duelMu sync.Mutex

func readDuelLocked() ([]models.Duel, error) {
    b, err := os.ReadFile("data/duel.json")
    if err != nil {
        if os.IsNotExist(err) {
            return []models.Duel{}, nil
        }
        return nil, err
    }
    var duels []models.Duel
    if err := json.Unmarshal(b, &duels); err != nil {
        return nil, err
    }
    return duels, nil
}

func saveDuelLocked(duels []models.Duel) error {
    data, err := json.MarshalIndent(duels, "", "  ")
    if err != nil {
        return err
    }
    return os.WriteFile("data/duel.json", data, 0o644)
}

func withDuels(fn func(duels []models.Duel) ([]models.Duel, error)) error {
    duelMu.Lock()
    defer duelMu.Unlock()
    duels, err := readDuelLocked()
    if err != nil {
        return err
    }
    updated, err := fn(duels)
    if err != nil {
        return err
    }
    if updated != nil {
        return saveDuelLocked(updated)
    }
    return nil
}

// ─── Sentinel errors ─────────────────────────────────────────────────────────

var (
    errNotFound        = &sentinelErr{"not found"}
    errForbidden       = &sentinelErr{"forbidden"}
    errAlreadyFinished = &sentinelErr{"already finished"}
    errAlreadyDone     = &sentinelErr{"already done"}
    errNotActive       = &sentinelErr{"duel not active"}
)

type sentinelErr struct{ msg string }

func (e *sentinelErr) Error() string { return e.msg }

// ─── Helpers ─────────────────────────────────────────────────────────────────

func resultFor(username string, d *models.Duel) string {
    switch {
    case d.Winner == username:
        return "win"
    case d.Winner == "draw":
        return "draw"
    default:
        return "lose"
    }
}

func calcWinner(d *models.Duel) { 
    switch {
    case d.P1Score > d.P2Score:
        d.Winner = d.Player1
    case d.P2Score > d.P1Score:
        d.Winner = d.Player2
    default:
        d.Winner = "draw"
    }
}

func calcEloChange(myElo, opponentElo int, result string, myScore, oppScore int) int {

    expected := 1.0 / (1.0 + math.Pow(10, float64(opponentElo-myElo)/400.0))

    var actual float64
    switch result {
    case "win":
        actual = 1.0
    case "draw":
        actual = 0.5
    default: // lose
        actual = 0.0
    }

    K := 500.0

    scoreMult := 1.0
    total := myScore + oppScore
    if total > 0 && result == "win" {
        ratio := float64(myScore) / float64(total) // 0.5 .. 1.0
        scoreMult = 1.0 + ratio                     // 1.5 .. 2.0
    }

    change := K * (actual - expected) * scoreMult
    return int(math.Round(change))
}

// Обновлённый applyRewards
func applyRewards(a *app.App, duel *models.Duel, username string) {
    var myScore, oppScore int
    var opponentUsername string

    if duel.Player1 == username {
        myScore = duel.P1Score
        oppScore = duel.P2Score
        opponentUsername = duel.Player2
    } else {
        myScore = duel.P2Score
        oppScore = duel.P1Score
        opponentUsername = duel.Player1
    }

    opponent, err := a.GetUserCopy(opponentUsername)
    if err != nil {
        return
    }
    opponentElo := opponent.Elo

    // Обновляем рекорд
    user, err := a.GetUserCopy(username)
    if err != nil {
        return
    }
    if myScore > user.MaxScoreInDuel {
        toSave, err := a.UpdateUser(username, func(u *models.User) error {
            u.MaxScoreInDuel = myScore
            return nil
        })
        if err == nil {
            a.Saver.Schedule(toSave)
        }
        user.MaxScoreInDuel = myScore
    }

    result := resultFor(username, duel)
    eloChange := calcEloChange(user.Elo, opponentElo, result, myScore, oppScore)

    toSave, err := a.UpdateUser(username, func(u *models.User) error {
        mult := 1 + u.Level/3
        if mult < 1 {
            mult = 1
        }

        switch result {
        case "win":
            u.DuelsWin++
            u.XP += 50 * mult
            u.Coins += 100 * mult
            u.Elo = max(0, u.Elo+eloChange)
        case "draw":
            u.XP += 15 * mult
            u.Coins += 30 * mult
        default: // lose
            u.XP += 5 * mult
            u.Coins += 10 * mult
        }

        u.Elo = max(0, u.Elo+eloChange)
        return nil
    })
    if err == nil {
        a.Saver.Schedule(toSave)
    }
}

// ─── Matchmaking ─────────────────────────────────────────────────────────────

func MakeMatchmakeDuelHandler(a *app.App) gin.HandlerFunc {
    return func(c *gin.Context) {
        username := c.GetString("username")

        type Response struct {
            DuelID string `json:"duel_id"`
            Status string `json:"status"` // waiting | active
            Role   string `json:"role"`   // player1 | player2
        }

        var result Response

        err := withDuels(func(duels []models.Duel) ([]models.Duel, error) {
            for i := range duels {
                d := &duels[i]
                if d.Status != "waiting" {
                    continue
                }
                // Уже стоим в очереди — возвращаем свою же дуэль
                if d.Player1 == username {
                    result = Response{DuelID: d.ID, Status: "waiting", Role: "player1"}
                    return nil, nil
                }
                // Есть чужая — присоединяемся
                d.Player2 = username
                d.Status = "active"
                d.StartedAt = time.Now().UTC().Format(time.RFC3339)
                result = Response{DuelID: d.ID, Status: "active", Role: "player2"}
                return duels, nil
            }
            // Свободных нет — создаём
            nd := models.Duel{
                ID:        "duel_" + uuid.NewString(),
                Player1:   username,
                Status:    "waiting",
                CreatedAt: time.Now().UTC().Format(time.RFC3339),
            }
            result = Response{DuelID: nd.ID, Status: "waiting", Role: "player1"}
            return append(duels, nd), nil
        })

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

// ─── Tasks ───────────────────────────────────────────────────────────────────

func MakeGetTasksHandler(a *app.App) gin.HandlerFunc {
    return func(c *gin.Context) {
        username := c.GetString("username")
        lang := c.DefaultQuery("lang", "en")
        id := c.Param("id")

        user, ok := a.GetUserRaw(username)
        if !ok {
            c.JSON(http.StatusInternalServerError, gin.H{"error": "user not found"})
            return
        }

        var symbols, words, phrases []string
        switch lang {
        case "en":
            for k := range models.EnglishMorseDictionary {
                symbols = append(symbols, k)
            }
            words = models.EnglishWords
            phrases = models.EnglishPhrases
        case "ru":
            for k := range models.RussianMorseDictionary {
                symbols = append(symbols, k)
            }
            words = models.RussianWords
            phrases = models.RussianPhrases
        default:
            c.JSON(http.StatusBadRequest, gin.H{"error": "unsupported language"})
            return
        }

        var tasks models.PracticeResponse

        err := withDuels(func(duels []models.Duel) ([]models.Duel, error) {
            for i := range duels {
                if duels[i].ID != id {
                    continue
                }
                if duels[i].Player1 != username && duels[i].Player2 != username {
                    return nil, errForbidden
                }
                // Задания уже есть — отдаём кеш
                if len(duels[i].Tasks.Questions) > 0 {
                    tasks = duels[i].Tasks
                    return nil, nil
                }
                // Генерируем
                types := []string{"text", "morse", "audio"}
                questions := make([]models.PracticeQuestion, 0, 10)
                for j := 0; j < 10; j++ { // 10 вопросов вместо 5
                    correct := pickContent(user.Level, symbols, words, phrases)
                    if correct == "" {
                        continue
                    }
                    t := types[rand.Intn(len(types))]
                    switch t {
                    case "text":
                        questions = append(questions, models.PracticeQuestion{Type: "text", Question: correct})
                    default:
                        questions = append(questions, models.PracticeQuestion{Type: t, Question: textToMorse(correct, lang)})
                    }
                }
                duels[i].Tasks = models.PracticeResponse{Questions: questions}
                tasks = duels[i].Tasks
                return duels, nil
            }
            return nil, errNotFound
        })

        switch err {
        case nil:
            c.JSON(http.StatusOK, tasks)
        case errNotFound:
            c.JSON(http.StatusNotFound, gin.H{"error": "duel not found"})
        case errForbidden:
            c.JSON(http.StatusForbidden, gin.H{"error": "not your duel"})
        default:
            c.JSON(http.StatusInternalServerError, gin.H{"error": "server error"})
        }
    }
}

// ─── Score update (after EACH answer) ────────────────────────────────────────

func MakeUpdateScoreHandler(a *app.App) gin.HandlerFunc {
    return func(c *gin.Context) {
        id := c.Param("id")
        username := c.GetString("username")

        var in struct {
            Score int `json:"score"`
        }
        if err := c.BindJSON(&in); err != nil {
            c.JSON(http.StatusBadRequest, gin.H{"error": "invalid body"})
            return
        }

        type ScoreState struct {
            MyScore       int    `json:"my_score"`
            OpponentScore int    `json:"opponent_score"`
            OpponentDone  bool   `json:"opponent_done"`
            DuelStatus    string `json:"duel_status"`
        }
        var state ScoreState

        err := withDuels(func(duels []models.Duel) ([]models.Duel, error) {
            for i := range duels {
                d := &duels[i]
                if d.ID != id {
                    continue
                }
                if d.Status == "finished" || d.Status == "cancelled" {
                    return nil, errAlreadyFinished
                }
                if d.Status != "active" {
                    return nil, errNotActive
                }

                switch username {
                case d.Player1:
                    d.P1Score = in.Score
                    state = ScoreState{
                        MyScore:       d.P1Score,
                        OpponentScore: d.P2Score,
                        OpponentDone:  d.P2Done,
                        DuelStatus:    d.Status,
                    }
                case d.Player2:
                    d.P2Score = in.Score
                    state = ScoreState{
                        MyScore:       d.P2Score,
                        OpponentScore: d.P1Score,
                        OpponentDone:  d.P1Done,
                        DuelStatus:    d.Status,
                    }
                default:
                    return nil, errForbidden
                }

                return duels, nil
            }
            return nil, errNotFound
        })

        switch err {
        case nil:
            c.JSON(http.StatusOK, state)
        case errNotFound:
            c.JSON(http.StatusNotFound, gin.H{"error": "duel not found"})
        case errForbidden:
            c.JSON(http.StatusForbidden, gin.H{"error": "not your duel"})
        case errAlreadyFinished:
            c.JSON(http.StatusBadRequest, gin.H{"error": "duel already finished"})
        case errNotActive:
            c.JSON(http.StatusBadRequest, gin.H{"error": "duel not active yet"})
        default:
            c.JSON(http.StatusInternalServerError, gin.H{"error": "server error"})
        }
    }
}

// ─── Complete (player finished all questions) ─────────────────────────────────


func MakeCompleteDuelHandler(a *app.App) gin.HandlerFunc {
    return func(c *gin.Context) {
        id := c.Param("id")
        username := c.GetString("username")

        var in struct {
            Score int `json:"score"`
        }

        _ = c.ShouldBindJSON(&in)

        type Result struct {
            Result        string `json:"result"`          // win | lose | draw
            MyScore       int    `json:"my_score"`
            OpponentScore int    `json:"opponent_score"`
            Winner        string `json:"winner"`
            BothDone      bool   `json:"both_done"`       // оба закончили?
        }
        var result Result

        err := withDuels(func(duels []models.Duel) ([]models.Duel, error) {
            for i := range duels {
                d := &duels[i]
                if d.ID != id {
                    continue
                }

                // 1. Сначала проверяем участника
                isPlayer1 := d.Player1 == username
                isPlayer2 := d.Player2 == username
                if !isPlayer1 && !isPlayer2 {
                    return nil, errForbidden  // "not your duel"
                }

                // 2. Потом уже статус
                if d.Status == "cancelled" {
                    return nil, errAlreadyFinished
                }
                if d.Status == "finished" {
                    // дуэль завершена — значит игрок уже сдал
                    return nil, errAlreadyDone  // "already completed"
                }
                if d.Status != "active" {
                    return nil, errNotActive
                }

                // 3. Флаг done
                now := time.Now().UTC().Format(time.RFC3339)
                if isPlayer1 {
                    if d.P1Done {
                        return nil, errAlreadyDone
                    }
                    if in.Score > 0 {
                        d.P1Score = in.Score
                    }
                    d.P1Done = true
                    d.P1DoneAt = now
                } else {
                    if d.P2Done {
                        return nil, errAlreadyDone
                    }
                    if in.Score > 0 {
                        d.P2Score = in.Score
                    }
                    d.P2Done = true
                    d.P2DoneAt = now
                }


                
                bothDone := d.P1Done && d.P2Done
                if bothDone {
                    d.Status = "finished"
                    d.FinishedAt = now
                    calcWinner(d) 
                }

                var myScore, oppScore int
                if isPlayer1 {
                    myScore, oppScore = d.P1Score, d.P2Score
                } else {
                    myScore, oppScore = d.P2Score, d.P1Score
                }

                result = Result{
                    Result:        resultFor(username, d),
                    MyScore:       myScore,
                    OpponentScore: oppScore,
                    Winner:        d.Winner,
                    BothDone:      bothDone,
                }

                return duels, nil
            }
            return nil, errNotFound
        })

        switch err {
        case nil:
        case errNotFound:
            c.JSON(http.StatusNotFound, gin.H{"error": "duel not found"})
            return
        case errForbidden:
            c.JSON(http.StatusForbidden, gin.H{"error": "not your duel"})
            return
        case errAlreadyFinished:
            c.JSON(http.StatusBadRequest, gin.H{"error": "duel cancelled"})
            return
        case errAlreadyDone:
            c.JSON(http.StatusBadRequest, gin.H{"error": "already completed"})
            return
        case errNotActive:
            c.JSON(http.StatusBadRequest, gin.H{"error": "duel not active yet"})
            return
        default:
            c.JSON(http.StatusInternalServerError, gin.H{"error": "server error"})
            return
        }

        if result.BothDone {
            duelMu.Lock()
            duels, _ := readDuelLocked()
            duelMu.Unlock()
            for _, d := range duels {
                if d.ID == id {
                    applyRewards(a, &d, d.Player1)
                    applyRewards(a, &d, d.Player2)
                    break
                }
            }
        }
        c.JSON(http.StatusOK, result)
    }
}

// ─── Status / List ───────────────────────────────────────────────────────────

func MakeStatusDuelHandler(a *app.App) gin.HandlerFunc {
    return func(c *gin.Context) {
        id := c.Param("id")
        duelMu.Lock()
        defer duelMu.Unlock()
        duels, err := readDuelLocked()
        if err != nil {
            c.JSON(http.StatusInternalServerError, gin.H{"error": "failed to read duels"})
            return
        }
        for i := range duels {
            if duels[i].ID == id {
                c.JSON(http.StatusOK, duels[i])
                return
            }
        }
        c.JSON(http.StatusNotFound, gin.H{"error": "duel not found"})
    }
}

func MakeListDuelHandler(a *app.App) gin.HandlerFunc {
    return func(c *gin.Context) {
        duelMu.Lock()
        defer duelMu.Unlock()
        duels, err := readDuelLocked()
        if err != nil {
            c.JSON(http.StatusInternalServerError, gin.H{"error": "failed to read duels"})
            return
        }
        c.JSON(http.StatusOK, duels)
    }
}

// ─── Leave ───────────────────────────────────────────────────────────────────

func MakeLeaveDuelsHandler(a *app.App) gin.HandlerFunc {
    return func(c *gin.Context) {
        username := c.GetString("username")
        id := c.Param("id")

        err := withDuels(func(duels []models.Duel) ([]models.Duel, error) {
            for i := range duels {
                d := &duels[i]
                if d.ID != id {
                    continue
                }
                if d.Player1 != username && d.Player2 != username {
                    return nil, errForbidden
                }
                if d.Status == "finished" || d.Status == "cancelled" {
                    return nil, errAlreadyFinished
                }

                now := time.Now().UTC().Format(time.RFC3339)
                if d.Player1 == username {
                    d.Player1Left = true
                    if d.Player2 == "" {
                        d.Status = "cancelled"
                    } else {
                        d.Winner = d.Player2
                        d.Status = "finished"
                        d.FinishedAt = now
                    }
                } else {
                    d.Player2Left = true
                    d.Winner = d.Player1
                    d.Status = "finished"
                    d.FinishedAt = now
                }
                return duels, nil
            }
            return nil, errNotFound
        })

        switch err {
        case nil:
            c.JSON(http.StatusOK, gin.H{"ok": true, "message": "you left the duel"})
        case errNotFound:
            c.JSON(http.StatusNotFound, gin.H{"error": "duel not found"})
        case errForbidden:
            c.JSON(http.StatusForbidden, gin.H{"error": "you are not a participant"})
        case errAlreadyFinished:
            c.JSON(http.StatusBadRequest, gin.H{"error": "duel already finished"})
        default:
            c.JSON(http.StatusInternalServerError, gin.H{"error": "failed to save"})
        }
    }
}

// ─── Content helpers ─────────────────────────────────────────────────────────

func pickContent(level int, symbols, words, phrases []string) string {
    switch {
    case level <= 10 || len(words) == 0:
        if len(symbols) == 0 {
            return ""
        }
        return generatePractice(symbols, rand.Intn(3)+1)
    case level <= 20 || len(phrases) == 0:
        return words[rand.Intn(len(words))]
    default:
        return phrases[rand.Intn(len(phrases))]
    }
}