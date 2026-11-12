
package auth

import "golang.org/x/crypto/bcrypt"

// HashPassword แปลงรหัสผ่านเป็น bcrypt hash
// เพื่อจัดเก็บลงฐานข้อมูลโดยไม่เก็บรหัสผ่านจริง
func HashPassword(plain string) (string, error) {
	hash, err := bcrypt.GenerateFromPassword(
		[]byte(plain),
		bcrypt.DefaultCost,
	)
	if err != nil {
		return "", err
	}

	return string(hash), nil
}

// CheckPassword ตรวจสอบว่ารหัสผ่านตรงกับ bcrypt hash หรือไม่
func CheckPassword(hash, plain string) bool {
	err := bcrypt.CompareHashAndPassword(
		[]byte(hash),
		[]byte(plain),
	)

	return err == nil
}
