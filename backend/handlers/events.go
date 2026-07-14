package handlers

import (
	"errors"
	"net/http"
	"time"

	"tempo-api/database"
	"tempo-api/models"

	"github.com/gin-gonic/gin"
	"github.com/google/uuid"
)

// ListEvents lista os eventos/tarefas do usuário, com filtros opcionais
// ?taskOnly=true e ?date=YYYY-MM-DD (BACKEND_SPECS.md §4.2).
func ListEvents(c *gin.Context) {
	user, err := currentUser(c)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	query := database.DB.Where("user_id = ?", user.ID)

	if c.Query("taskOnly") == "true" {
		query = query.Where("is_task = ?", true)
	}

	if date := c.Query("date"); date != "" {
		day, err := time.Parse("2006-01-02", date)
		if err != nil {
			c.JSON(http.StatusBadRequest, gin.H{"error": "parâmetro date inválido, use o formato YYYY-MM-DD"})
			return
		}
		query = query.Where("start_date >= ? AND start_date < ?", day, day.Add(24*time.Hour))
	}

	var events []models.Event
	if err := query.Order("start_date asc").Find(&events).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, events)
}

func CreateEvent(c *gin.Context) {
	var event models.Event
	if err := c.ShouldBindJSON(&event); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	if err := validateEventDates(&event); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	user, err := currentUser(c)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}
	event.ID = uuid.Nil
	event.UserID = user.ID

	if err := database.DB.Create(&event).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusCreated, event)
}

func UpdateEvent(c *gin.Context) {
	id, err := uuid.Parse(c.Param("id"))
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "id inválido"})
		return
	}

	var existing models.Event
	if err := database.DB.First(&existing, "id = ?", id).Error; err != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "evento não encontrado"})
		return
	}

	var payload models.Event
	if err := c.ShouldBindJSON(&payload); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	if err := validateEventDates(&payload); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	fields := []string{"Title", "Notes", "Category", "IsAllDay", "StartDate", "EndDate", "IsTask", "IsDone"}
	if err := database.DB.Model(&existing).Select(fields).Updates(payload).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	database.DB.First(&existing, "id = ?", id)
	c.JSON(http.StatusOK, existing)
}

func DeleteEvent(c *gin.Context) {
	id, err := uuid.Parse(c.Param("id"))
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "id inválido"})
		return
	}

	result := database.DB.Delete(&models.Event{}, "id = ?", id)
	if result.Error != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": result.Error.Error()})
		return
	}
	if result.RowsAffected == 0 {
		c.JSON(http.StatusNotFound, gin.H{"error": "evento não encontrado"})
		return
	}

	c.JSON(http.StatusOK, gin.H{"message": "evento removido com sucesso"})
}

// validateEventDates aplica a regra de negócio do BACKEND_SPECS.md §4.1:
// tarefas (isTask=true) podem ter datas nulas; eventos exigem start/end
// válidos, com end não anterior a start.
func validateEventDates(event *models.Event) error {
	if event.IsTask {
		return nil
	}
	if event.StartDate == nil || event.EndDate == nil {
		return errors.New("startDate e endDate são obrigatórios quando isTask=false")
	}
	if event.EndDate.Before(*event.StartDate) {
		return errors.New("endDate não pode ser anterior a startDate")
	}
	return nil
}
