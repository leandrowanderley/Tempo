package database

import (
	"log"
	"os"
	"gorm.io/driver/postgres"
	"gorm.io/gorm"
)

var DB *gorm.DB

func ConnectDB() {
	// Pega a URL do .env
	dsn := os.Getenv("DATABASE_URL")
	if dsn == "" {
		log.Fatal("❌ DATABASE_URL não está configurada no arquivo .env!")
	}

	var err error
	// Conecta de forma direta ao Supabase
	DB, err = gorm.Open(postgres.Open(dsn), &gorm.Config{})
	if err != nil {
		log.Fatal("❌ Falha ao conectar ao Supabase:", err)
	}

	log.Println("☁️ Conectado ao Supabase com sucesso!")
}