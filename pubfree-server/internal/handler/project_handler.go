package handler

import (
	"net/http"
	"pubfree-platform/pubfree-server/internal/dto/request"
	"pubfree-platform/pubfree-server/internal/service"
	"pubfree-platform/pubfree-server/pkg/utils"
	"strconv"

	"github.com/gin-gonic/gin"
)

type ProjectHandler struct {
	projectService service.ProjectService
}

func NewProjectHandler(projectService service.ProjectService) *ProjectHandler {
	return &ProjectHandler{projectService: projectService}
}

func (h *ProjectHandler) CreateProject(c *gin.Context) {
	var req request.CreateProjectRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		utils.ErrorResponse(c, http.StatusBadRequest, err.Error())
		return
	}

	// 从token中获取用户ID，这里简化处理
	userID := uint(1) // 应该从JWT token中获取

	project, err := h.projectService.CreateProject(c.Request.Context(), userID, &req)
	if err != nil {
		utils.ErrorResponse(c, http.StatusInternalServerError, err.Error())
		return
	}

	utils.SuccessResponse(c, project)
}

func (h *ProjectHandler) GetProject(c *gin.Context) {
	id, err := strconv.ParseUint(c.Param("id"), 10, 32)
	if err != nil {
		utils.ErrorResponse(c, http.StatusBadRequest, "无效的项目ID")
		return
	}

	project, err := h.projectService.GetProject(c.Request.Context(), uint(id))
	if err != nil {
		utils.ErrorResponse(c, http.StatusNotFound, err.Error())
		return
	}

	utils.SuccessResponse(c, project)
}

func (h *ProjectHandler) UpdateProject(c *gin.Context) {
	id, err := strconv.ParseUint(c.Param("id"), 10, 32)
	if err != nil {
		utils.ErrorResponse(c, http.StatusBadRequest, "无效的项目ID")
		return
	}

	var req request.UpdateProjectRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		utils.ErrorResponse(c, http.StatusBadRequest, err.Error())
		return
	}

	project, err := h.projectService.UpdateProject(c.Request.Context(), uint(id), &req)
	if err != nil {
		utils.ErrorResponse(c, http.StatusInternalServerError, err.Error())
		return
	}

	utils.SuccessResponse(c, project)
}

func (h *ProjectHandler) DeleteProject(c *gin.Context) {
	id, err := strconv.ParseUint(c.Param("id"), 10, 32)
	if err != nil {
		utils.ErrorResponse(c, http.StatusBadRequest, "无效的项目ID")
		return
	}

	if err := h.projectService.DeleteProject(c.Request.Context(), uint(id)); err != nil {
		utils.ErrorResponse(c, http.StatusInternalServerError, err.Error())
		return
	}

	utils.SuccessResponse(c, nil)
}

func (h *ProjectHandler) ListProjects(c *gin.Context) {
	page, _ := strconv.Atoi(c.DefaultQuery("page", "1"))
	pageSize, _ := strconv.Atoi(c.DefaultQuery("page_size", "10"))

	// 可以根据group_id过滤
	groupID := c.Query("group_id")

	projects, total, err := h.projectService.ListProjects(c.Request.Context(), groupID, page, pageSize)
	if err != nil {
		utils.ErrorResponse(c, http.StatusInternalServerError, err.Error())
		return
	}

	utils.SuccessResponseWithPagination(c, projects, total, page, pageSize)
}

func (h *ProjectHandler) GetProjectMembers(c *gin.Context) {
	id, err := strconv.ParseUint(c.Param("id"), 10, 32)
	if err != nil {
		utils.ErrorResponse(c, http.StatusBadRequest, "无效的项目ID")
		return
	}

	members, err := h.projectService.GetProjectMembers(c.Request.Context(), uint(id))
	if err != nil {
		utils.ErrorResponse(c, http.StatusInternalServerError, err.Error())
		return
	}

	utils.SuccessResponse(c, members)
}

func (h *ProjectHandler) AddProjectMember(c *gin.Context) {
	id, err := strconv.ParseUint(c.Param("id"), 10, 32)
	if err != nil {
		utils.ErrorResponse(c, http.StatusBadRequest, "无效的项目ID")
		return
	}

	var req request.AddProjectMemberRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		utils.ErrorResponse(c, http.StatusBadRequest, err.Error())
		return
	}

	member, err := h.projectService.AddProjectMember(c.Request.Context(), uint(id), &req)
	if err != nil {
		utils.ErrorResponse(c, http.StatusInternalServerError, err.Error())
		return
	}

	utils.SuccessResponse(c, member)
}

func (h *ProjectHandler) RemoveProjectMember(c *gin.Context) {
	id, err := strconv.ParseUint(c.Param("id"), 10, 32)
	if err != nil {
		utils.ErrorResponse(c, http.StatusBadRequest, "无效的项目ID")
		return
	}

	userID, err := strconv.ParseUint(c.Param("user_id"), 10, 32)
	if err != nil {
		utils.ErrorResponse(c, http.StatusBadRequest, "无效的用户ID")
		return
	}

	if err := h.projectService.RemoveProjectMember(c.Request.Context(), uint(id), uint(userID)); err != nil {
		utils.ErrorResponse(c, http.StatusInternalServerError, err.Error())
		return
	}

	utils.SuccessResponse(c, nil)
}

// 项目环境相关
func (h *ProjectHandler) CreateProjectEnv(c *gin.Context) {
	id, err := strconv.ParseUint(c.Param("id"), 10, 32)
	if err != nil {
		utils.ErrorResponse(c, http.StatusBadRequest, "无效的项目ID")
		return
	}

	var req request.CreateProjectEnvRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		utils.ErrorResponse(c, http.StatusBadRequest, err.Error())
		return
	}

	// 从token中获取用户ID
	userID := uint(1)

	env, err := h.projectService.CreateProjectEnv(c.Request.Context(), uint(id), userID, &req)
	if err != nil {
		utils.ErrorResponse(c, http.StatusInternalServerError, err.Error())
		return
	}

	utils.SuccessResponse(c, env)
}

func (h *ProjectHandler) GetProjectEnvs(c *gin.Context) {
	id, err := strconv.ParseUint(c.Param("id"), 10, 32)
	if err != nil {
		utils.ErrorResponse(c, http.StatusBadRequest, "无效的项目ID")
		return
	}

	envs, err := h.projectService.GetProjectEnvs(c.Request.Context(), uint(id))
	if err != nil {
		utils.ErrorResponse(c, http.StatusInternalServerError, err.Error())
		return
	}

	utils.SuccessResponse(c, envs)
}

// 项目域名相关
func (h *ProjectHandler) CreateProjectDomain(c *gin.Context) {
	id, err := strconv.ParseUint(c.Param("id"), 10, 32)
	if err != nil {
		utils.ErrorResponse(c, http.StatusBadRequest, "无效的项目ID")
		return
	}

	var req request.CreateProjectDomainRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		utils.ErrorResponse(c, http.StatusBadRequest, err.Error())
		return
	}

	domain, err := h.projectService.CreateProjectDomain(c.Request.Context(), uint(id), &req)
	if err != nil {
		utils.ErrorResponse(c, http.StatusInternalServerError, err.Error())
		return
	}

	utils.SuccessResponse(c, domain)
}

func (h *ProjectHandler) GetProjectDomains(c *gin.Context) {
	id, err := strconv.ParseUint(c.Param("id"), 10, 32)
	if err != nil {
		utils.ErrorResponse(c, http.StatusBadRequest, "无效的项目ID")
		return
	}

	domains, err := h.projectService.GetProjectDomains(c.Request.Context(), uint(id))
	if err != nil {
		utils.ErrorResponse(c, http.StatusInternalServerError, err.Error())
		return
	}

	utils.SuccessResponse(c, domains)
}

// 项目部署相关
func (h *ProjectHandler) CreateProjectDeploy(c *gin.Context) {
	id, err := strconv.ParseUint(c.Param("id"), 10, 32)
	if err != nil {
		utils.ErrorResponse(c, http.StatusBadRequest, "无效的项目ID")
		return
	}

	var req request.CreateProjectDeployRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		utils.ErrorResponse(c, http.StatusBadRequest, err.Error())
		return
	}

	// 从token中获取用户ID
	userID := uint(1)

	deploy, err := h.projectService.CreateProjectDeploy(c.Request.Context(), uint(id), userID, &req)
	if err != nil {
		utils.ErrorResponse(c, http.StatusInternalServerError, err.Error())
		return
	}

	utils.SuccessResponse(c, deploy)
}

func (h *ProjectHandler) GetProjectDeploys(c *gin.Context) {
	id, err := strconv.ParseUint(c.Param("id"), 10, 32)
	if err != nil {
		utils.ErrorResponse(c, http.StatusBadRequest, "无效的项目ID")
		return
	}

	deploys, err := h.projectService.GetProjectDeploys(c.Request.Context(), uint(id))
	if err != nil {
		utils.ErrorResponse(c, http.StatusInternalServerError, err.Error())
		return
	}

	utils.SuccessResponse(c, deploys)
}
