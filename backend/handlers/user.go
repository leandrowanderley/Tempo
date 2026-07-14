package handlers

import (
	"errors"

	"tempo-api/database"
	"tempo-api/models"

	"github.com/gin-gonic/gin"
	"github.com/google/uuid"
	"gorm.io/gorm"
)

// currentUser resolve o usuário autenticado a partir do "userID" injetado
// por middleware.RequireAuth (claim "sub" do JWT do Supabase Auth) e cria a
// linha correspondente em public.users no primeiro request autenticado,
// usando o mesmo id do Supabase Auth como chave primária.
func currentUser(c *gin.Context) (*models.User, error) {
	id, err := uuid.Parse(c.GetString("userID"))
	if err != nil {
		return nil, err
	}

	var user models.User
	err = database.DB.First(&user, "id = ?", id).Error
	if err == nil {
		return &user, nil
	}
	if !errors.Is(err, gorm.ErrRecordNotFound) {
		return nil, err
	}

	user = models.User{
		ID:    id,
		Email: c.GetString("userEmail"),
		Name:  "Novo Usuário",
	}
	if err := database.DB.Create(&user).Error; err != nil {
		return nil, err
	}
	return &user, nil
}
