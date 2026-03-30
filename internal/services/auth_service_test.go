package services

import (
	"testing"

	"github.com/cautro/morzelingo/internal/models"
	"golang.org/x/crypto/bcrypt"
)

func TestAuthService_Register_Success(t *testing.T) {
	users := newFakeUserRepo()
	svc := NewAuthService(users, "test-secret")

	res, err := svc.Register(models.RegisterInput{
		Username: "tester",
		Email:    "tester@example.com",
		Password: "123456",
	})
	if err != nil {
		t.Fatalf("Register() error = %v", err)
	}

	if !res.OK {
		t.Fatalf("expected OK=true")
	}
	if res.Token == "" {
		t.Fatalf("expected token to be non-empty")
	}

	created, err := users.GetByUsername("tester")
	if err != nil {
		t.Fatalf("user was not created: %v", err)
	}

	if created.Password == "" {
		t.Fatalf("expected hashed password")
	}
	if created.Password == "123456" {
		t.Fatalf("password must not be stored as plain text")
	}

	if err := bcrypt.CompareHashAndPassword([]byte(created.Password), []byte("123456")); err != nil {
		t.Fatalf("stored password is not a valid bcrypt hash: %v", err)
	}
}

func TestAuthService_Register_DuplicateUsername(t *testing.T) {
	users := newFakeUserRepo(models.User{
		Username: "tester",
		Email:    "old@example.com",
	})
	svc := NewAuthService(users, "test-secret")

	_, err := svc.Register(models.RegisterInput{
		Username: "tester",
		Email:    "new@example.com",
		Password: "123456",
	})
	if err != ErrUsernameExists {
		t.Fatalf("expected ErrUsernameExists, got %v", err)
	}
}

func TestAuthService_Register_EmptyUsernameOrPassword(t *testing.T) {
	users := newFakeUserRepo()
	svc := NewAuthService(users, "test-secret")

	_, err := svc.Register(models.RegisterInput{
		Username: "",
		Password: "",
	})
	if err != ErrUsernamePasswordRequired {
		t.Fatalf("expected ErrUsernamePasswordRequired, got %v", err)
	}
}

func TestAuthService_Login_WrongPassword(t *testing.T) {
	hash, err := bcrypt.GenerateFromPassword([]byte("correct-password"), bcrypt.DefaultCost)
	if err != nil {
		t.Fatalf("bcrypt error: %v", err)
	}

	users := newFakeUserRepo(models.User{
		Username: "tester",
		Password: string(hash),
	})
	svc := NewAuthService(users, "test-secret")

	_, err = svc.Login(models.LoginInput{
		Username: "tester",
		Password: "wrong-password",
	})
	if err != ErrInvalidCredentials {
		t.Fatalf("expected ErrInvalidCredentials, got %v", err)
	}
}