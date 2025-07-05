package router

import (
	"pubfree-platform/pubfree-server/internal/handler"

	"github.com/gin-gonic/gin"
)

func SetupUserRoutes(r *gin.RouterGroup, userHandler *handler.UserHandler) {
	userGroup := r.Group("/users")
	{
		userGroup.POST("", userHandler.CreateUser)
		userGroup.GET("/:id", userHandler.GetUser)
		userGroup.PUT("/:id", userHandler.UpdateUser)
		userGroup.DELETE("/:id", userHandler.DeleteUser)
		userGroup.GET("", userHandler.ListUsers)
	}

	// 认证相关路由
	authGroup := r.Group("/auth")
	{
		authGroup.POST("/login", userHandler.Login)
	}
}
