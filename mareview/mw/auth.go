package mw

import (
	"context"
	"encoding/json"
	"net/http"
	"strings"

	"mareview/auth"
)

type Who struct {
	ID   int64
	Role string
}

type ctxKey struct{}

// WhoFrom ดึงข้อมูลสมาชิกจาก Context
func WhoFrom(ctx context.Context) Who {
	w, _ := ctx.Value(ctxKey{}).(Who)
	return w
}

// deny ส่งข้อความแจ้งเตือนเมื่อไม่มีสิทธิ์เข้าใช้งาน
func deny(w http.ResponseWriter, status int, code, msg string) {
	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(status)

	_ = json.NewEncoder(w).Encode(map[string]any{
		"error": map[string]string{
			"code":    code,
			"message": msg,
		},
	})
}

// RequireLogin ตรวจสอบว่าผู้ใช้เข้าสู่ระบบแล้วหรือไม่
func RequireLogin(iss *auth.Issuer, next http.HandlerFunc) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		header := r.Header.Get("Authorization")

		token, found := strings.CutPrefix(header, "Bearer ")
		if !found || token == "" {
			deny(
				w,
				http.StatusUnauthorized,
				"LOGIN_REQUIRED",
				"กรุณาเข้าสู่ระบบก่อน",
			)
			return
		}

		id, role, err := iss.Parse(token)
		if err != nil {
			deny(
				w,
				http.StatusUnauthorized,
				"TOKEN_INVALID",
				"ตั๋วใช้ไม่ได้หรือหมดอายุ กรุณาเข้าสู่ระบบใหม่",
			)
			return
		}

		ctx := context.WithValue(
			r.Context(),
			ctxKey{},
			Who{
				ID:   id,
				Role: role,
			},
		)

		next(w, r.WithContext(ctx))
	}
}

// RequireRole ตรวจสอบสิทธิ์ตามบทบาทสมาชิก
func RequireRole(role string, next http.HandlerFunc) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		if WhoFrom(r.Context()).Role != role {
			deny(
				w,
				http.StatusForbidden,
				"FORBIDDEN",
				"บัญชีนี้ไม่มีสิทธิ์ทำรายการนี้",
			)
			return
		}

		next(w, r)
	}
}