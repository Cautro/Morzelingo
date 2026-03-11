package worker

import (
	"time"

	"github.com/cautro/morzelingo/internal/models"
	"github.com/cautro/morzelingo/internal/storage"
)

const DefaultDebounce = 1 * time.Second

type Saver struct {
	storage  *storage.Storage
	ch       chan []models.User
	quit     chan struct{}
	debounce time.Duration
	running  bool
}

func NewSaver(st *storage.Storage, debounce time.Duration) *Saver {
	return &Saver{
		storage:  st,
		ch:       make(chan []models.User, 1),
		quit:     make(chan struct{}),
		debounce: debounce,
	}
}

func (s *Saver) Start() {
	if s.running {
		return
	}
	s.running = true
	go s.loop()
}

func (s *Saver) Stop() {
	if !s.running {
		return
	}
	close(s.quit)
	s.running = false
}

func (s *Saver) Schedule(users []models.User) {
	select {
	case s.ch <- users:
	default:
		select {
		case <-s.ch:
		default:
		}
		s.ch <- users
	}
}

func (s *Saver) loop() {
	var pending []models.User
	timer := time.NewTimer(0)
	<-timer.C // drain
	timer.Stop()
	resetTimer := func(d time.Duration) {
		if !timer.Stop() {
			select {
			case <-timer.C:
			default:
			}
		}
		timer.Reset(d)
	}

	for {
		select {
		case u := <-s.ch:
			pending = u
			resetTimer(s.debounce)
		case <-timer.C:
			if pending != nil {
				_ = s.storage.SaveUsers(pending)
				pending = nil
			}
		case <-s.quit:
			if pending != nil {
				_ = s.storage.SaveUsers(pending)
			}
			return
		}
	}
}