package router

import (
	"pubfree-platform/pubfree-server/internal/handler"

	"github.com/gin-gonic/gin"
)

func SetupGroupRoutes(r *gin.RouterGroup, groupHandler *handler.GroupHandler) {
	groupGroup := r.Group("/groups")
	{
		groupGroup.POST("", groupHandler.CreateGroup)
		groupGroup.GET("/:id", groupHandler.GetGroup)
		groupGroup.PUT("/:id", groupHandler.UpdateGroup)
		groupGroup.DELETE("/:id", groupHandler.DeleteGroup)
		groupGroup.GET("", groupHandler.ListGroups)

		// 空间成员管理
		groupGroup.GET("/:id/members", groupHandler.GetGroupMembers)
		groupGroup.POST("/:id/members", groupHandler.AddGroupMember)
		groupGroup.DELETE("/:id/members/:user_id", groupHandler.RemoveGroupMember)
	}
}
