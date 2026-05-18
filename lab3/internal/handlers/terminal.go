package handlers

import (
	"net/http"

	"payment-auth-server/internal/database"
	"payment-auth-server/internal/models"

	"github.com/gin-gonic/gin"
)

// TerminalAuthorize godoc
// @Summary Авторизация транзакции терминалом
// @Tags Terminal
// @Accept json
// @Produce json
// @Security BearerAuth
// @Param request body models.TerminalAuthRequest true "Данные транзакции"
// @Success 200 {object} models.TerminalAuthResponse
// @Router /terminal/authorize [post]
func TerminalAuthorize(c *gin.Context) {
	var req models.TerminalAuthRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	// Проверка карты
	var card models.Card
	err := database.DB.QueryRow(
		"SELECT id, card_number, balance, is_locked FROM cards WHERE card_number = ?",
		req.CardNumber,
	).Scan(&card.ID, &card.CardNumber, &card.Balance, &card.IsLocked)

	if err != nil {
		c.JSON(http.StatusOK, models.TerminalAuthResponse{Authorized: false, Message: "card not found"})
		return
	}

	if card.IsLocked {
		c.JSON(http.StatusOK, models.TerminalAuthResponse{Authorized: false, Message: "card is locked"})
		return
	}

	if card.Balance < req.Amount {
		c.JSON(http.StatusOK, models.TerminalAuthResponse{Authorized: false, Message: "insufficient balance"})
		return
	}

	// Поиск терминала
	var terminalID int
	err = database.DB.QueryRow(
		"SELECT id FROM terminals WHERE serial_number = ?",
		req.TerminalSN,
	).Scan(&terminalID)

	if err != nil {
		c.JSON(http.StatusOK, models.TerminalAuthResponse{Authorized: false, Message: "terminal not found"})
		return
	}

	// Создаём транзакцию
	_, err = database.DB.Exec(
		"INSERT INTO transactions (amount, card_id, terminal_id) VALUES (?, ?, ?)",
		req.Amount, card.ID, terminalID,
	)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	// Списываем баланс
	_, err = database.DB.Exec(
		"UPDATE cards SET balance = balance - ? WHERE id = ?",
		req.Amount, card.ID,
	)

	c.JSON(http.StatusOK, models.TerminalAuthResponse{Authorized: true, Message: "approved"})
}

// GetKeysForTerminal godoc
// @Summary Загрузка ключей для терминала
// @Tags Terminal
// @Produce json
// @Security BearerAuth
// @Success 200 {array} models.Key
// @Router /terminal/keys [get]
func GetKeysForTerminal(c *gin.Context) {
	rows, err := database.DB.Query("SELECT id, key_value, description, created_at FROM keys")
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}
	defer rows.Close()

	var keys []models.Key
	for rows.Next() {
		var k models.Key
		if err := rows.Scan(&k.ID, &k.KeyValue, &k.Description, &k.CreatedAt); err != nil {
			c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
			return
		}
		keys = append(keys, k)
	}
	c.JSON(http.StatusOK, keys)
}
