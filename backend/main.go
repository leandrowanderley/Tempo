package main

import (
	"log"

	"tempo-api/database"
	"tempo-api/models"

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
}
