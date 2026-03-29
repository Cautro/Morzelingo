package services

import (
	"strings"
	"time"

	"github.com/cautro/morzelingo/internal/app"
	"github.com/cautro/morzelingo/internal/models"
	"github.com/cautro/morzelingo/internal/utils"
	"github.com/golang-jwt/jwt/v5"
	"golang.org/x/crypto/bcrypt"
)

type AuthService struct {
	app *app.App
}

type RegisterResult struct {
	OK    bool   `json:"ok"`
	Token string `json:"token"`
}

type LoginResult struct {
	Token string `json:"token"`
}

func NewAuthService(a *app.App) *AuthService {
	return &AuthService{app: a}
}

func (s *AuthService) Register(in models.RegisterInput) (RegisterResult, error) {
	in.Username = strings.TrimSpace(in.Username)
	in.Email = strings.TrimSpace(in.Email)
	in.Password = strings.TrimSpace(in.Password)

	if in.Username == "" || in.Password == "" {
		return RegisterResult{}, ErrUsernamePasswordRequired
	}

	if _, err := s.app.GetByUsername(in.Username); err == nil {
		return RegisterResult{}, ErrUsernameExists
	}

	users := s.app.ListUser()
	if in.Email != "" {
		for _, u := range users {
			if u.Email == in.Email {
				return RegisterResult{}, ErrEmailExists
			}
		}
	}

	hashed, err := bcrypt.GenerateFromPassword([]byte(in.Password), bcrypt.DefaultCost)
	if err != nil {
		return RegisterResult{}, err
	}

	newUser := models.User{
		Username:       in.Username,
		Email:          in.Email,
		Password:       string(hashed),
		XP:             0,
		ReferralCode:   utils.GenerateReferralCode(users),
		Friends:        []string{},
		Items:          nil,
		SymbolStats:    nil,
		RegisteredDate: time.Now().UTC().Format("2006-01-02"),
	}

	if in.ReferralInput != "" {
		for _, u := range s.app.ListUser() {
			if u.ReferralCode == in.ReferralInput {
				_, _ = s.app.UpdateUser(u.Username, func(x *models.User) error {
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

	toSave := s.app.CreateUser(newUser)
	s.app.Saver.Schedule(toSave)

	token, err := s.signToken(in.Username, 24*time.Hour)
	if err != nil {
		return RegisterResult{}, ErrTokenGeneration
	}

	return RegisterResult{OK: true, Token: token}, nil
}

func (s *AuthService) Login(in models.LoginInput) (LoginResult, error) {
	user, ok := s.app.GetUserRaw(in.Username)
	if !ok {
		return LoginResult{}, ErrInvalidCredentials
	}

	if err := bcrypt.CompareHashAndPassword([]byte(user.Password), []byte(in.Password)); err != nil {
		return LoginResult{}, ErrInvalidCredentials
	}

	toSave, err := s.app.UpdateUser(user.Username, func(u *models.User) error {
		today := time.Now().UTC().Format("2006-01-02")
		yesterday := time.Now().UTC().AddDate(0, 0, -1).Format("2006-01-02")

		if u.LastLogin == today {
			// no-op when user already logged in today
		} else if u.LastLogin == yesterday {
			u.Streak++
			u.LastLogin = today
		} else {
			u.Streak = 1
			u.LastLogin = today
		}

		if u.ReferralCode == "" {
			u.ReferralCode = utils.GenerateReferralCode(s.app.ListUser())
		}

		return nil
	})
	if err != nil {
		return LoginResult{}, err
	}

	s.app.Saver.Schedule(toSave)

	token, err := s.signToken(in.Username, 168*time.Hour)
	if err != nil {
		return LoginResult{}, ErrTokenGeneration
	}

	return LoginResult{Token: token}, nil
}

func (s *AuthService) signToken(username string, ttl time.Duration) (string, error) {
	claims := models.Claims{
		Username: username,
		RegisteredClaims: jwt.RegisteredClaims{
			ExpiresAt: jwt.NewNumericDate(time.Now().Add(ttl)),
			IssuedAt:  jwt.NewNumericDate(time.Now()),
		},
	}

	tok := jwt.NewWithClaims(jwt.SigningMethodHS256, claims)
	return tok.SignedString([]byte(s.app.Secret))
}
