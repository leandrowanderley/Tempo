package handlers

import (
	"errors"

	"tempo-api/database"
	"tempo-api/models"

	"gorm.io/gorm"
)

// currentUser retorna o único usuário do MVP, criando-o na primeira chamada.
// TODO: substituir por autenticação real quando o fluxo de login for definido
// (nenhum endpoint de auth está previsto no BACKEND_SPECS.md para este sprint).
func currentUser() (*models.User, error) {
	var user models.User
	err := database.DB.First(&user).Error
	if err == nil {
		return &user, nil
	}
	if !errors.Is(err, gorm.ErrRecordNotFound) {
		return nil, err
	}

	user = models.User{
		Name:  "Usuário Tempo",
		Email: "usuario@tempo.app",
	}
	if err := database.DB.Create(&user).Error; err != nil {
		return nil, err
	}
	return &user, nil
}
