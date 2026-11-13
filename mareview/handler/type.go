package handler

import (
    "net/http"
)

// GetDormitoryTypes ดึงประเภทหอพัก
func (h *Handler) GetDormitoryTypes(w http.ResponseWriter, r *http.Request) {
    items, err := h.Store.ListDormitoryTypes(r.Context())
    if err != nil {
        internal(w, err)
        return
    }

    writeJSON(w, http.StatusOK, map[string]any{
        "items": items,
    })
}

// GetGenderTypes ดึงประเภทผู้พัก
func (h *Handler) GetGenderTypes(w http.ResponseWriter, r *http.Request) {
    items, err := h.Store.ListGenderTypes(r.Context())
    if err != nil {
        internal(w, err)
        return
    }

    writeJSON(w, http.StatusOK, map[string]any{
        "items": items,
    })
}