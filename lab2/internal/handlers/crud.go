package handlers

import (
	"net/http"
	"strconv"

	"payment-auth-server/internal/database"
	"payment-auth-server/internal/models"

	"github.com/gin-gonic/gin"
)

// --- Terminals ---

// GetTerminals godoc
// @Summary Получить список терминалов
// @Tags Terminals
// @Produce json
// @Security BearerAuth
// @Success 200 {array} models.Terminal
// @Router /terminals [get]
func GetTerminals(c *gin.Context) {
	rows, _ := database.DB.Query("SELECT * FROM terminals")
	defer rows.Close()
	var list []models.Terminal
	for rows.Next() {
		var t models.Terminal
		rows.Scan(&t.ID, &t.SerialNumber, &t.Address, &t.Name, &t.CreatedAt)
		list = append(list, t)
	}
	c.JSON(http.StatusOK, list)
}

// GetTerminalByID godoc
// @Summary Получить терминал по ID
// @Tags Terminals
// @Produce json
// @Security BearerAuth
// @Param id path int true "ID терминала"
// @Success 200 {object} models.Terminal
// @Failure 404 {object} map[string]string
// @Router /terminals/{id} [get]
func GetTerminalByID(c *gin.Context) {
	id := c.Param("id")

	var t models.Terminal
	err := database.DB.QueryRow(
		"SELECT id, serial_number, address, name, created_at FROM terminals WHERE id = ?",
		id,
	).Scan(&t.ID, &t.SerialNumber, &t.Address, &t.Name, &t.CreatedAt)

	if err != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "terminal not found"})
		return
	}

	c.JSON(http.StatusOK, t)
}

// CreateTerminal godoc
// @Summary Создать терминал
// @Tags Terminals
// @Accept json
// @Produce json
// @Security BearerAuth
// @Param request body models.Terminal true "Данные терминала"
// @Success 201 {object} models.Terminal
// @Router /terminals [post]
func CreateTerminal(c *gin.Context) {
	var t models.Terminal
	c.ShouldBindJSON(&t)
	res, _ := database.DB.Exec("INSERT INTO terminals (serial_number, address, name) VALUES (?, ?, ?)", t.SerialNumber, t.Address, t.Name)
	id, _ := res.LastInsertId()
	t.ID = int(id)
	c.JSON(http.StatusCreated, t)
}

// UpdateTerminal godoc
// @Summary Обновить терминал
// @Tags Terminals
// @Accept json
// @Produce json
// @Security BearerAuth
// @Param id path int true "ID терминала"
// @Param request body models.Terminal true "Данные терминала"
// @Success 200 {object} models.Terminal
// @Router /terminals/{id} [put]
func UpdateTerminal(c *gin.Context) {
	id := c.Param("id")
	var t models.Terminal
	if err := c.ShouldBindJSON(&t); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	_, err := database.DB.Exec(
		"UPDATE terminals SET serial_number = ?, address = ?, name = ? WHERE id = ?",
		t.SerialNumber, t.Address, t.Name, id,
	)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}
	t.ID, _ = strconv.Atoi(id)
	c.JSON(http.StatusOK, t)
}

// DeleteTerminal godoc
// @Summary Удалить терминал
// @Tags Terminals
// @Security BearerAuth
// @Param id path int true "ID терминала"
// @Success 200 {object} map[string]string
// @Router /terminals/{id} [delete]
func DeleteTerminal(c *gin.Context) {
	id := c.Param("id")
	_, err := database.DB.Exec("DELETE FROM terminals WHERE id = ?", id)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}
	c.JSON(http.StatusOK, gin.H{"message": "terminal deleted"})
}

// --- Cards ---

// GetCards godoc
// @Summary Получить список карт
// @Tags Cards
// @Produce json
// @Security BearerAuth
// @Success 200 {array} models.Card
// @Router /cards [get]
func GetCards(c *gin.Context) {
	rows, _ := database.DB.Query("SELECT * FROM cards")
	defer rows.Close()
	var list []models.Card
	for rows.Next() {
		var t models.Card
		rows.Scan(&t.ID, &t.CardNumber, &t.Balance, &t.IsLocked, &t.OwnerName, &t.KeyID, &t.CreatedAt)
		list = append(list, t)
	}
	c.JSON(http.StatusOK, list)
}

// GetCardByID godoc
// @Summary Получить карту по ID
// @Tags Cards
// @Produce json
// @Security BearerAuth
// @Param id path int true "ID карты"
// @Success 200 {object} models.Card
// @Failure 404 {object} map[string]string
// @Router /cards/{id} [get]
func GetCardByID(c *gin.Context) {
	id := c.Param("id")

	var t models.Card
	err := database.DB.QueryRow(
		"SELECT id, card_number, balance, is_locked, owner_name, key_id, created_at FROM cards WHERE id = ?",
		id,
	).Scan(&t.ID, &t.CardNumber, &t.Balance, &t.IsLocked, &t.OwnerName, &t.KeyID, &t.CreatedAt)

	if err != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "card not found"})
		return
	}

	c.JSON(http.StatusOK, t)
}

// CreateCard godoc
// @Summary Создать карту
// @Tags Cards
// @Accept json
// @Produce json
// @Security BearerAuth
// @Param request body models.Card true "Данные карты"
// @Success 201 {object} models.Card
// @Router /cards [post]
func CreateCard(c *gin.Context) {
	var t models.Card
	c.ShouldBindJSON(&t)
	res, _ := database.DB.Exec("INSERT INTO cards (card_number, balance, is_locked, owner_name, key_id) VALUES (?, ?, ?, ?, ?)", t.CardNumber, t.Balance, t.IsLocked, t.OwnerName, t.KeyID)
	id, _ := res.LastInsertId()
	t.ID = int(id)
	c.JSON(http.StatusCreated, t)
}

// UpdateCard godoc
// @Summary Обновить карту
// @Tags Cards
// @Accept json
// @Produce json
// @Security BearerAuth
// @Param id path int true "ID карты"
// @Param request body models.Card true "Данные карты"
// @Success 200 {object} models.Card
// @Router /cards/{id} [put]
func UpdateCard(c *gin.Context) {
	id := c.Param("id")
	var t models.Card
	if err := c.ShouldBindJSON(&t); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	_, err := database.DB.Exec(
		"UPDATE cards SET card_number = ?, balance = ?, is_locked = ?, owner_name = ?, key_id = ? WHERE id = ?",
		t.CardNumber, t.Balance, t.IsLocked, t.OwnerName, t.KeyID, id,
	)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}
	t.ID, _ = strconv.Atoi(id)
	c.JSON(http.StatusOK, t)
}

// DeleteCard godoc
// @Summary Удалить карту
// @Tags Cards
// @Security BearerAuth
// @Param id path int true "ID карты"
// @Success 200 {object} map[string]string
// @Router /cards/{id} [delete]
func DeleteCard(c *gin.Context) {
	id := c.Param("id")
	_, err := database.DB.Exec("DELETE FROM cards WHERE id = ?", id)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}
	c.JSON(http.StatusOK, gin.H{"message": "card deleted"})
}

// --- Keys ---

// GetKeys godoc
// @Summary Получить список ключей
// @Tags Keys
// @Produce json
// @Security BearerAuth
// @Success 200 {array} models.Key
// @Router /keys [get]
func GetKeys(c *gin.Context) {
	rows, _ := database.DB.Query("SELECT * FROM keys")
	defer rows.Close()
	var list []models.Key
	for rows.Next() {
		var t models.Key
		rows.Scan(&t.ID, &t.KeyValue, &t.Description, &t.CreatedAt)
		list = append(list, t)
	}
	c.JSON(http.StatusOK, list)
}

// GetKeyByID godoc
// @Summary Получить ключ по ID
// @Tags Keys
// @Produce json
// @Security BearerAuth
// @Param id path int true "ID ключа"
// @Success 200 {object} models.Key
// @Failure 404 {object} map[string]string
// @Router /keys/{id} [get]
func GetKeyByID(c *gin.Context) {
	id := c.Param("id")

	var t models.Key
	err := database.DB.QueryRow(
		"SELECT id, key_value, description, created_at FROM keys WHERE id = ?",
		id,
	).Scan(&t.ID, &t.KeyValue, &t.Description, &t.CreatedAt)

	if err != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "key not found"})
		return
	}

	c.JSON(http.StatusOK, t)
}

// CreateKey godoc
// @Summary Создать ключ
// @Tags Keys
// @Accept json
// @Produce json
// @Security BearerAuth
// @Param request body models.Key true "Данные ключа"
// @Success 201 {object} models.Key
// @Router /keys [post]
func CreateKey(c *gin.Context) {
	var t models.Key
	c.ShouldBindJSON(&t)
	res, _ := database.DB.Exec("INSERT INTO keys (key_value, description) VALUES (?, ?)", t.KeyValue, t.Description)
	id, _ := res.LastInsertId()
	t.ID = int(id)
	c.JSON(http.StatusCreated, t)
}

// UpdateKey godoc
// @Summary Обновить ключ
// @Tags Keys
// @Accept json
// @Produce json
// @Security BearerAuth
// @Param id path int true "ID ключа"
// @Param request body models.Key true "Данные ключа"
// @Success 200 {object} models.Key
// @Router /keys/{id} [put]
func UpdateKey(c *gin.Context) {
	id := c.Param("id")
	var t models.Key
	if err := c.ShouldBindJSON(&t); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	_, err := database.DB.Exec(
		"UPDATE keys SET key_value = ?, description = ? WHERE id = ?",
		t.KeyValue, t.Description, id,
	)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}
	t.ID, _ = strconv.Atoi(id)
	c.JSON(http.StatusOK, t)
}

// DeleteKey godoc
// @Summary Удалить ключ
// @Tags Keys
// @Security BearerAuth
// @Param id path int true "ID ключа"
// @Success 200 {object} map[string]string
// @Router /keys/{id} [delete]
func DeleteKey(c *gin.Context) {
	id := c.Param("id")
	_, err := database.DB.Exec("DELETE FROM keys WHERE id = ?", id)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}
	c.JSON(http.StatusOK, gin.H{"message": "key deleted"})
}

// --- Transactions ---

// / GetTransactions godoc
// @Summary Получить список транзакций
// @Tags Transactions
// @Produce json
// @Security BearerAuth
// @Success 200 {array} models.Transaction
// @Router /transactions [get]
func GetTransactions(c *gin.Context) {
	rows, _ := database.DB.Query("SELECT * FROM transactions")
	defer rows.Close()
	var list []models.Transaction
	for rows.Next() {
		var t models.Transaction
		rows.Scan(&t.ID, &t.Amount, &t.CardID, &t.TerminalID, &t.TransactionDate)
		list = append(list, t)
	}
	c.JSON(http.StatusOK, list)
}

// GetTransactionByID godoc
// @Summary Получить транзакцию по ID
// @Tags Transactions
// @Produce json
// @Security BearerAuth
// @Param id path int true "ID транзакции"
// @Success 200 {object} models.Transaction
// @Failure 404 {object} map[string]string
// @Router /transactions/{id} [get]
func GetTransactionByID(c *gin.Context) {
	id := c.Param("id")

	var t models.Transaction
	err := database.DB.QueryRow(
		"SELECT id, amount, card_id, terminal_id, transaction_date FROM transactions WHERE id = ?",
		id,
	).Scan(&t.ID, &t.Amount, &t.CardID, &t.TerminalID, &t.TransactionDate)

	if err != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "transaction not found"})
		return
	}

	c.JSON(http.StatusOK, t)
}

// CreateTransaction godoc
// @Summary Создать транзакцию
// @Tags Transactions
// @Accept json
// @Produce json
// @Security BearerAuth
// @Param request body models.Transaction true "Данные транзакции"
// @Success 201 {object} models.Transaction
// @Router /transactions [post]
func CreateTransaction(c *gin.Context) {
	var t models.Transaction
	c.ShouldBindJSON(&t)
	res, _ := database.DB.Exec("INSERT INTO transactions (amount, card_id, terminal_id) VALUES (?, ?, ?)", t.Amount, t.CardID, t.TerminalID)
	id, _ := res.LastInsertId()
	t.ID = int(id)
	c.JSON(http.StatusCreated, t)
}
