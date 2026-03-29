package services

import (
	"math/rand"
	"strconv"
	"time"
)

func stringInt(v int) string {
	return strconv.Itoa(v)
}

func nowDate() string {
	return time.Now().Format("2006-01-02")
}

func randomInt(limit int) int {
	if limit <= 0 {
		return 0
	}

	return rand.Intn(limit)
}
