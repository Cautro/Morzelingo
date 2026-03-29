package models

type Duel struct {
    ID      string `json:"id"`
    Player1 string `json:"player1"`
    Player2 string `json:"player2"`
    Status  string `json:"status"` // waiting | active | finished | cancelled

    Tasks PracticeResponse `json:"tasks"`

    // Текущие очки — обновляются после каждого ответа
    P1Score int `json:"p1_score"`
    P2Score int `json:"p2_score"`

    // Игрок ответил на все вопросы
    P1Done bool `json:"p1_done"`
    P2Done bool `json:"p2_done"`

    // Когда именно завершил (для отображения на фронте)
    P1DoneAt string `json:"p1_done_at,omitempty"`
    P2DoneAt string `json:"p2_done_at,omitempty"`

    Winner string `json:"winner"`

    CreatedAt   string `json:"created_at"`
    StartedAt   string `json:"started_at,omitempty"`
    FinishedAt  string `json:"finished_at,omitempty"`

    Player1Left bool `json:"player1_left,omitempty"`
    Player2Left bool `json:"player2_left,omitempty"`
}

type MorseTask struct {
    Morse string `json:"morse"`
    Answer string `json:"answer"`
}

type FinishScore struct {
	Score int `json:"score"`
}
