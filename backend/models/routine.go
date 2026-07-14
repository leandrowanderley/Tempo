package models

import (
	"time"

	"github.com/google/uuid"
)

type RoutineType string

const (
	TypeWorkout RoutineType = "workout" // Esportes / Treinos
	TypeHabit   RoutineType = "habit"   // Hábitos pessoais
)

// Routine representa a tabela `routines`: metas semanais que alimentam a
// tela Routine Planner e os anéis de progresso da Home.
type Routine struct {
	ID     uuid.UUID `json:"id" gorm:"type:uuid;primaryKey;default:gen_random_uuid()"`
	UserID uuid.UUID `json:"userId" gorm:"type:uuid;not null;index"`
	User   User      `json:"-" gorm:"foreignKey:UserID;references:ID;constraint:OnDelete:CASCADE"`

	Title string      `json:"title" binding:"required" gorm:"type:varchar(150);not null"`
	Type  RoutineType `json:"type" binding:"required" gorm:"type:varchar(20);not null;check:routines_type_check,type IN ('workout','habit')"`

	TargetCount  int `json:"targetCount" gorm:"not null;default:1;check:routines_target_count_check,target_count >= 1"`
	CurrentCount int `json:"currentCount" gorm:"not null;default:0;check:routines_current_count_check,current_count >= 0"`

	CreatedAt time.Time `json:"createdAt" gorm:"not null;default:now()"`
	UpdatedAt time.Time `json:"updatedAt" gorm:"not null;default:now()"`
}
