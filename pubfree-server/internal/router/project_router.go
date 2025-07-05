package router

import (
	"pubfree-platform/pubfree-server/internal/handler"

	"github.com/gin-gonic/gin"
)

func SetupProjectRoutes(r *gin.RouterGroup, projectHandler *handler.ProjectHandler) {
	projectGroup := r.Group("/projects")
	{
		projectGroup.POST("", projectHandler.CreateProject)
		projectGroup.GET("/:id", projectHandler.GetProject)
		projectGroup.PUT("/:id", projectHandler.UpdateProject)
		projectGroup.DELETE("/:id", projectHandler.DeleteProject)
		projectGroup.GET("", projectHandler.ListProjects)

		// 项目成员管理
		projectGroup.GET("/:id/members", projectHandler.GetProjectMembers)
		projectGroup.POST("/:id/members", projectHandler.AddProjectMember)
		projectGroup.DELETE("/:id/members/:user_id", projectHandler.RemoveProjectMember)

		// 项目环境管理
		projectGroup.POST("/:id/envs", projectHandler.CreateProjectEnv)
		projectGroup.GET("/:id/envs", projectHandler.GetProjectEnvs)

		// 项目域名管理
		projectGroup.POST("/:id/domains", projectHandler.CreateProjectDomain)
		projectGroup.GET("/:id/domains", projectHandler.GetProjectDomains)

		// 项目部署管理
		projectGroup.POST("/:id/deploys", projectHandler.CreateProjectDeploy)
		projectGroup.GET("/:id/deploys", projectHandler.GetProjectDeploys)
	}
}
