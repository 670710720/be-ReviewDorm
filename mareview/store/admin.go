package store

import (
	"context"
	"encoding/json"
	"errors"
	"time"

	"github.com/jackc/pgx/v5"
)

var (
	ErrBadRole   = errors.New("invalid role")
	ErrLastAdmin = errors.New("cannot remove the last admin")
	ErrBadImages = errors.New("maximum 4 images allowed")
)

// =====================================================
// Dashboard
// =====================================================

type TopDormitory struct {
	ID            int64   `json:"id"`
	Name          string  `json:"name"`
	RatingAverage float64 `json:"ratingAverage"`
	RatingCount   int64   `json:"ratingCount"`
}

type AdminMember struct {
	ID          int64     `json:"id"`
	Email       string    `json:"email"`
	DisplayName string    `json:"displayName"`
	AvatarURL   *string   `json:"avatarUrl"`
	Role        string    `json:"role"`
	CreatedAt   time.Time `json:"createdAt"`
}

type AdminStats struct {
	Dormitories    int64          `json:"dormitories"`
	Members        int64          `json:"members"`
	Admins         int64          `json:"admins"`
	Reviews        int64          `json:"reviews"`
	Ratings        int64          `json:"ratings"`
	Wishlists      int64          `json:"wishlists"`
	NewestMembers  []AdminMember  `json:"newestMembers"`
	TopDormitories []TopDormitory `json:"topDormitories"`
}

// Stats รวมข้อมูล Dashboard
func (s *Store) Stats(ctx context.Context) (AdminStats, error) {
	var st AdminStats

	err := s.Pool.QueryRow(ctx, `
		SELECT
			(SELECT count(*) FROM dormitories),
			(SELECT count(*) FROM members),
			(SELECT count(*) FROM members WHERE role = 'admin'),
			(SELECT count(*) FROM dorm_reviews),
			(SELECT count(*) FROM dorm_ratings),
			(SELECT count(*) FROM dorm_wishlists)
	`).Scan(
		&st.Dormitories,
		&st.Members,
		&st.Admins,
		&st.Reviews,
		&st.Ratings,
		&st.Wishlists,
	)
	if err != nil {
		return st, err
	}

	// สมาชิกใหม่ล่าสุด 5 คน
	rows, err := s.Pool.Query(ctx, `
		SELECT member_id, email, display_name, avatar_url, role, created_at
		FROM members
		ORDER BY created_at DESC, member_id DESC
		LIMIT 5
	`)
	if err != nil {
		return st, err
	}

	st.NewestMembers = []AdminMember{}

	for rows.Next() {
		var m AdminMember
		if err := rows.Scan(
			&m.ID,
			&m.Email,
			&m.DisplayName,
			&m.AvatarURL,
			&m.Role,
			&m.CreatedAt,
		); err != nil {
			rows.Close()
			return st, err
		}
		st.NewestMembers = append(st.NewestMembers, m)
	}

	err = rows.Err()
	rows.Close()
	if err != nil {
		return st, err
	}

	// หอพักคะแนนสูงสุด 5 อันดับ
	rows, err = s.Pool.Query(ctx, `
		SELECT
			d.dorm_id,
			d.dorm_name,
			COALESCE(rs.rating_average, 0)::float8,
			COALESCE(rs.rating_count, 0)
		FROM dormitories d
		LEFT JOIN dorm_rating_stats rs
			ON rs.dorm_id = d.dorm_id
		ORDER BY
			COALESCE(rs.rating_average, 0) DESC,
			COALESCE(rs.rating_count, 0) DESC
		LIMIT 5
	`)
	if err != nil {
		return st, err
	}
	defer rows.Close()

	st.TopDormitories = []TopDormitory{}

	for rows.Next() {
		var d TopDormitory
		if err := rows.Scan(
			&d.ID,
			&d.Name,
			&d.RatingAverage,
			&d.RatingCount,
		); err != nil {
			return st, err
		}
		st.TopDormitories = append(st.TopDormitories, d)
	}

	return st, rows.Err()
}

// =====================================================
// Dormitory Management
// =====================================================

// DormitoryInput ข้อมูลที่ Admin สามารถเพิ่มหรือแก้ไขได้
type DormitoryInput struct {
	Name         string   `json:"name"`
	MinPrice     float64  `json:"minPrice"`
	MaxPrice     float64  `json:"maxPrice"`
	DormTypeID   int64    `json:"dormTypeId"`
	GenderTypeID int64    `json:"genderTypeId"`
	GoogleMapURL *string  `json:"googleMapUrl"`
	ContactURL   *string  `json:"contactUrl"`
	Description  *string  `json:"description"`
	Images       []string `json:"images"`
}

type DormitoryImpact struct {
	Reviews   int64 `json:"reviews"`
	Ratings   int64 `json:"ratings"`
	Wishlists int64 `json:"wishlists"`
}

type AdminDormitory struct {
	Dormitory
	UpdatedAt *time.Time      `json:"updatedAt"`
	Impact    DormitoryImpact `json:"impact"`
}

// AdminGetDormitory อ่านข้อมูลหอพักสำหรับ Admin
func (s *Store) AdminGetDormitory(
	ctx context.Context,
	id int64,
) (AdminDormitory, error) {
	var result AdminDormitory

	d, err := s.DormitoryByID(ctx, id)
	if err != nil {
		return result, err
	}

	result.Dormitory = d

	err = s.Pool.QueryRow(ctx, `
		SELECT
			d.updated_at,
			(SELECT count(*) FROM dorm_reviews WHERE dorm_id = d.dorm_id),
			(SELECT count(*) FROM dorm_ratings WHERE dorm_id = d.dorm_id),
			(SELECT count(*) FROM dorm_wishlists WHERE dorm_id = d.dorm_id)
		FROM dormitories d
		WHERE d.dorm_id = $1
	`, id).Scan(
		&result.UpdatedAt,
		&result.Impact.Reviews,
		&result.Impact.Ratings,
		&result.Impact.Wishlists,
	)

	return result, err
}

// ListAdminDormitories แสดงหอพักทั้งหมดสำหรับ Admin
func (s *Store) ListAdminDormitories(
	ctx context.Context,
) ([]Dormitory, error) {
	rows, err := s.Pool.Query(ctx, `
		SELECT
			d.dorm_id,
			d.dorm_name,
			d.min_price,
			d.max_price,
			d.dorm_type_id,
			dt.dorm_type_name,
			d.gender_type_id,
			gt.gender_type_name,
			d.google_map_url,
			d.contact_url,
			d.description,
			d.rating_average,
			d.rating_count,
			COALESCE(
				(
					SELECT json_agg(di.image_url ORDER BY di.image_order)
					FROM dorm_images di
					WHERE di.dorm_id = d.dorm_id
				),
				'[]'::json
			)
		FROM dormitories d
		LEFT JOIN dorm_types dt
			ON dt.dorm_type_id = d.dorm_type_id
		LEFT JOIN gender_types gt
			ON gt.gender_type_id = d.gender_type_id
		ORDER BY d.dorm_id DESC
	`)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	items := []Dormitory{}

	for rows.Next() {
		var d Dormitory
		var imagesJSON []byte

		err := rows.Scan(
			&d.ID,
			&d.Name,
			&d.MinPrice,
			&d.MaxPrice,
			&d.DormTypeID,
			&d.DormType,
			&d.GenderTypeID,
			&d.GenderType,
			&d.GoogleMapURL,
			&d.ContactURL,
			&d.Description,
			&d.RatingAverage,
			&d.RatingCount,
			&imagesJSON,
		)
		if err != nil {
			return nil, err
		}

		if err := json.Unmarshal(imagesJSON, &d.Images); err != nil {
			return nil, err
		}

		items = append(items, d)
	}

	return items, rows.Err()
}

// saveDormitoryImages บันทึกรูปภาพหอพัก
func saveDormitoryImages(
	ctx context.Context,
	tx pgx.Tx,
	dormID int64,
	images []string,
) error {
	if len(images) > 4 {
		return ErrBadImages
	}

	_, err := tx.Exec(ctx,
		`DELETE FROM dorm_images WHERE dorm_id = $1`,
		dormID,
	)
	if err != nil {
		return err
	}

	for i, url := range images {
		if url == "" {
			continue
		}

		_, err := tx.Exec(ctx, `
			INSERT INTO dorm_images (dorm_id, image_url, image_order)
			VALUES ($1, $2, $3)
		`, dormID, url, i+1)

		if err != nil {
			return err
		}
	}

	return nil
}

// CreateDormitory เพิ่มหอพัก
func (s *Store) CreateDormitory(
	ctx context.Context,
	in DormitoryInput,
) (AdminDormitory, error) {
	if len(in.Images) > 4 {
		return AdminDormitory{}, ErrBadImages
	}

	tx, err := s.Pool.Begin(ctx)
	if err != nil {
		return AdminDormitory{}, err
	}
	defer tx.Rollback(ctx)

	var id int64

	err = tx.QueryRow(ctx, `
		INSERT INTO dormitories (
			dorm_name,
			min_price,
			max_price,
			dorm_type_id,
			gender_type_id,
			google_map_url,
			contact_url,
			description,
			rating_average,
			rating_count,
			created_at,
			updated_at
		)
		VALUES ($1,$2,$3,$4,$5,$6,$7,$8,0,0,now(),now())
		RETURNING dorm_id
	`,
		in.Name,
		in.MinPrice,
		in.MaxPrice,
		in.DormTypeID,
		in.GenderTypeID,
		in.GoogleMapURL,
		in.ContactURL,
		in.Description,
	).Scan(&id)

	if err != nil {
		return AdminDormitory{}, err
	}

	if err := saveDormitoryImages(ctx, tx, id, in.Images); err != nil {
		return AdminDormitory{}, err
	}

	if err := tx.Commit(ctx); err != nil {
		return AdminDormitory{}, err
	}

	return s.AdminGetDormitory(ctx, id)
}

// UpdateDormitory แก้ไขข้อมูลหอพักและรูปภาพ
func (s *Store) UpdateDormitory(
	ctx context.Context,
	id int64,
	in DormitoryInput,
) (AdminDormitory, error) {
	if len(in.Images) > 4 {
		return AdminDormitory{}, ErrBadImages
	}

	tx, err := s.Pool.Begin(ctx)
	if err != nil {
		return AdminDormitory{}, err
	}
	defer tx.Rollback(ctx)

	tag, err := tx.Exec(ctx, `
		UPDATE dormitories
		SET
			dorm_name = $2,
			min_price = $3,
			max_price = $4,
			dorm_type_id = $5,
			gender_type_id = $6,
			google_map_url = $7,
			contact_url = $8,
			description = $9,
			updated_at = now()
		WHERE dorm_id = $1
	`,
		id,
		in.Name,
		in.MinPrice,
		in.MaxPrice,
		in.DormTypeID,
		in.GenderTypeID,
		in.GoogleMapURL,
		in.ContactURL,
		in.Description,
	)
	if err != nil {
		return AdminDormitory{}, err
	}

	if tag.RowsAffected() == 0 {
		return AdminDormitory{}, ErrNotFound
	}

	if err := saveDormitoryImages(ctx, tx, id, in.Images); err != nil {
		return AdminDormitory{}, err
	}

	if err := tx.Commit(ctx); err != nil {
		return AdminDormitory{}, err
	}

	return s.AdminGetDormitory(ctx, id)
}

// DeleteDormitory ลบหอพักและข้อมูลที่เกี่ยวข้อง
func (s *Store) DeleteDormitory(
	ctx context.Context,
	id int64,
) error {
	tag, err := s.Pool.Exec(ctx,
		`DELETE FROM dormitories WHERE dorm_id = $1`,
		id,
	)
	if err != nil {
		return err
	}

	if tag.RowsAffected() == 0 {
		return ErrNotFound
	}

	// รูปภาพ รีวิว คะแนน และ Wishlist จะถูกลบด้วย CASCADE
	return nil
}

// =====================================================
// Review Management
// =====================================================

type AdminReview struct {
	ID          int64      `json:"id"`
	DormID      int64      `json:"dormId"`
	DormName    string     `json:"dormName"`
	MemberID    int64      `json:"memberId"`
	DisplayName string     `json:"displayName"`
	Rating      int        `json:"rating"`
	Comment     *string    `json:"comment"`
	CreatedAt   *time.Time `json:"createdAt"`
}

// ListAdminReviews แสดงรีวิวทั้งหมด
func (s *Store) ListAdminReviews(
	ctx context.Context,
) ([]AdminReview, error) {
	rows, err := s.Pool.Query(ctx, `
		SELECT
			r.review_id,
			r.dorm_id,
			d.dorm_name,
			r.member_id,
			m.display_name,
			r.rating,
			r.comment,
			r.created_at
		FROM dorm_reviews r
		JOIN dormitories d ON d.dorm_id = r.dorm_id
		JOIN members m ON m.member_id = r.member_id
		ORDER BY r.created_at DESC NULLS LAST, r.review_id DESC
	`)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	items := []AdminReview{}

	for rows.Next() {
		var r AdminReview

		err := rows.Scan(
			&r.ID,
			&r.DormID,
			&r.DormName,
			&r.MemberID,
			&r.DisplayName,
			&r.Rating,
			&r.Comment,
			&r.CreatedAt,
		)
		if err != nil {
			return nil, err
		}

		items = append(items, r)
	}

	return items, rows.Err()
}

// DeleteReview ลบรีวิว
// func (s *Store) DeleteReview(
// 	ctx context.Context,
// 	id int64,
// ) error {
// 	tag, err := s.Pool.Exec(ctx,
// 		`DELETE FROM dorm_reviews WHERE review_id = $1`,
// 		id,
// 	)
// 	if err != nil {
// 		return err
// 	}

// 	if tag.RowsAffected() == 0 {
// 		return ErrNotFound
// 	}

// 	return nil
// }

// =====================================================
// Member Management
// =====================================================

// ListAdminMembers แสดงสมาชิกทั้งหมด
func (s *Store) ListAdminMembers(
	ctx context.Context,
) ([]AdminMember, error) {
	rows, err := s.Pool.Query(ctx, `
		SELECT
			member_id,
			email,
			display_name,
			avatar_url,
			role,
			created_at
		FROM members
		ORDER BY created_at DESC, member_id DESC
	`)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	items := []AdminMember{}

	for rows.Next() {
		var m AdminMember

		err := rows.Scan(
			&m.ID,
			&m.Email,
			&m.DisplayName,
			&m.AvatarURL,
			&m.Role,
			&m.CreatedAt,
		)
		if err != nil {
			return nil, err
		}

		items = append(items, m)
	}

	return items, rows.Err()
}

// UpdateMemberRole เปลี่ยน Role สมาชิก
func (s *Store) UpdateMemberRole(
	ctx context.Context,
	id int64,
	role string,
) error {
	if role != "admin" && role != "user" {
		return ErrBadRole
	}

	tx, err := s.Pool.Begin(ctx)
	if err != nil {
		return err
	}
	defer tx.Rollback(ctx)

	var currentRole string

	err = tx.QueryRow(ctx, `
		SELECT role
		FROM members
		WHERE member_id = $1
		FOR UPDATE
	`, id).Scan(&currentRole)

	if errors.Is(err, pgx.ErrNoRows) {
		return ErrNotFound
	}
	if err != nil {
		return err
	}

	// ป้องกันการลดสิทธิ์ Admin คนสุดท้าย
	if currentRole == "admin" && role != "admin" {
		var count int64

		err = tx.QueryRow(ctx, `
			SELECT count(*)
			FROM members
			WHERE role = 'admin'
		`).Scan(&count)

		if err != nil {
			return err
		}

		if count <= 1 {
			return ErrLastAdmin
		}
	}

	_, err = tx.Exec(ctx, `
		UPDATE members
		SET role = $2,
		    updated_at = now()
		WHERE member_id = $1
	`, id, role)

	if err != nil {
		return err
	}

	return tx.Commit(ctx)
}

// DeleteMember ลบสมาชิก
// ข้อมูลรีวิว คะแนน และ Wishlist จะถูกลบด้วย CASCADE
func (s *Store) DeleteMember(
	ctx context.Context,
	id int64,
) error {
	tag, err := s.Pool.Exec(ctx, `
		DELETE FROM members
		WHERE member_id = $1
		  AND role <> 'admin'
	`, id)

	if err != nil {
		return err
	}

	if tag.RowsAffected() == 0 {
		return ErrNotFound
	}

	return nil
}
