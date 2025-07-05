package router

import (
	"pubfree-platform/pubfree-server/internal/handler"
	"pubfree-platform/pubfree-server/internal/repository"
	"pubfree-platform/pubfree-server/internal/service"

	"github.com/gin-gonic/gin"
	"gorm.io/gorm"
)

func SetupRouter(db *gorm.DB) *gin.Engine {
	r := gin.Default()

	// 初始化repositories
	userRepo := repository.NewUserRepository(db)
	groupRepo := repository.NewGroupRepository(db)
	groupMemberRepo := repository.NewGroupMemberRepository(db)
	projectRepo := repository.NewProjectRepository(db)
	projectMemberRepo := repository.NewProjectMemberRepository(db)
	projectEnvRepo := repository.NewProjectEnvRepository(db)
	projectDomainRepo := repository.NewProjectDomainRepository(db)
	projectDeployRepo := repository.NewProjectDeployRepository(db)

	// 初始化services
	userService := service.NewUserService(userRepo)
	groupService := service.NewGroupService(groupRepo, groupMemberRepo)
	projectService := service.NewProjectService(projectRepo, projectMemberRepo, projectEnvRepo, projectDomainRepo, projectDeployRepo)

	// 初始化handlers
	userHandler := handler.NewUserHandler(userService)
	groupHandler := handler.NewGroupHandler(groupService)
	projectHandler := handler.NewProjectHandler(projectService)

	// 设置路由
	api := r.Group("/api/v1")
	{
		SetupUserRoutes(api, userHandler)
		SetupGroupRoutes(api, groupHandler)
		SetupProjectRoutes(api, projectHandler)
	}

	return r
}
