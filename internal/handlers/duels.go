package handlers

// import (
// 	"encoding/json"

// 	"github.com/cautro/morzelingo/internal/app"
// 	"github.com/cautro/morzelingo/internal/models"
// 	"github.com/gin-gonic/gin"
// )

// func ReadDuel() ([]models.Duel, error) {
// 	filename := "data/duel.json"
// 	b, err := osReadFile(filename)
// 	if err != nil {
// 		return nil, err
// 	}
// 	var duels []models.Duel
// 	if err := json.Unmarshal(b, &duels); err != nil {
// 		return nil, err
// 	}
// 	return duels, nil
// }

// func MakeCreateDuelHandler(a *app.App) gin.HandlerFunc {
// 	return func (c *gin.Context)  {
		
// 	}
// }