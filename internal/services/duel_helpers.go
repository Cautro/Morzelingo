package services

import (
	"math"
	"math/rand"

	"github.com/cautro/morzelingo/internal/app"
    "github.com/cautro/morzelingo/internal/handlers"
	"github.com/cautro/morzelingo/internal/models"
)

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

func pickContent(level int, symbols, words, phrases []string) string {
    switch {
    case level <= 10 || len(words) == 0:
        if len(symbols) == 0 {
            return ""
        }
        return handlers.GeneratePractice(symbols, rand.Intn(3)+1)
    case level <= 20 || len(phrases) == 0:
        return words[rand.Intn(len(words))]
    default:
        return phrases[rand.Intn(len(phrases))]
    }
}