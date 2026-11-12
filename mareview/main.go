package main

import (
	"context"
	"log"
	"net/http"
	"os"
	"strings"
	"time"

	"github.com/jackc/pgx/v5/pgxpool"
	"github.com/joho/godotenv"

	"mareview/auth"
	"mareview/handler"
	"mareview/mw"
	"mareview/store"
)

func main() {
	// ตรวจสอบ JWT Secret
	secret := os.Getenv("JWT_SECRET")
	if len(secret) < 32 {
		log.Fatal("JWT_SECRET ต้องยาวอย่างน้อย 32 ตัวอักษร")
	}

	if err := godotenv.Load(); err != nil {
    log.Println("ไม่พบไฟล์ .env")
	}
	// เชื่อมต่อฐานข้อมูล PostgreSQL
	databaseURL := os.Getenv("DATABASE_URL")
	if databaseURL == "" {
		log.Fatal("กรุณากำหนด DATABASE_URL")
	}

	pool, err := pgxpool.New(context.Background(), databaseURL)
	if err != nil {
		log.Fatal("สร้างการเชื่อมต่อฐานข้อมูลไม่สำเร็จ: ", err)
	}
	defer pool.Close()

	if err := pool.Ping(context.Background()); err != nil {
		log.Fatal("เชื่อมต่อฐานข้อมูลไม่สำเร็จ: ", err)
	}

	log.Println("เชื่อมต่อฐานข้อมูลสำเร็จ")

	// สร้างระบบ Token
	tickets := &auth.Issuer{
		Secret: []byte(secret),
		TTL:    time.Hour,
	}

	// สร้าง Handler
	h := &handler.Handler{
		Store:   &store.Store{Pool: pool},
		Tickets: tickets,
	}

	// Middleware ตรวจสอบการเข้าสู่ระบบ
	login := func(f http.HandlerFunc) http.HandlerFunc {
		return mw.RequireLogin(tickets, f)
	}

	// กำหนด Routes
	mux := http.NewServeMux()

	// Authentication
	mux.HandleFunc("POST /api/auth/register", h.Register)
	mux.HandleFunc("POST /api/auth/login", h.Login)

	// Dormitories
	mux.HandleFunc("GET /api/dormitories", h.SearchDormitories)

	// Dormitory Reviews
	mux.HandleFunc("GET /api/dormitories/{id}/reviews", h.ListReviews)
	mux.HandleFunc("POST /api/dormitories/{id}/reviews", login(h.AddReview))
	mux.HandleFunc("DELETE /api/reviews/{reviewId}", login(h.DeleteReview))

	// Member
	mux.HandleFunc("GET /api/me", login(h.Me))

	// Admin
	mux.HandleFunc(
		"GET /api/admin/members",
		login(mw.RequireRole("admin", h.AdminMembers)),
	)

	// CORS
	origins := strings.Split(os.Getenv("ALLOWED_ORIGINS"), ",")

	// เริ่มต้น Server
	log.Println("Mareview API กำลังทำงานที่ :8080")
	log.Println("Allowed Origins:", origins)

	server := &http.Server{
		Addr:              ":8080",
		Handler:           mw.Logging(mw.CORS(origins, mux)),
		ReadHeaderTimeout: 5 * time.Second,
	}

	log.Fatal(server.ListenAndServe())
}