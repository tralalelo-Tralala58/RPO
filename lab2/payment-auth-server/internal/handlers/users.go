package handlers

import (
	"net/http"
	"strconv"

	"payment-auth-server/internal/database"
	"payment-auth-server/internal/models"

	"github.com/gin-gonic/gin"
	"golang.org/x/crypto/bcrypt"
)

// GetUsers godoc
// @Summary Получить список пользователей
// @Tags Users
// @Produce json
// @Security BearerAuth
// @Success 200 {array} models.User
// @Router /users [get]
func GetUsers(c *gin.Context) {
	rows, err := database.DB.Query("SELECT id, login, name, is_admin, created_at FROM users")
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}
	defer rows.Close()

	var users []models.User
	for rows.Next() {
		var u models.User
		if err := rows.Scan(&u.ID, &u.Login, &u.Name, &u.IsAdmin, &u.CreatedAt); err != nil {
			c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
			return
		}
		users = append(users, u)
	}
	c.JSON(http.StatusOK, users)
}

// GetUserByID godoc
// @Summary Получить пользователя по ID
// @Tags Users
// @Produce json
// @Security BearerAuth
// @Param id path int true "ID пользователя"
// @Success 200 {object} models.User
// @Failure 404 {object} map[string]string
// @Router /users/{id} [get]
func GetUserByID(c *gin.Context) {
	id := c.Param("id")

	var u models.User
	err := database.DB.QueryRow(
		"SELECT id, login, name, is_admin, created_at FROM users WHERE id = ?",
		id,
	).Scan(&u.ID, &u.Login, &u.Name, &u.IsAdmin, &u.CreatedAt)

	if err != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "user not found"})
		return
	}

	c.JSON(http.StatusOK, u)
}

// CreateUser godoc
// @Summary Создать пользователя
// @Tags Users
// @Accept json
// @Produce json
// @Security BearerAuth
// @Param request body models.User true "Данные пользователя"
// @Success 201 {object} models.User
// @Router /users [post]
func CreateUser(c *gin.Context) {
	var user models.User
	if err := c.ShouldBindJSON(&user); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	// Проверяем, что пароль передан
	if user.Password == "" {
		c.JSON(http.StatusBadRequest, gin.H{"error": "password is required"})
		return
	}

	// Хешируем пароль из поля Password (не PasswordHash!)
	hash, err := bcrypt.GenerateFromPassword([]byte(user.Password), bcrypt.DefaultCost)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "password hash failed"})
		return
	}

	result, err := database.DB.Exec(
		"INSERT INTO users (login, name, password_hash, is_admin) VALUES (?, ?, ?, ?)",
		user.Login, user.Name, string(hash), user.IsAdmin,
	)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	id, _ := result.LastInsertId()
	user.ID = int(id)
	user.PasswordHash = "" // Не возвращаем хеш
	user.Password = ""     // Не возвращаем пароль
	c.JSON(http.StatusCreated, user)
}

// UpdateUser godoc
// @Summary Обновить пользователя
// @Tags Users
// @Accept json
// @Produce json
// @Security BearerAuth
// @Param id path integer true "ID пользователя"
// @Param request body models.User true "Данные пользователя"
// @Param input body models.UpdateUserRequest true "User update data"
// @Success 200 {object} models.User
// @Router /users/{id} [put]
func UpdateUser(c *gin.Context) {
	id := c.Param("id")

	var req models.UpdateUserRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	userIDAny, _ := c.Get("userID")
	isAdminAny, _ := c.Get("isAdmin")

	userID, ok := userIDAny.(int)
	if !ok {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "invalid user context"})
		return
	}

	isAdmin, ok := isAdminAny.(bool)
	if !ok {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "invalid admin context"})
		return
	}

	targetID, err := strconv.Atoi(id)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "invalid id"})
		return
	}

	// Обычный пользователь может редактировать только себя
	if !isAdmin && userID != targetID {
		c.JSON(http.StatusForbidden, gin.H{"error": "you can edit only your own profile"})
		return
	}

	// Если передан пароль — хешируем его
	var passwordHash string
	updatePassword := false
	if req.Password != "" {
		hash, err := bcrypt.GenerateFromPassword([]byte(req.Password), bcrypt.DefaultCost)
		if err != nil {
			c.JSON(http.StatusInternalServerError, gin.H{"error": "password hash failed"})
			return
		}
		passwordHash = string(hash)
		updatePassword = true
	}

	if isAdmin {
		// Админ может менять всё, включая is_admin
		if updatePassword {
			_, err = database.DB.Exec(
				"UPDATE users SET login = ?, name = ?, password_hash = ?, is_admin = ? WHERE id = ?",
				req.Login, req.Name, passwordHash, req.IsAdmin, targetID,
			)
		} else {
			_, err = database.DB.Exec(
				"UPDATE users SET login = ?, name = ?, is_admin = ? WHERE id = ?",
				req.Login, req.Name, req.IsAdmin, targetID,
			)
		}
	} else {
		// Обычный пользователь не может менять is_admin
		if updatePassword {
			_, err = database.DB.Exec(
				"UPDATE users SET login = ?, name = ?, password_hash = ? WHERE id = ?",
				req.Login, req.Name, passwordHash, targetID,
			)
		} else {
			_, err = database.DB.Exec(
				"UPDATE users SET login = ?, name = ? WHERE id = ?",
				req.Login, req.Name, targetID,
			)
		}
	}

	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	var updated models.User
	err = database.DB.QueryRow(
		"SELECT id, login, name, is_admin, created_at FROM users WHERE id = ?",
		targetID,
	).Scan(&updated.ID, &updated.Login, &updated.Name, &updated.IsAdmin, &updated.CreatedAt)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "failed to load updated user"})
		return
	}

	c.JSON(http.StatusOK, updated)
}

// DeleteUser godoc
// @Summary Удалить пользователя
// @Tags Users
// @Security BearerAuth
// @Param id path integer true "ID пользователя"
// @Success 200 {object} map[string]string
// @Router /users/{id} [delete]
func DeleteUser(c *gin.Context) {
	id := c.Param("id")
	_, err := database.DB.Exec("DELETE FROM users WHERE id = ?", id)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}
	c.JSON(http.StatusOK, gin.H{"message": "deleted"})
}
