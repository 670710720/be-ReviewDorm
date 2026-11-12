
package auth

import (
	"errors"
	"strconv"
	"time"

	"github.com/golang-jwt/jwt/v5"
)

// Claims เก็บข้อมูลสมาชิกภายใน JWT
type Claims struct {
	Role string `json:"role"`
	jwt.RegisteredClaims
}

// Issuer ใช้สร้างและตรวจสอบ JWT
type Issuer struct {
	Secret []byte
	TTL    time.Duration
}

// Issue ออก Token ให้สมาชิกหนึ่งคน
func (i *Issuer) Issue(memberID int64, role string) (string, error) {
	if memberID <= 0 {
		return "", errors.New("invalid member ID")
	}

	if len(i.Secret) == 0 {
		return "", errors.New("JWT secret is empty")
	}

	if i.TTL <= 0 {
		return "", errors.New("invalid token TTL")
	}

	now := time.Now()

	claims := Claims{
		Role: role,
		RegisteredClaims: jwt.RegisteredClaims{
			Subject:   strconv.FormatInt(memberID, 10),
			IssuedAt:  jwt.NewNumericDate(now),
			ExpiresAt: jwt.NewNumericDate(now.Add(i.TTL)),
		},
	}

	token := jwt.NewWithClaims(jwt.SigningMethodHS256, claims)

	return token.SignedString(i.Secret)
}

// Parse ตรวจสอบ Token
// ถ้าถูกต้องจะคืนค่า memberID และ role
func (i *Issuer) Parse(tokenString string) (int64, string, error) {
	if len(i.Secret) == 0 {
		return 0, "", errors.New("JWT secret is empty")
	}

	if tokenString == "" {
		return 0, "", errors.New("token is empty")
	}

	var claims Claims

	token, err := jwt.ParseWithClaims(
		tokenString,
		&claims,
		func(t *jwt.Token) (any, error) {
			return i.Secret, nil
		},
		jwt.WithValidMethods([]string{"HS256"}),
		jwt.WithExpirationRequired(),
	)

	if err != nil {
		return 0, "", err
	}

	if token == nil || !token.Valid {
		return 0, "", errors.New("invalid token")
	}

	memberID, err := strconv.ParseInt(claims.Subject, 10, 64)
	if err != nil || memberID <= 0 {
		return 0, "", errors.New("bad subject")
	}

	return memberID, claims.Role, nil
}
