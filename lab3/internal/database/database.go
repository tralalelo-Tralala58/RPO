package database

import (
	"database/sql"
	"log"
	"os"
	"path/filepath"

	_ "github.com/mattn/go-sqlite3"
	"github.com/pressly/goose/v3"
)

var DB *sql.DB

func Init(dbPath string) error {
	var err error

	// Создаём директорию для БД если нет
	dir := filepath.Dir(dbPath)
	if err := os.MkdirAll(dir, 0755); err != nil {
		return err
	}

	DB, err = sql.Open("sqlite3", dbPath+"?_foreign_keys=on")
	if err != nil {
		return err
	}

	if err := goose.SetDialect("sqlite3"); err != nil {
		return err
	}

	// Путь к миграциям относительно корня проекта
	if err := goose.Up(DB, "/app/migrations"); err != nil {
		return err
	}

	log.Println("✓ Database initialized")
	return nil
}

func Close() error {
	if DB != nil {
		return DB.Close()
	}
	return nil
}
