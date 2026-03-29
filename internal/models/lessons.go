package models

type Lesson struct {
	ID       int      `json:"id"`
	Title    string   `json:"title"`
	Theory   string   `json:"theory"`
	Symbols  []string `json:"symbols"`
	XPReward int      `json:"xp_reward"`
	Practice string   `json:"practice"`
}