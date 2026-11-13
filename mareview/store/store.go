package store

import (
	"errors"

	"github.com/jackc/pgx/v5/pgxpool"
)

// ErrNotFound ใช้เมื่อไม่พบข้อมูลในฐานข้อมูล
var ErrNotFound = errors.New("not found")

// Store จัดการการเชื่อมต่อฐานข้อมูล
type Store struct {
	Pool *pgxpool.Pool
}
