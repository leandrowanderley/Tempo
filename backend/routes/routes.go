package routes

import (
	"net/http"

	"tempo-api/handlers"

	"github.com/gin-gonic/gin"
)

// Setup registra as rotas descritas em BACKEND_SPECS.md §3.
func Setup(router *gin.Engine) {
	router.GET("/ping", func(c *gin.Context) {
		c.JSON(http.StatusOK, gin.H{"message": "pong"})
	})

	v1 := router.Group("/api/v1")
	{
		v1.GET("/profile", handlers.GetProfile)

		v1.GET("/events", handlers.ListEvents)
		v1.POST("/events", handlers.CreateEvent)
		v1.PUT("/events/:id", handlers.UpdateEvent)
		v1.DELETE("/events/:id", handlers.DeleteEvent)

		v1.GET("/routines", handlers.ListRoutines)
		v1.POST("/routines", handlers.CreateRoutine)
		v1.PATCH("/routines/:id/increment", handlers.IncrementRoutine)
		v1.PATCH("/routines/:id/decrement", handlers.DecrementRoutine)

		v1.POST("/integrations/strava/toggle", handlers.ToggleStrava)
	}
}
