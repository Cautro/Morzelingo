package services

import "errors"

var (
	ErrUsernamePasswordRequired = errors.New("username/password required")
	ErrInvalidCredentials       = errors.New("invalid username or password")
	ErrTokenGeneration          = errors.New("could not generate token")

	ErrUserNotFound   = errors.New("user not found")
	ErrUsernameExists = errors.New("username exists")
	ErrEmailExists    = errors.New("email exists")

	ErrInvalidLessonID    = errors.New("invalid lesson id")
	ErrInvalidLessonOrder = errors.New("invalid lesson order")
	ErrLessonNotFound     = errors.New("lesson not found")

	ErrUnsupportedLanguage = errors.New("unsupported language")
	ErrUseRussianLetters   = errors.New("use russian letters for lang=ru")
	ErrNoSymbolsAvailable  = errors.New("no symbols available")

	ErrCannotAddYourself    = errors.New("cannot add yourself")
	ErrCannotDeleteYourself = errors.New("cannot delete yourself")
	ErrFriendNotFound       = errors.New("friend not found")

	ErrDuelNotFound        = errors.New("duel not found")
	ErrNotYourDuel         = errors.New("not your duel")
	ErrNotParticipant      = errors.New("you are not a participant")
	ErrDuelAlreadyFinished = errors.New("duel already finished")
	ErrDuelCancelled       = errors.New("duel cancelled")
	ErrAlreadyCompleted    = errors.New("already completed")
	ErrDuelNotActive       = errors.New("duel not active yet")
)
