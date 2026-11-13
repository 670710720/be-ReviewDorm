package store

import (
	"context"
	"encoding/json"
	"errors"

	"github.com/jackc/pgx/v5/pgconn"
)

// ListWishlist ดึงรายการหอพักที่สมาชิกบันทึกไว้
func (s *Store) ListWishlist(
	ctx context.Context,
	memberID int64,
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
			COALESCE(rs.rating_average, 0)::float8,
			COALESCE(rs.rating_count, 0)::int,
			COALESCE(
				(
					SELECT json_agg(di.image_url ORDER BY di.image_id)
					FROM dorm_images di
					WHERE di.dorm_id = d.dorm_id
				),
				'[]'::json
			) AS images
		FROM dorm_wishlists w
		JOIN dormitories d
			ON d.dorm_id = w.dorm_id
		LEFT JOIN dorm_types dt
			ON dt.dorm_type_id = d.dorm_type_id
		LEFT JOIN gender_types gt
			ON gt.gender_type_id = d.gender_type_id
		LEFT JOIN (
			SELECT
				dorm_id,
				AVG(rating)::float8 AS rating_average,
				COUNT(*) AS rating_count
			FROM dorm_reviews
			GROUP BY dorm_id
		) rs ON rs.dorm_id = d.dorm_id
		WHERE w.member_id = $1
		ORDER BY d.dorm_name ASC
	`, memberID)

	if err != nil {
		return nil, err
	}
	defer rows.Close()

	items := make([]Dormitory, 0)

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

	if err := rows.Err(); err != nil {
		return nil, err
	}

	return items, nil
}

// AddWishlist เพิ่มหอพักลงรายการที่บันทึก
func (s *Store) AddWishlist(
	ctx context.Context,
	memberID int64,
	dormID int64,
) error {
	_, err := s.Pool.Exec(ctx, `
		INSERT INTO dorm_wishlists
			(member_id, dorm_id)
		VALUES ($1, $2)
		ON CONFLICT (member_id, dorm_id) DO NOTHING
	`, memberID, dormID)

	if err != nil {
		var pgErr *pgconn.PgError

		if errors.As(err, &pgErr) && pgErr.Code == "23503" {
			return ErrNoDormitory
		}

		return err
	}

	return nil
}

// RemoveWishlist ลบหอพักออกจากรายการที่บันทึก
func (s *Store) RemoveWishlist(
	ctx context.Context,
	memberID int64,
	dormID int64,
) error {
	_, err := s.Pool.Exec(ctx, `
		DELETE FROM dorm_wishlists
		WHERE member_id = $1
		AND dorm_id = $2
	`, memberID, dormID)

	return err
}
