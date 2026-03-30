package services

import (
	"testing"
	"github.com/cautro/morzelingo/internal/models"
)

func TestUserService_AddFriend_Success(t *testing.T) {
	users := newFakeUserRepo(
		models.User{Username: "alice"},
		models.User{Username: "bob"},
	)
	streaks := newFakeStreakRepo()
	svc := NewUserService(users, streaks)

	res, err := svc.AddFriend("alice", "bob")
	if err != nil {
		t.Fatalf("AddFriend() error = %v", err)
	}

	if !res.OK {
		t.Fatalf("expected OK=true")
	}

	alice, err := users.GetByUsername("alice")
	if err != nil {
		t.Fatalf("alice not found: %v", err)
	}
	bob, err := users.GetByUsername("bob")
	if err != nil {
		t.Fatalf("bob not found: %v", err)
	}

	if len(alice.Friends) != 1 || alice.Friends[0] != "bob" {
		t.Fatalf("alice friends = %#v, want [bob]", alice.Friends)
	}
	if len(bob.Friends) != 1 || bob.Friends[0] != "alice" {
		t.Fatalf("bob friends = %#v, want [alice]", bob.Friends)
	}

	allStreaks, err := streaks.List()
	if err != nil {
		t.Fatalf("streaks.List() error = %v", err)
	}
	if len(allStreaks) != 1 {
		t.Fatalf("expected 1 streak, got %d", len(allStreaks))
	}
}

func TestUserService_AddFriend_CannotAddYourself(t *testing.T) {
	users := newFakeUserRepo(models.User{Username: "alice"})
	streaks := newFakeStreakRepo()
	svc := NewUserService(users, streaks)

	_, err := svc.AddFriend("alice", "alice")
	if err != ErrCannotAddYourself {
		t.Fatalf("expected ErrCannotAddYourself, got %v", err)
	}
}

func TestUserService_DeleteFriend_Success(t *testing.T) {
	users := newFakeUserRepo(
		models.User{Username: "alice", Friends: []string{"bob"}},
		models.User{Username: "bob", Friends: []string{"alice"}},
	)
	streaks := newFakeStreakRepo()
	svc := NewUserService(users, streaks)

	res, err := svc.DeleteFriend("alice", "bob")
	if err != nil {
		t.Fatalf("DeleteFriend() error = %v", err)
	}
	if !res.OK {
		t.Fatalf("expected OK=true")
	}

	alice, _ := users.GetByUsername("alice")
	bob, _ := users.GetByUsername("bob")

	if len(alice.Friends) != 0 {
		t.Fatalf("expected alice friends to be empty, got %#v", alice.Friends)
	}
	if len(bob.Friends) != 0 {
		t.Fatalf("expected bob friends to be empty, got %#v", bob.Friends)
	}
}