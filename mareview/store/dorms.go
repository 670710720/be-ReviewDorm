package store

import "context"

// Dormitory ข้อมูลหอพัก
type Dormitory struct {
	ID          int64    `json:"id"`
	Name        string   `json:"name"`
	MinPrice    float64  `json:"minPrice"`
	MaxPrice    float64  `json:"maxPrice"`
	DormTypeID  int64    `json:"dormTypeId"`
	DormType    *string  `json:"dormType"`
	GenderTypeID int64   `json:"genderTypeId"`
	GenderType  *string  `json:"genderType"`
	GoogleMapURL *string `json:"googleMapUrl"`
	ContactURL   *string `json:"contactUrl"`
	Description  *string `json:"description"`
	RatingAverage float64 `json:"ratingAverage"`
	RatingCount   int     `json:"ratingCount"`
	Images        []string `json:"images"`
}

// SearchDormitories ค้นหาหอพักด้วยชื่อ โดยใช้ $1 แยกจากคำสั่ง SQL
func (s *Store) SearchDormitories(ctx context.Context, q string) ([]Dormitory, error) {
	rows, err := s.Pool.Query(ctx,
		`SELECT
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
			d.rating_count
		FROM dormitories d
		LEFT JOIN dorm_types dt ON dt.dorm_type_id = d.dorm_type_id
		LEFT JOIN gender_types gt ON gt.gender_type_id = d.gender_type_id
		WHERE lower(d.dorm_name) LIKE '%' || lower($1) || '%'
		ORDER BY d.rating_average DESC, d.dorm_name ASC`,
		q,
	)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	out := []Dormitory{}

	for rows.Next() {
		var d Dormitory

		if err := rows.Scan(
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
		); err != nil {
			return nil, err
		}

		d.Images = []string{}
		out = append(out, d)
	}

	if err := rows.Err(); err != nil {
		return nil, err
	}

	return out, nil
}