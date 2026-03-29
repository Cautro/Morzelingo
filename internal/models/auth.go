package models

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