package main

import (
	"context"
	"log"
	"net/http"
	"os"
	"strings"
	"time"

	"github.com/jackc/pgx/v5"
	"github.com/jackc/pgx/v5/pgxpool"
	"github.com/joho/godotenv"

	"mareview/auth"
	"mareview/handler"
	"mareview/mw"
	"mareview/store"
)

func main() {
	// =====================================
	// 1. Load Environment Variables
	// =====================================

	if err := godotenv.Load(); err != nil {
		log.Println("ไม่พบไฟล์ .env ใช้ Environment Variables จากระบบ")
	}

	// =====================================
	// 2. JWT Configuration
	// =====================================

	secret := os.Getenv("JWT_SECRET")

	if len(secret) < 32 {
		log.Fatal("JWT_SECRET ต้องยาวอย่างน้อย 32 ตัวอักษร")
	}

	tickets := &auth.Issuer{
		Secret: []byte(secret),
		TTL:    time.Hour,
	}

	// =====================================
	// 3. Database Connection
	// =====================================

	databaseURL := os.Getenv("DATABASE_URL")

	if databaseURL == "" {
		log.Fatal("กรุณากำหนด DATABASE_URL")
	}

	ctx, cancel := context.WithTimeout(
		context.Background(),
		15*time.Second,
	)
	defer cancel()

	// Parse Database Configuration
	poolConfig, err := pgxpool.ParseConfig(databaseURL)
	if err != nil {
		log.Fatal("อ่าน Database URL ไม่สำเร็จ: ", err)
	}

	// ปิด Prepared Statement Cache
	// รองรับ Supabase Transaction Pooler
	poolConfig.ConnConfig.DefaultQueryExecMode = pgx.QueryExecModeExec
	poolConfig.ConnConfig.StatementCacheCapacity = 0

	// สร้าง Connection Pool
	pool, err := pgxpool.NewWithConfig(ctx, poolConfig)
	if err != nil {
		log.Fatal("สร้างการเชื่อมต่อฐานข้อมูลไม่สำเร็จ: ", err)
	}
	defer pool.Close()

	// ตรวจสอบ Database Connection
	if err := pool.Ping(ctx); err != nil {
		log.Fatal("เชื่อมต่อฐานข้อมูลไม่สำเร็จ: ", err)
	}

	log.Println("เชื่อมต่อฐานข้อมูลสำเร็จ")
	log.Println("PostgreSQL Query Mode: Exec")

	// =====================================
	// 4. Initialize Handler
	// =====================================

	h := &handler.Handler{
		Store:   &store.Store{Pool: pool},
		Tickets: tickets,
	}

	// =====================================
	// 5. Authentication Middleware
	// =====================================

	login := func(f http.HandlerFunc) http.HandlerFunc {
		return mw.RequireLogin(tickets, f)
	}

	admin := func(f http.HandlerFunc) http.HandlerFunc {
		return login(mw.RequireRole("admin", f))
	}

	// =====================================
	// 6. API Routes
	// =====================================

	mux := http.NewServeMux()

	// Authentication
	mux.HandleFunc("POST /api/auth/register", h.Register)
	mux.HandleFunc("POST /api/auth/login", h.Login)

	// Dormitories
	mux.HandleFunc("GET /api/dormitories", h.SearchDormitories)
	mux.HandleFunc("GET /api/dormitories/{id}",h.GetDormitory)


	// Reviews
	mux.HandleFunc("GET /api/dormitories/{id}/reviews", h.ListReviews)
	mux.HandleFunc("POST /api/dormitories/{id}/reviews", login(h.AddReview))
	mux.HandleFunc("DELETE /api/reviews/{reviewId}", login(h.DeleteReview))

	// Member
	mux.HandleFunc("GET /api/me", login(h.Me))

	// Admin
	mux.HandleFunc("GET /api/admin/members", admin(h.AdminMembers))

	// =====================================
	// 7. CORS Configuration
	// =====================================

	allowedOrigins := strings.Split(
		os.Getenv("ALLOWED_ORIGINS"),
		",",
	)

	var origins []string

	for _, origin := range allowedOrigins {
		origin = strings.TrimSpace(origin)

		if origin != "" {
			origins = append(origins, origin)
		}
	}

	if len(origins) == 0 {
		log.Println("WARNING: ยังไม่ได้กำหนด ALLOWED_ORIGINS")
	}

	// =====================================
	// 8. Server Configuration
	// =====================================

	port := os.Getenv("PORT")

	if port == "" {
		port = "8080"
	}

	server := &http.Server{
		Addr:              ":" + port,
		Handler:           mw.Logging(mw.CORS(origins, mux)),
		ReadHeaderTimeout: 5 * time.Second,
	}

	log.Println("=================================")
	log.Println("Mareview API กำลังทำงาน")
	log.Println("Port:", port)
	log.Println("Allowed Origins:", origins)
	log.Println("=================================")

	if err := server.ListenAndServe(); err != nil &&
		err != http.ErrServerClosed {
		log.Fatal("Server error: ", err)
	}
}
