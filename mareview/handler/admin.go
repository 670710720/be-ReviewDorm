
package handler

import (
	"encoding/json"
	"errors"
	"net/http"
	"strconv"

	"mareview/store"
)

// AdminMembers แสดงรายการสมาชิก
func (h *Handler) AdminMembers(w http.ResponseWriter, r *http.Request) {
	members, err := h.Store.ListAdminMembers(r.Context())
	if err != nil {
		internal(w, err)
		return
	}

	writeJSON(w, http.StatusOK, map[string]any{
		"items": members,
	})
}

// AdminStats แสดง Dashboard
func (h *Handler) AdminStats(w http.ResponseWriter, r *http.Request) {
	stats, err := h.Store.Stats(r.Context())
	if err != nil {
		internal(w, err)
		return
	}

	writeJSON(w, http.StatusOK, stats)
}

// AdminDormitories แสดงรายการหอพักทั้งหมด
func (h *Handler) AdminDormitories(w http.ResponseWriter, r *http.Request) {
	items, err := h.Store.ListAdminDormitories(r.Context())
	if err != nil {
		internal(w, err)
		return
	}

	writeJSON(w, http.StatusOK, map[string]any{
		"items": items,
	})
}

// AdminGetDormitory ดูรายละเอียดหอพัก
func (h *Handler) AdminGetDormitory(w http.ResponseWriter, r *http.Request) {
	id, err := strconv.ParseInt(r.PathValue("id"), 10, 64)
	if err != nil {
		http.Error(w, "invalid dormitory id", http.StatusBadRequest)
		return
	}

	item, err := h.Store.AdminGetDormitory(r.Context(), id)
	if err != nil {
		if errors.Is(err, store.ErrNotFound) {
			http.Error(w, "dormitory not found", http.StatusNotFound)
			return
		}
		internal(w, err)
		return
	}

	writeJSON(w, http.StatusOK, item)
}

// AdminCreateDormitory เพิ่มหอพัก
func (h *Handler) AdminCreateDormitory(w http.ResponseWriter, r *http.Request) {
	var input store.DormitoryInput

	if err := json.NewDecoder(r.Body).Decode(&input); err != nil {
		http.Error(w, "invalid request body", http.StatusBadRequest)
		return
	}

	item, err := h.Store.CreateDormitory(r.Context(), input)
	if err != nil {
		if errors.Is(err, store.ErrBadImages) {
			http.Error(w, err.Error(), http.StatusBadRequest)
			return
		}
		internal(w, err)
		return
	}

	writeJSON(w, http.StatusCreated, item)
}

// AdminUpdateDormitory แก้ไขหอพัก
func (h *Handler) AdminUpdateDormitory(w http.ResponseWriter, r *http.Request) {
	id, err := strconv.ParseInt(r.PathValue("id"), 10, 64)
	if err != nil {
		http.Error(w, "invalid dormitory id", http.StatusBadRequest)
		return
	}

	var input store.DormitoryInput

	if err := json.NewDecoder(r.Body).Decode(&input); err != nil {
		http.Error(w, "invalid request body", http.StatusBadRequest)
		return
	}

	item, err := h.Store.UpdateDormitory(r.Context(), id, input)
	if err != nil {
		if errors.Is(err, store.ErrNotFound) {
			http.Error(w, "dormitory not found", http.StatusNotFound)
			return
		}
		if errors.Is(err, store.ErrBadImages) {
			http.Error(w, err.Error(), http.StatusBadRequest)
			return
		}
		internal(w, err)
		return
	}

	writeJSON(w, http.StatusOK, item)
}

// AdminDeleteDormitory ลบหอพัก
func (h *Handler) AdminDeleteDormitory(w http.ResponseWriter, r *http.Request) {
	id, err := strconv.ParseInt(r.PathValue("id"), 10, 64)
	if err != nil {
		http.Error(w, "invalid dormitory id", http.StatusBadRequest)
		return
	}

	if err := h.Store.DeleteDormitory(r.Context(), id); err != nil {
		if errors.Is(err, store.ErrNotFound) {
			http.Error(w, "dormitory not found", http.StatusNotFound)
			return
		}
		internal(w, err)
		return
	}

	writeJSON(w, http.StatusOK, map[string]any{
		"message": "dormitory deleted successfully",
	})
}

// AdminReviews แสดงรีวิวทั้งหมด
func (h *Handler) AdminReviews(w http.ResponseWriter, r *http.Request) {
	items, err := h.Store.ListAdminReviews(r.Context())
	if err != nil {
		internal(w, err)
		return
	}

	writeJSON(w, http.StatusOK, map[string]any{
		"items": items,
	})
}

// AdminUpdateMemberRole เปลี่ยน Role สมาชิก
func (h *Handler) AdminUpdateMemberRole(w http.ResponseWriter, r *http.Request) {
	id, err := strconv.ParseInt(r.PathValue("id"), 10, 64)
	if err != nil {
		http.Error(w, "invalid member id", http.StatusBadRequest)
		return
	}

	var input struct {
		Role string `json:"role"`
	}

	if err := json.NewDecoder(r.Body).Decode(&input); err != nil {
		http.Error(w, "invalid request body", http.StatusBadRequest)
		return
	}

	err = h.Store.UpdateMemberRole(r.Context(), id, input.Role)
	if err != nil {
		if errors.Is(err, store.ErrNotFound) {
			http.Error(w, "member not found", http.StatusNotFound)
			return
		}
		if errors.Is(err, store.ErrBadRole) || errors.Is(err, store.ErrLastAdmin) {
			http.Error(w, err.Error(), http.StatusBadRequest)
			return
		}
		internal(w, err)
		return
	}

	writeJSON(w, http.StatusOK, map[string]any{
		"message": "member role updated successfully",
	})
}

// AdminDeleteMember ลบสมาชิก
func (h *Handler) AdminDeleteMember(w http.ResponseWriter, r *http.Request) {
	id, err := strconv.ParseInt(r.PathValue("id"), 10, 64)
	if err != nil {
		http.Error(w, "invalid member id", http.StatusBadRequest)
		return
	}

	if err := h.Store.DeleteMember(r.Context(), id); err != nil {
		if errors.Is(err, store.ErrNotFound) {
			http.Error(w, "member not found or cannot delete admin", http.StatusNotFound)
			return
		}
		internal(w, err)
		return
	}

	writeJSON(w, http.StatusOK, map[string]any{
		"message": "member deleted successfully",
	})
}
