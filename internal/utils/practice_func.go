package utils

import (
	"math/rand"
	"strings"
	"github.com/cautro/morzelingo/internal/models"
)

func TextToMorse(text string, lang string) string {
	var dict map[string]string
	if lang == "ru" {
		dict = models.RussianMorseDictionary
	} else {
		dict = models.EnglishMorseDictionary
	}

	out := make([]string, 0, len(text))
	for _, ch := range text {
		upper := strings.ToUpper(string(ch))
		if m, ok := dict[upper]; ok {
			out = append(out, m)
		}
	}

	return strings.Join(out, " ")
}

func GeneratePractice(symbols []string, length int) string {
	if len(symbols) == 0 {
		return ""
	}

	sb := make([]string, length)
	for i := 0; i < length; i++ {
		sb[i] = symbols[rand.Intn(len(symbols))]
	}

	return strings.Join(sb, "")
}

func GetHardSymbols(stats []models.SymbolStat) []string {
	hard := make([]string, 0)
	for _, s := range stats {
		if s.Wrong >= 2 {
			hard = append(hard, s.Symbol)
		}
	}
	return hard
}

func WeightedRandom(symbols []string, stats []models.SymbolStat) string {
	if len(symbols) == 0 {
		return ""
	}

	weights := make([]int, len(symbols))
	total := 0

	for i, sym := range symbols {
		w := 10
		for _, st := range stats {
			if st.Symbol == sym {
				w = 10 + st.Wrong*5 - st.Correct*3
				break
			}
		}
		if w < 1 {
			w = 1
		}
		weights[i] = w
		total += w
	}

	r := rand.Intn(total)
	acc := 0
	for i, w := range weights {
		acc += w
		if r < acc {
			return symbols[i]
		}
	}

	return symbols[rand.Intn(len(symbols))]
}