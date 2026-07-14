package handlers

import (
	"net/http"

	"tempo-api/database"

	"github.com/gin-gonic/gin"
)

// ToggleStrava inverte o status stravaConnected do usuário. Mock da Fase 1
// da integração (BACKEND_SPECS.md §5) para a equipe de iOS testar os dois
// estados da tela de Perfil antes do OAuth2 real.
func ToggleStrava(c *gin.Context) {
	user, err := currentUser()
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	newStatus := !user.StravaConnected
	if err := database.DB.Model(user).Update("strava_connected", newStatus).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}
	user.StravaConnected = newStatus

	c.JSON(http.StatusOK, user)
}
