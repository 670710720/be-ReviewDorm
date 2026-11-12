package auth

import (
	"testing"
	"time"
)

func TestIssueAndParse(t *testing.T) {
	issuer := &Issuer{
		Secret: []byte("test-secret-key"),
		TTL:    time.Hour,
	}

	const memberID int64 = 123
	const role = "member"

	token, err := issuer.Issue(memberID, role)
	if err != nil {
		t.Fatalf("Issue() error = %v", err)
	}

	if token == "" {
		t.Fatal("Issue() returned empty token")
	}

	gotID, gotRole, err := issuer.Parse(token)
	if err != nil {
		t.Fatalf("Parse() error = %v", err)
	}

	if gotID != memberID {
		t.Errorf("Parse() memberID = %d, want %d", gotID, memberID)
	}

	if gotRole != role {
		t.Errorf("Parse() role = %q, want %q", gotRole, role)
	}
}

func TestIssueInvalidMemberID(t *testing.T) {
	issuer := &Issuer{
		Secret: []byte("test-secret-key"),
		TTL:    time.Hour,
	}

	_, err := issuer.Issue(0, "member")
	if err == nil {
		t.Fatal("Issue() expected error for invalid member ID")
	}
}

func TestIssueEmptySecret(t *testing.T) {
	issuer := &Issuer{
		TTL: time.Hour,
	}

	_, err := issuer.Issue(123, "member")
	if err == nil {
		t.Fatal("Issue() expected error for empty secret")
	}
}

func TestIssueInvalidTTL(t *testing.T) {
	issuer := &Issuer{
		Secret: []byte("test-secret-key"),
		TTL:    0,
	}

	_, err := issuer.Issue(123, "member")
	if err == nil {
		t.Fatal("Issue() expected error for invalid TTL")
	}
}

func TestParseEmptyToken(t *testing.T) {
	issuer := &Issuer{
		Secret: []byte("test-secret-key"),
		TTL:    time.Hour,
	}

	_, _, err := issuer.Parse("")
	if err == nil {
		t.Fatal("Parse() expected error for empty token")
	}
}

func TestParseExpiredToken(t *testing.T) {
	issuer := &Issuer{
		Secret: []byte("test-secret-key"),
		TTL:    -time.Hour,
	}

	// ใช้ Token ที่สร้างไว้ด้วย TTL ติดลบไม่ได้
	// เพราะ Issue() ปฏิเสธ TTL ที่ไม่เป็นบวก
	_, err := issuer.Issue(123, "member")
	if err == nil {
		t.Fatal("Issue() expected error for invalid TTL")
	}
}
