package handler

import (
	"encoding/json"
	"errors"
	"log"
	"net/http"
	"strconv"

	"mareview/auth"
	"mareview/store"
)

// Handler จัดการ HTTP Request ของระบบรีวิวหอพัก
type Handler struct {
	Store   *store.Store
	Tickets *auth.Issuer
}

// writeJSON ส่งข้อมูลกลับในรูปแบบ JSON
func writeJSON(w http.ResponseWriter, status int, v any) {
	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(status)
	_ = json.NewEncoder(w).Encode(v)
}

// writeError ส่งข้อความแจ้งข้อผิดพลาด
func writeError(w http.ResponseWriter, status int, code, message string) {
	writeJSON(w, status, map[string]any{
		"error": map[string]string{
			"code":    code,
			"message": message,
		},
	})
}

// internal บันทึกรายละเอียดข้อผิดพลาดไว้ใน log
// และส่งข้อความทั่วไปกลับไปยังผู้ใช้
func internal(w http.ResponseWriter, err error) {
	log.Printf("internal error: %v", err)

	writeError(
		w,
		http.StatusInternalServerError,
		"INTERNAL",
		"ระบบขัดข้อง ลองใหม่อีกครั้ง",
	)
}

// pathID อ่าน ID จาก URL และตรวจสอบว่าเป็นตัวเลขที่มากกว่า 0
func pathID(r *http.Request, name string) (int64, bool) {
	id, err := strconv.ParseInt(r.PathValue(name), 10, 64)
	return id, err == nil && id > 0
}

// SearchDormitories ค้นหาหอพัก
func (h *Handler) SearchDormitories(w http.ResponseWriter, r *http.Request) {
	query := r.URL.Query().Get("q")

	items, err := h.Store.SearchDormitories(r.Context(), query)
	if err != nil {
		internal(w, err)
		return
	}

	writeJSON(w, http.StatusOK, map[string]any{
		"items": items,
	})
}

// ListReviews แสดงรีวิวของหอพักตาม ID
func (h *Handler) ListReviews(w http.ResponseWriter, r *http.Request) {
	dormID, ok := pathID(r, "id")
	if !ok {
		writeError(
			w,
			http.StatusBadRequest,
			"BAD_ID",
			"รหัสหอพักต้องเป็นตัวเลขที่มากกว่า 0",
		)
		return
	}

	items, err := h.Store.ListReviews(r.Context(), dormID)
	if err != nil {
		internal(w, err)
		return
	}

	writeJSON(w, http.StatusOK, map[string]any{
		"items": items,
	})
}

// GetDormitory แสดงรายละเอียดหอพักตาม ID
func (h *Handler) GetDormitory(w http.ResponseWriter, r *http.Request) {
	dormID, ok := pathID(r, "id")
	if !ok {
		writeError(w, http.StatusBadRequest, "BAD_ID", "รหัสหอพักต้องเป็นตัวเลขที่มากกว่า 0")
		return
	}

	dorm, err := h.Store.DormitoryByID(r.Context(), dormID)

	if errors.Is(err, store.ErrNotFound) {
		writeError(w, http.StatusNotFound, "DORMITORY_NOT_FOUND", "ไม่พบหอพักนี้")
		return
	}

	if err != nil {
		internal(w, err)
		return
	}

	writeJSON(w, http.StatusOK, dorm)
}
