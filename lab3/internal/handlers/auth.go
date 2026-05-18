package handlers

import (
	"net/http"

	"payment-auth-server/internal/database"
	"payment-auth-server/internal/middleware"
	"payment-auth-server/internal/models"

	"github.com/gin-gonic/gin"
	"golang.org/x/crypto/bcrypt"
)

// Login godoc
// @Summary Авторизация пользователя
// @Tags Auth
// @Accept json
// @Produce json
// @Param request body models.LoginRequest true "Логин и пароль"
// @Success 200 {object} models.AuthResponse
// @Router /auth/login [post]
func Login(c *gin.Context) {
	var req models.LoginRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	var user models.User
	err := database.DB.QueryRow(
		"SELECT id, login, name, password_hash, is_admin FROM users WHERE login = ?",
		req.Login,
	).Scan(&user.ID, &user.Login, &user.Name, &user.PasswordHash, &user.IsAdmin)

	if err != nil {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "invalid credentials"})
		return
	}

	if err := bcrypt.CompareHashAndPassword([]byte(user.PasswordHash), []byte(req.Password)); err != nil {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "invalid credentials"})
		return
	}

	token, err := middleware.GenerateToken(user.ID, user.Login, user.IsAdmin)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "token generation failed"})
		return
	}

	c.JSON(http.StatusOK, models.AuthResponse{Token: token})
}
