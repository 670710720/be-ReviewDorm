package store

import "context"

// TypeItem ข้อมูลประเภทสำหรับแสดงใน Select
type TypeItem struct {
    ID   int64  `json:"id"`
    Name string `json:"name"`
}

// ListDormitoryTypes ดึงประเภทหอพักทั้งหมด
func (s *Store) ListDormitoryTypes(ctx context.Context) ([]TypeItem, error) {
    rows, err := s.Pool.Query(ctx, `
        SELECT dorm_type_id, dorm_type_name
        FROM dorm_types
        ORDER BY dorm_type_id
    `)
    if err != nil {
        return nil, err
    }
    defer rows.Close()

    items := make([]TypeItem, 0)

    for rows.Next() {
        var item TypeItem

        if err := rows.Scan(&item.ID, &item.Name); err != nil {
            return nil, err
        }

        items = append(items, item)
    }

    if err := rows.Err(); err != nil {
        return nil, err
    }

    return items, nil
}

// ListGenderTypes ดึงประเภทผู้พักทั้งหมด
func (s *Store) ListGenderTypes(ctx context.Context) ([]TypeItem, error) {
    rows, err := s.Pool.Query(ctx, `
        SELECT gender_type_id, gender_type_name
        FROM gender_types
        ORDER BY gender_type_id
    `)
    if err != nil {
        return nil, err
    }
    defer rows.Close()

    items := make([]TypeItem, 0)

    for rows.Next() {
        var item TypeItem

        if err := rows.Scan(&item.ID, &item.Name); err != nil {
            return nil, err
        }

        items = append(items, item)
    }

    if err := rows.Err(); err != nil {
        return nil, err
    }

    return items, nil
}