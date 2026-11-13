package handler

import (
	"encoding/json"
	"errors"
	"net/http"
	"strings"
	"unicode/utf8"

	"mareview/auth"
	"mareview/store"
)

type registerReq struct {
	Email       string `json:"email"`
	Password    string `json:"password"`
	DisplayName string `json:"displayName"`
}

type loginReq struct {
	Email    string `json:"email"`
	Password string `json:"password"`
}

// Register สมัครสมาชิกใหม่
func (h *Handler) Register(w http.ResponseWriter, r *http.Request) {
	var req registerReq

	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		writeError(
			w,
			http.StatusBadRequest,
			"BAD_JSON",
			"รูปแบบ JSON ไม่ถูกต้อง",
		)
		return
	}

	email := strings.ToLower(strings.TrimSpace(req.Email))
	name := strings.TrimSpace(req.DisplayName)

	switch {
	case email == "" || !strings.Contains(email, "@") || len(email) > 255:
		writeError(
			w,
			http.StatusBadRequest,
			"BAD_EMAIL",
			"รูปแบบอีเมลไม่ถูกต้อง",
		)
		return

	case utf8.RuneCountInString(req.Password) < 8 || len(req.Password) > 72:
		writeError(
			w,
			http.StatusBadRequest,
			"BAD_PASSWORD",
			"รหัสผ่านต้องมีอย่างน้อย 8 ตัวอักษร และไม่เกิน 72 ไบต์",
		)
		return

	case name == "" || utf8.RuneCountInString(name) > 50:
		writeError(
			w,
			http.StatusBadRequest,
			"BAD_NAME",
			"กรุณากรอกชื่อที่แสดง โดยต้องไม่เกิน 50 ตัวอักษร",
		)
		return
	}

	// เข้ารหัสรหัสผ่านก่อนบันทึกลงฐานข้อมูล
	hash, err := auth.HashPassword(req.Password)
	if err != nil {
		internal(w, err)
		return
	}

	// สร้างสมาชิกใหม่
	member, err := h.Store.CreateMember(
		r.Context(),
		email,
		hash,
		name,
	)

	if errors.Is(err, store.ErrEmailTaken) {
		writeError(
			w,
			http.StatusConflict,
			"EMAIL_TAKEN",
			"อีเมลนี้มีบัญชีอยู่แล้ว",
		)
		return
	}

	if err != nil {
		internal(w, err)
		return
	}

	writeJSON(w, http.StatusCreated, member)
}

// Login เข้าสู่ระบบสมาชิก
func (h *Handler) Login(w http.ResponseWriter, r *http.Request) {
	var req loginReq

	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		writeError(
			w,
			http.StatusBadRequest,
			"BAD_JSON",
			"รูปแบบ JSON ไม่ถูกต้อง",
		)
		return
	}

	email := strings.ToLower(strings.TrimSpace(req.Email))

	if email == "" || req.Password == "" {
		writeError(
			w,
			http.StatusBadRequest,
			"MISSING_CREDENTIALS",
			"กรุณากรอกอีเมลและรหัสผ่าน",
		)
		return
	}

	// ค้นหาสมาชิกจากอีเมล
	member, err := h.Store.MemberByEmail(r.Context(), email)

	if errors.Is(err, store.ErrNotFound) {
		writeError(
			w,
			http.StatusUnauthorized,
			"BAD_CREDENTIALS",
			"อีเมลหรือรหัสผ่านไม่ถูกต้อง",
		)
		return
	}

	if err != nil {
		internal(w, err)
		return
	}

	// ตรวจสอบรหัสผ่านกับ bcrypt hash
	if !auth.CheckPassword(member.PasswordHash, req.Password) {
		writeError(
			w,
			http.StatusUnauthorized,
			"BAD_CREDENTIALS",
			"อีเมลหรือรหัสผ่านไม่ถูกต้อง",
		)
		return
	}

	// สร้าง JWT Token
	token, err := h.Tickets.Issue(member.ID, member.Role)
	if err != nil {
		internal(w, err)
		return
	}

	// ส่ง Token และข้อมูลสมาชิกกลับไป
	writeJSON(w, http.StatusOK, map[string]any{
		"token":  token,
		"member": member,
	})
}
