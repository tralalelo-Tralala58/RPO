package main

import (
	"log"

	_ "payment-auth-server/docs"
	"payment-auth-server/internal/database"
	"payment-auth-server/internal/handlers"
	"payment-auth-server/internal/middleware"

	"github.com/gin-gonic/gin"
	swaggerFiles "github.com/swaggo/files"
	ginSwagger "github.com/swaggo/gin-swagger"
)

// @title Payment Auth API
// @version 1.0
// @host localhost:8888
// @BasePath /api/v1
// @schemes https
// @securityDefinitions.apikey BearerAuth
// @in header
// @name Authorization
func main() {
	// Инициализация БД
	if err := database.Init("/app/data/auth.db"); err != nil {
		log.Fatalf("DB init failed: %v", err)
	}
	defer database.Close()

	r := gin.Default()
	v1 := r.Group("/api/v1")

	// Swagger UI
	v1.GET("/swagger/*any", ginSwagger.WrapHandler(swaggerFiles.Handler))

	// === ПУБЛИЧНЫЕ ЭНДПОИНТЫ ===
	auth := v1.Group("/auth")
	{
		auth.POST("/login", handlers.Login) // @tags Auth
	}

	// === ЗАЩИЩЁННЫЕ ЭНДПОИНТЫ (требуют JWT) ===
	protected := v1.Group("")
	protected.Use(middleware.JWTMiddleware())
	{
		users := protected.Group("/users")
		{
			users.GET("", handlers.GetUsers)
			users.GET("/:id", handlers.GetUserByID)
			users.POST("", middleware.AdminOnly(), handlers.CreateUser)
			users.PUT("/:id", handlers.UpdateUser)
			users.DELETE("/:id", middleware.AdminOnly(), handlers.DeleteUser)
		}

		terminals := protected.Group("/terminals")
		{
			terminals.GET("", handlers.GetTerminals)
			terminals.GET("/:id", handlers.GetTerminalByID)
			terminals.POST("", middleware.AdminOnly(), handlers.CreateTerminal)
			terminals.PUT("/:id", middleware.AdminOnly(), handlers.UpdateTerminal)
			terminals.DELETE("/:id", middleware.AdminOnly(), handlers.DeleteTerminal)
		}

		cards := protected.Group("/cards")
		{
			cards.GET("", handlers.GetCards)
			cards.GET("/:id", handlers.GetCardByID)
			cards.POST("", middleware.AdminOnly(), handlers.CreateCard)
			cards.PUT("/:id", middleware.AdminOnly(), handlers.UpdateCard)
			cards.DELETE("/:id", middleware.AdminOnly(), handlers.DeleteCard)
		}

		keys := protected.Group("/keys")
		{
			keys.GET("", handlers.GetKeys)
			keys.GET("/:id", handlers.GetKeyByID)
			keys.POST("", middleware.AdminOnly(), handlers.CreateKey)
			keys.PUT("/:id", middleware.AdminOnly(), handlers.UpdateKey)
			keys.DELETE("/:id", middleware.AdminOnly(), handlers.DeleteKey)
		}

		transactions := protected.Group("/transactions")
		{
			transactions.GET("", handlers.GetTransactions)
			transactions.GET("/:id", handlers.GetTransactionByID)
			transactions.POST("", middleware.AdminOnly(), handlers.CreateTransaction)
		}

		terminal := protected.Group("/terminal")
		{
			terminal.POST("/authorize", handlers.TerminalAuthorize)
			terminal.GET("/keys", handlers.GetKeysForTerminal)
		}
	}

	log.Println("Server starting on :8080")
	r.Run(":8080")
}
