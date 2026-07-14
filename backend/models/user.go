package models

import (
	"time"

	"github.com/google/uuid"
)

// User representa a tabela `users`: perfil do usuário e status das
// integrações externas (Strava, Apple Health).
type User struct {
	ID    uuid.UUID `json:"id" gorm:"type:uuid;primaryKey;default:gen_random_uuid()"`
	Name  string    `json:"name" gorm:"type:varchar(150);not null"`
	Email string    `json:"email" gorm:"type:varchar(255);not null;uniqueIndex"`
	// PasswordHash é nulo quando o usuário se autentica via OAuth/Supabase Auth.
	PasswordHash *string    `json:"-" gorm:"type:varchar(255)"`
	BirthDate    *time.Time `json:"birthDate,omitempty" gorm:"type:date"`

	StravaConnected bool `json:"stravaConnected" gorm:"not null;default:false"`
	AppleConnected  bool `json:"appleConnected" gorm:"not null;default:true"`

	StravaAthleteID      *string    `json:"-" gorm:"type:varchar(100)"`
	StravaAccessToken    *string    `json:"-" gorm:"type:text"`
	StravaRefreshToken   *string    `json:"-" gorm:"type:text"`
	StravaTokenExpiresAt *time.Time `json:"-"`

	CreatedAt time.Time `json:"createdAt" gorm:"not null;default:now()"`
	UpdatedAt time.Time `json:"updatedAt" gorm:"not null;default:now()"`
}
