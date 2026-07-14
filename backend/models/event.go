package models

import (
	"time"

	"github.com/google/uuid"
)

// Event representa a tabela `events`, modelagem unificada de Calendário e
// To-Do List. A flag IsTask diferencia um evento agendado (false) de uma
// tarefa solta sem data, exibida na bandeja "Sem Data" (true).
type Event struct {
	ID     uuid.UUID `json:"id" gorm:"type:uuid;primaryKey;default:gen_random_uuid()"`
	UserID uuid.UUID `json:"userId" gorm:"type:uuid;not null;index:idx_events_user_dates,priority:1"`
	User   User      `json:"-" gorm:"foreignKey:UserID;references:ID;constraint:OnDelete:CASCADE"`

	Title string `json:"title" binding:"required" gorm:"type:varchar(255);not null"`
	Notes string `json:"notes,omitempty" gorm:"type:text"`
	// Category: "Faculdade", "Trabalho", "Treinos", "Habitos".
	Category string `json:"category" gorm:"type:varchar(50);not null;default:'Geral'"`
	IsAllDay bool   `json:"isAllDay" gorm:"not null;default:false"`

	// StartDate/EndDate são nulos quando IsTask == true (tarefa sem data).
	StartDate *time.Time `json:"startDate,omitempty" gorm:"index:idx_events_user_dates,priority:2"`
	EndDate   *time.Time `json:"endDate,omitempty" gorm:"index:idx_events_user_dates,priority:3"`

	IsTask bool `json:"isTask" gorm:"not null;default:false"`
	IsDone bool `json:"isDone" gorm:"not null;default:false"`

	CreatedAt time.Time `json:"createdAt" gorm:"not null;default:now()"`
	UpdatedAt time.Time `json:"updatedAt" gorm:"not null;default:now()"`
}
