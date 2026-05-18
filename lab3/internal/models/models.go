package models

import "time"

// --- Таблицы БД ---

type User struct {
	ID           int       `json:"id"`
	Login        string    `json:"login" binding:"required"`
	Name         string    `json:"name" binding:"required"`
	Password     string    `json:"password,omitempty" binding:"omitempty"` // ← Для ввода пароля (при создании)
	PasswordHash string    `json:"-"`                                      // ← Только для БД, не возвращается в JSON
	IsAdmin      bool      `json:"is_admin"`
	CreatedAt    time.Time `json:"created_at"`
}

type Terminal struct {
	ID           int       `json:"id"`
	SerialNumber string    `json:"serial_number" binding:"required"`
	Address      string    `json:"address"`
	Name         string    `json:"name"`
	CreatedAt    time.Time `json:"created_at"`
}

type Key struct {
	ID          int       `json:"id"`
	KeyValue    string    `json:"key_value" binding:"required"`
	Description string    `json:"description"`
	CreatedAt   time.Time `json:"created_at"`
}

type Card struct {
	ID         int       `json:"id"`
	CardNumber string    `json:"card_number" binding:"required"`
	Balance    float64   `json:"balance"`
	IsLocked   bool      `json:"is_locked"`
	OwnerName  string    `json:"owner_name"`
	KeyID      *int      `json:"key_id,omitempty"`
	CreatedAt  time.Time `json:"created_at"`
}

type Transaction struct {
	ID              int       `json:"id"`
	Amount          float64   `json:"amount" binding:"required"`
	CardID          int       `json:"card_id" binding:"required"`
	TerminalID      int       `json:"terminal_id" binding:"required"`
	TransactionDate time.Time `json:"transaction_date"`
}

// --- Запросы и Ответы API ---

type LoginRequest struct {
	Login    string `json:"login" binding:"required"`
	Password string `json:"password" binding:"required"`
}

type AuthResponse struct {
	Token string `json:"token"`
}

type TerminalAuthRequest struct {
	CardNumber string  `json:"card_number" binding:"required"`
	Amount     float64 `json:"amount" binding:"required"`
	TerminalSN string  `json:"terminal_sn" binding:"required"`
}

type TerminalAuthResponse struct {
	Authorized bool   `json:"authorized"`
	Message    string `json:"message,omitempty"`
}

type UpdateUserRequest struct {
	Login    string `json:"login"`
	Name     string `json:"name"`
	Password string `json:"password,omitempty"`
	IsAdmin  bool   `json:"is_admin,omitempty"`
}
