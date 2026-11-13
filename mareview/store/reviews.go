package store

import (
	"context"
	"errors"
	"time"

	"github.com/jackc/pgx/v5/pgconn"
)

var (
	ErrDuplicate      = errors.New("duplicate")
	ErrNoDormitory    = errors.New("dormitory not found")
	ErrInvalidRating  = errors.New("rating must be between 1 and 10")
)

type ReviewAuthor struct {
	ID          int64  `json:"id"`
	DisplayName string `json:"displayName"`
}

type Review struct {
	ID        int64        `json:"id"`
	MemberID  int64        `json:"memberId"`
	DormID    int64        `json:"dormId"`
	Text      string       `json:"text"`
	Rating    int16        `json:"rating"`
	CreatedAt time.Time    `json:"createdAt"`
	Member    ReviewAuthor `json:"member"`
}

// ListReviews แสดงรีวิวทั้งหมดของหอพัก
func (s *Store) ListReviews(ctx context.Context, dormID int64) ([]Review, error) {
	rows, err := s.Pool.Query(ctx,
		`SELECT
			r.review_id,
			r.member_id,
			r.dorm_id,
			r.comment,
			r.rating,
			r.created_at,
			m.display_name
		FROM dorm_reviews r
		JOIN members m ON m.member_id = r.member_id
		WHERE r.dorm_id = $1
		ORDER BY r.created_at DESC`,
		dormID,
	)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	out := []Review{}

	for rows.Next() {
		var r Review

		if err := rows.Scan(
			&r.ID,
			&r.MemberID,
			&r.DormID,
			&r.Text,
			&r.Rating,
			&r.CreatedAt,
			&r.Member.DisplayName,
		); err != nil {
			return nil, err
		}

		r.Member.ID = r.MemberID
		out = append(out, r)
	}

	return out, rows.Err()
}

// AddReview เพิ่มรีวิวหอพัก
func (s *Store) AddReview(
	ctx context.Context,
	memberID, dormID int64,
	text string,
	rating int16,
) (Review, error) {
	// ตรวจสอบคะแนน 1-10
	if rating < 1 || rating > 10 {
		return Review{}, ErrInvalidRating
	}

	r := Review{
		MemberID: memberID,
		DormID:   dormID,
		Text:     text,
		Rating:   rating,
	}

	err := s.Pool.QueryRow(ctx,
		`INSERT INTO dorm_reviews
			(member_id, dorm_id, comment, rating)
		VALUES ($1, $2, $3, $4)
		RETURNING review_id, created_at`,
		memberID,
		dormID,
		text,
		rating,
	).Scan(&r.ID, &r.CreatedAt)

	if err != nil {
		var pgErr *pgconn.PgError
		if errors.As(err, &pgErr) {
			switch pgErr.Code {
			case "23505":
				return Review{}, ErrDuplicate
			case "23503":
				return Review{}, ErrNoDormitory
			case "23514":
				return Review{}, ErrInvalidRating
			}
		}
		return Review{}, err
	}

	return r, nil
}

// DeleteReview ลบรีวิวได้เมื่อเป็นเจ้าของรีวิว หรือเป็นแอดมิน
func (s *Store) DeleteReview(
	ctx context.Context,
	reviewID, memberID int64,
	isAdmin bool,
) error {
	tag, err := s.Pool.Exec(ctx,
		`DELETE FROM dorm_reviews
		WHERE review_id = $1
		AND (member_id = $2 OR $3)`,
		reviewID,
		memberID,
		isAdmin,
	)
	if err != nil {
		return err
	}

	if tag.RowsAffected() == 0 {
		return ErrNotFound
	}

	return nil
}