package handlers

import (
	"net/http"

	"tempo-api/database"
	"tempo-api/models"

	"github.com/gin-gonic/gin"
	"github.com/google/uuid"
)

func ListRoutines(c *gin.Context) {
	user, err := currentUser()
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	var routines []models.Routine
	if err := database.DB.Where("user_id = ?", user.ID).Find(&routines).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, routines)
}

func CreateRoutine(c *gin.Context) {
	var routine models.Routine
	if err := c.ShouldBindJSON(&routine); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	if routine.Type != models.TypeWorkout && routine.Type != models.TypeHabit {
		c.JSON(http.StatusBadRequest, gin.H{"error": "type deve ser 'workout' ou 'habit'"})
		return
	}

	user, err := currentUser()
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}
	routine.ID = uuid.Nil
	routine.UserID = user.ID

	if err := database.DB.Create(&routine).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusCreated, routine)
}

// IncrementRoutine soma +1 ao currentCount (BACKEND_SPECS.md §4.3).
func IncrementRoutine(c *gin.Context) {
	adjustRoutineCount(c, 1)
}

// DecrementRoutine subtrai 1 do currentCount, nunca abaixo de 0.
func DecrementRoutine(c *gin.Context) {
	adjustRoutineCount(c, -1)
}

func adjustRoutineCount(c *gin.Context, delta int) {
	id, err := uuid.Parse(c.Param("id"))
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "id inválido"})
		return
	}

	var routine models.Routine
	if err := database.DB.First(&routine, "id = ?", id).Error; err != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "rotina não encontrada"})
		return
	}

	newCount := routine.CurrentCount + delta
	if newCount < 0 {
		newCount = 0
	}

	if err := database.DB.Model(&routine).Update("current_count", newCount).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}
	routine.CurrentCount = newCount

	c.JSON(http.StatusOK, routine)
}
