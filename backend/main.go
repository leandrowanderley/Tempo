package main

import (
	"log"
	"os"

	"tempo-api/database"
	"tempo-api/models"
	"tempo-api/routes"

	"github.com/gin-contrib/cors"
	"github.com/gin-gonic/gin"
	"github.com/joho/godotenv"
)

func main() {
	if err := godotenv.Load(); err != nil {
		log.Println("⚠️  Nenhum arquivo .env encontrado, usando variáveis de ambiente do sistema")
	}

	database.ConnectDB()

	if err := database.DB.AutoMigrate(&models.User{}, &models.Event{}, &models.Routine{}); err != nil {
		log.Fatal("❌ Falha ao rodar o AutoMigrate:", err)
	}
	log.Println("✅ AutoMigrate concluído! Tabelas criadas/atualizadas no Supabase.")

	router := gin.Default()
	router.Use(cors.Default()) // libera todas as origens (dev/Xcode simulator), conforme BACKEND_SPECS.md
	routes.Setup(router)

	port := os.Getenv("PORT")
	if port == "" {
		port = "8080"
	}

	if err := router.Run(":" + port); err != nil {
		log.Fatal("❌ Falha ao iniciar o servidor:", err)
	}
}
