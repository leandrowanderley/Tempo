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
	// PreferSimpleProtocol desabilita prepared statements: o Connection
	// Pooler (PgBouncer) do Supabase reaproveita conexões entre clientes,
	// então statements preparados em uma conexão colidem com os de outra.
	DB, err = gorm.Open(postgres.New(postgres.Config{
		DSN:                  dsn,
		PreferSimpleProtocol: true,
	}), &gorm.Config{})
	if err != nil {
		log.Fatal("❌ Falha ao conectar ao Supabase:", err)
	}

	log.Println("☁️ Conectado ao Supabase com sucesso!")
}