package services

import (
	"strings"
	"time"

	"github.com/cautro/morzelingo/internal/models"
	"github.com/cautro/morzelingo/internal/repo"
	"github.com/cautro/morzelingo/internal/utils"
	"github.com/golang-jwt/jwt/v5"
	"golang.org/x/crypto/bcrypt"
)

type AuthService struct {
	users     repo.UserRepository
	jwtSecret string
}

type RegisterResult struct {
	OK    bool   `json:"ok"`
	Token string `json:"token"`
}

type LoginResult struct {
	Token string `json:"token"`
}

func NewAuthService(users repo.UserRepository, jwtSecret string) *AuthService {
	return &AuthService{
		users:     users,
		jwtSecret: jwtSecret,
	}
}

func (s *AuthService) Register(in models.RegisterInput) (RegisterResult, error) {
	in.Username = strings.TrimSpace(in.Username)
	in.Email = strings.TrimSpace(in.Email)
	in.Password = strings.TrimSpace(in.Password)

	if in.Username == "" || in.Password == "" {
		return RegisterResult{}, ErrUsernamePasswordRequired
	}

	if _, err := s.users.GetByUsername(in.Username); err == nil {
		return RegisterResult{}, ErrUsernameExists
	}

	users := s.users.ListUser()
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
		for _, u := range s.users.ListUser() {
			if u.ReferralCode == in.ReferralInput {
				_, _ = s.users.UpdateUser(u.Username, func(x *models.User) error {
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

	if err := s.users.CreateUser(newUser); err != nil {
		return RegisterResult{}, err
	}

	token, err := s.signToken(in.Username, 24*time.Hour)
	if err != nil {
		return RegisterResult{}, ErrTokenGeneration
	}

	return RegisterResult{OK: true, Token: token}, nil
}

func (s *AuthService) Login(in models.LoginInput) (LoginResult, error) {
	user, ok := s.users.GetUserRaw(in.Username)
	if !ok {
		return LoginResult{}, ErrInvalidCredentials
	}

	if err := bcrypt.CompareHashAndPassword([]byte(user.Password), []byte(in.Password)); err != nil {
		return LoginResult{}, ErrInvalidCredentials
	}

	_, err := s.users.UpdateUser(user.Username, func(u *models.User) error {
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
			u.ReferralCode = utils.GenerateReferralCode(s.users.ListUser())
		}

		return nil
	})
	if err != nil {
		return LoginResult{}, err
	}

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
	return tok.SignedString([]byte(s.jwtSecret))
}
