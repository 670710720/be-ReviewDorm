
package handler

import (
	"encoding/json"
	"net/http"
	"strconv"

	"mareview/mw"
	"mareview/store"
)

// GetWishlist ดึงรายการ Wishlist ของสมาชิก
func (h *Handler) GetWishlist(
	w http.ResponseWriter,
	r *http.Request,
) {
	who := mw.WhoFrom(r.Context())

	items, err := h.Store.ListWishlist(
		r.Context(),
		who.ID,
	)
	if err != nil {
		http.Error(
			w,
			"ไม่สามารถดึงรายการ Wishlist ได้",
			http.StatusInternalServerError,
		)
		return
	}

	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(map[string]interface{}{
		"items": items,
	})
}

// AddWishlist เพิ่มหอพักลง Wishlist
func (h *Handler) AddWishlist(
	w http.ResponseWriter,
	r *http.Request,
) {
	who := mw.WhoFrom(r.Context())

	dormID, err := strconv.ParseInt(
		r.PathValue("id"),
		10,
		64,
	)
	if err != nil || dormID <= 0 {
		http.Error(
			w,
			"รหัสหอพักไม่ถูกต้อง",
			http.StatusBadRequest,
		)
		return
	}

	err = h.Store.AddWishlist(
		r.Context(),
		who.ID,
		dormID,
	)
	if err != nil {
		if err == store.ErrNoDormitory {
			http.Error(
				w,
				"ไม่พบหอพักที่ต้องการบันทึก",
				http.StatusNotFound,
			)
			return
		}

		http.Error(
			w,
			"ไม่สามารถบันทึก Wishlist ได้",
			http.StatusInternalServerError,
		)
		return
	}

	w.WriteHeader(http.StatusNoContent)
}

// RemoveWishlist ลบหอพักออกจาก Wishlist
func (h *Handler) RemoveWishlist(
	w http.ResponseWriter,
	r *http.Request,
) {
	who := mw.WhoFrom(r.Context())

	dormID, err := strconv.ParseInt(
		r.PathValue("id"),
		10,
		64,
	)
	if err != nil || dormID <= 0 {
		http.Error(
			w,
			"รหัสหอพักไม่ถูกต้อง",
			http.StatusBadRequest,
		)
		return
	}

	err = h.Store.RemoveWishlist(
		r.Context(),
		who.ID,
		dormID,
	)
	if err != nil {
		http.Error(
			w,
			"ไม่สามารถลบ Wishlist ได้",
			http.StatusInternalServerError,
		)
		return
	}

	w.WriteHeader(http.StatusNoContent)
}
