package handler

import (
	"encoding/json"
	"errors"
	"net/http"
	"strings"
	"unicode/utf8"
	"strconv"

	"mareview/mw"
	"mareview/store"
)

// Me แสดงข้อมูลสมาชิกที่เข้าสู่ระบบอยู่
func (h *Handler) Me(w http.ResponseWriter, r *http.Request) {
	who := mw.WhoFrom(r.Context())

	m, err := h.Store.MemberByID(r.Context(), who.ID)
	if errors.Is(err, store.ErrNotFound) {
		writeError(w, http.StatusUnauthorized, "LOGIN_REQUIRED", "กรุณาเข้าสู่ระบบก่อน")
		return
	}
	if err != nil {
		internal(w, err)
		return
	}

	writeJSON(w, http.StatusOK, m)
}

// reviewReq ข้อมูลที่รับจากผู้ใช้ตอนเขียนรีวิวหอพัก
type reviewReq struct {
	Text   string `json:"text"`
	Rating int16  `json:"rating"`
}

// AddReview เพิ่มรีวิวหอพัก
func (h *Handler) AddReview(w http.ResponseWriter, r *http.Request) {
    dormID, ok := pathID(r, "id")
    if !ok {
        writeError(w, http.StatusBadRequest, "BAD_ID", "รหัสหอพักต้องเป็นตัวเลขที่มากกว่า 0")
        return
    }

    var req reviewReq
    if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
        writeError(w, http.StatusBadRequest, "BAD_JSON", "รูปแบบ JSON ไม่ถูกต้อง")
        return
    }

    text := strings.TrimSpace(req.Text)

    if utf8.RuneCountInString(text) < 10 {
        writeError(w, http.StatusBadRequest, "REVIEW_TOO_SHORT", "รีวิวต้องมีอย่างน้อย 10 ตัวอักษร")
        return
    }

    if req.Rating < 1 || req.Rating > 10 {
        writeError(w, http.StatusBadRequest, "INVALID_RATING", "คะแนนต้องอยู่ระหว่าง 1-10")
        return
    }

    who := mw.WhoFrom(r.Context())

    rv, err := h.Store.AddReview(
        r.Context(),
        who.ID,
        dormID,
        text,
        req.Rating,
    )

    switch {
    case errors.Is(err, store.ErrDuplicate):
        writeError(w, http.StatusConflict, "ALREADY_REVIEWED", "คุณรีวิวหอพักนี้ไปแล้ว")
        return

    case errors.Is(err, store.ErrNoDormitory):
        writeError(w, http.StatusNotFound, "DORMITORY_NOT_FOUND", "ไม่พบหอพักนี้")
        return

    case errors.Is(err, store.ErrInvalidRating):
        writeError(w, http.StatusBadRequest, "INVALID_RATING", "คะแนนต้องอยู่ระหว่าง 1-10")
        return

    case err != nil:
        internal(w, err)
        return
    }

    writeJSON(w, http.StatusCreated, map[string]any{
        "id":        rv.ID,
        "text":      rv.Text,
        "rating":    rv.Rating,
        "createdAt": rv.CreatedAt,
    })
}

// DeleteReview ลบรีวิวของสมาชิก หรือรีวิวที่ผู้ดูแลระบบมีสิทธิ์ลบ
func (h *Handler) DeleteReview(w http.ResponseWriter, r *http.Request) {
    reviewID, err := strconv.ParseInt(r.PathValue("id"), 10, 64)
    if err != nil {
        http.Error(w, "invalid review id", http.StatusBadRequest)
        return
    }

    who := mw.WhoFrom(r.Context())

    isAdmin := who.Role == "admin"

    err = h.Store.DeleteReview(
        r.Context(),
        reviewID,
        who.ID,
        isAdmin,
    )
    if err != nil {
        if errors.Is(err, store.ErrNotFound) {
            http.Error(w, "review not found or permission denied", http.StatusNotFound)
            return
        }

        http.Error(w, "internal server error", http.StatusInternalServerError)
        return
    }

    writeJSON(w, http.StatusOK, map[string]any{
        "message": "review deleted successfully",
    })
}
