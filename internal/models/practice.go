package models

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

type SymbolStat struct {
	Symbol  string `json:"symbol"`
	Correct int    `json:"correct"`
	Wrong   int    `json:"wrong"`
}