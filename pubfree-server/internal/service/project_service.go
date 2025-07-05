package service

import (
	"context"
	"errors"
	"pubfree-platform/pubfree-server/internal/dto/request"
	"pubfree-platform/pubfree-server/internal/dto/response"
	"pubfree-platform/pubfree-server/internal/model"
	"pubfree-platform/pubfree-server/internal/repository"
	"strconv"
)

type ProjectService interface {
	CreateProject(ctx context.Context, userID uint, req *request.CreateProjectRequest) (*response.ProjectResponse, error)
	GetProject(ctx context.Context, id uint) (*response.ProjectResponse, error)
	UpdateProject(ctx context.Context, id uint, req *request.UpdateProjectRequest) (*response.ProjectResponse, error)
	DeleteProject(ctx context.Context, id uint) error
	ListProjects(ctx context.Context, groupID string, page, pageSize int) ([]*response.ProjectResponse, int64, error)
	GetProjectMembers(ctx context.Context, projectID uint) ([]*response.ProjectMemberResponse, error)
	AddProjectMember(ctx context.Context, projectID uint, req *request.AddProjectMemberRequest) (*response.ProjectMemberResponse, error)
	RemoveProjectMember(ctx context.Context, projectID, userID uint) error

	// 环境管理
	CreateProjectEnv(ctx context.Context, projectID, userID uint, req *request.CreateProjectEnvRequest) (*response.ProjectEnvResponse, error)
	GetProjectEnvs(ctx context.Context, projectID uint) ([]*response.ProjectEnvResponse, error)

	// 域名管理
	CreateProjectDomain(ctx context.Context, projectID uint, req *request.CreateProjectDomainRequest) (*response.ProjectDomainResponse, error)
	GetProjectDomains(ctx context.Context, projectID uint) ([]*response.ProjectDomainResponse, error)

	// 部署管理
	CreateProjectDeploy(ctx context.Context, projectID, userID uint, req *request.CreateProjectDeployRequest) (*response.ProjectDeployResponse, error)
	GetProjectDeploys(ctx context.Context, projectID uint) ([]*response.ProjectDeployResponse, error)
}

type projectService struct {
	projectRepo       repository.ProjectRepository
	projectMemberRepo repository.ProjectMemberRepository
	projectEnvRepo    repository.ProjectEnvRepository
	projectDomainRepo repository.ProjectDomainRepository
	projectDeployRepo repository.ProjectDeployRepository
}

func NewProjectService(
	projectRepo repository.ProjectRepository,
	projectMemberRepo repository.ProjectMemberRepository,
	projectEnvRepo repository.ProjectEnvRepository,
	projectDomainRepo repository.ProjectDomainRepository,
	projectDeployRepo repository.ProjectDeployRepository,
) ProjectService {
	return &projectService{
		projectRepo:       projectRepo,
		projectMemberRepo: projectMemberRepo,
		projectEnvRepo:    projectEnvRepo,
		projectDomainRepo: projectDomainRepo,
		projectDeployRepo: projectDeployRepo,
	}
}

func (s *projectService) CreateProject(ctx context.Context, userID uint, req *request.CreateProjectRequest) (*response.ProjectResponse, error) {
	// 检查项目名是否已存在
	if _, err := s.projectRepo.GetByName(ctx, req.Name); err == nil {
		return nil, errors.New("项目名已存在")
	}

	project := &model.Project{
		Name:         req.Name,
		ZhName:       req.ZhName,
		Description:  req.Description,
		OwnerID:      userID,
		GroupID:      req.GroupID,
		CreateUserID: userID,
	}

	if err := s.projectRepo.Create(ctx, project); err != nil {
		return nil, err
	}

	// 自动将创建者添加为成员
	member := &model.ProjectMember{
		ProjectID: project.ID,
		UserID:    userID,
		Role:      1, // 管理员角色
	}
	_ = s.projectMemberRepo.Create(ctx, member)

	return s.modelToResponse(project), nil
}

func (s *projectService) GetProject(ctx context.Context, id uint) (*response.ProjectResponse, error) {
	project, err := s.projectRepo.GetByID(ctx, id)
	if err != nil {
		return nil, err
	}
	return s.modelToResponse(project), nil
}

func (s *projectService) UpdateProject(ctx context.Context, id uint, req *request.UpdateProjectRequest) (*response.ProjectResponse, error) {
	project, err := s.projectRepo.GetByID(ctx, id)
	if err != nil {
		return nil, err
	}

	if req.Name != "" {
		project.Name = req.Name
	}
	if req.ZhName != "" {
		project.ZhName = req.ZhName
	}
	if req.Description != nil {
		project.Description = req.Description
	}
	if req.GroupID != nil {
		project.GroupID = req.GroupID
	}

	if err := s.projectRepo.Update(ctx, project); err != nil {
		return nil, err
	}

	return s.modelToResponse(project), nil
}

func (s *projectService) DeleteProject(ctx context.Context, id uint) error {
	return s.projectRepo.Delete(ctx, id)
}

func (s *projectService) ListProjects(ctx context.Context, groupID string, page, pageSize int) ([]*response.ProjectResponse, int64, error) {
	offset := (page - 1) * pageSize
	var projects []*model.Project
	var err error

	if groupID != "" {
		if gid, parseErr := strconv.ParseUint(groupID, 10, 32); parseErr == nil {
			projects, err = s.projectRepo.ListByGroup(ctx, uint(gid), offset, pageSize)
		} else {
			return nil, 0, errors.New("无效的空间ID")
		}
	} else {
		projects, err = s.projectRepo.List(ctx, offset, pageSize)
	}

	if err != nil {
		return nil, 0, err
	}

	total, err := s.projectRepo.Count(ctx)
	if err != nil {
		return nil, 0, err
	}

	var responses []*response.ProjectResponse
	for _, project := range projects {
		responses = append(responses, s.modelToResponse(project))
	}

	return responses, total, nil
}

func (s *projectService) GetProjectMembers(ctx context.Context, projectID uint) ([]*response.ProjectMemberResponse, error) {
	members, err := s.projectMemberRepo.ListByProjectID(ctx, projectID)
	if err != nil {
		return nil, err
	}

	var responses []*response.ProjectMemberResponse
	for _, member := range members {
		responses = append(responses, s.memberModelToResponse(member))
	}

	return responses, nil
}

func (s *projectService) AddProjectMember(ctx context.Context, projectID uint, req *request.AddProjectMemberRequest) (*response.ProjectMemberResponse, error) {
	member := &model.ProjectMember{
		ProjectID: projectID,
		UserID:    req.UserID,
		Role:      req.Role,
	}

	if err := s.projectMemberRepo.Create(ctx, member); err != nil {
		return nil, err
	}

	return s.memberModelToResponse(member), nil
}

func (s *projectService) RemoveProjectMember(ctx context.Context, projectID, userID uint) error {
	return s.projectMemberRepo.DeleteByProjectIDAndUserID(ctx, projectID, userID)
}

func (s *projectService) CreateProjectEnv(ctx context.Context, projectID, userID uint, req *request.CreateProjectEnvRequest) (*response.ProjectEnvResponse, error) {
	env := &model.ProjectEnv{
		ProjectID:    projectID,
		Name:         req.Name,
		EnvType:      req.EnvType,
		CreateUserID: userID,
	}

	if err := s.projectEnvRepo.Create(ctx, env); err != nil {
		return nil, err
	}

	return s.envModelToResponse(env), nil
}

func (s *projectService) GetProjectEnvs(ctx context.Context, projectID uint) ([]*response.ProjectEnvResponse, error) {
	envs, err := s.projectEnvRepo.ListByProjectID(ctx, projectID)
	if err != nil {
		return nil, err
	}

	var responses []*response.ProjectEnvResponse
	for _, env := range envs {
		responses = append(responses, s.envModelToResponse(env))
	}

	return responses, nil
}

func (s *projectService) CreateProjectDomain(ctx context.Context, projectID uint, req *request.CreateProjectDomainRequest) (*response.ProjectDomainResponse, error) {
	domain := &model.ProjectDomain{
		ProjectID:    projectID,
		ProjectEnvID: req.ProjectEnvID,
		Host:         req.Host,
	}

	if err := s.projectDomainRepo.Create(ctx, domain); err != nil {
		return nil, err
	}

	return s.domainModelToResponse(domain), nil
}

func (s *projectService) GetProjectDomains(ctx context.Context, projectID uint) ([]*response.ProjectDomainResponse, error) {
	domains, err := s.projectDomainRepo.ListByProjectID(ctx, projectID)
	if err != nil {
		return nil, err
	}

	var responses []*response.ProjectDomainResponse
	for _, domain := range domains {
		responses = append(responses, s.domainModelToResponse(domain))
	}

	return responses, nil
}

func (s *projectService) CreateProjectDeploy(ctx context.Context, projectID, userID uint, req *request.CreateProjectDeployRequest) (*response.ProjectDeployResponse, error) {
	deploy := &model.ProjectEnvDeploy{
		ProjectID:    projectID,
		ProjectEnvID: req.ProjectEnvID,
		Remark:       req.Remark,
		TargetType:   req.TargetType,
		Target:       req.Target,
		CreateUserID: userID,
		ActionUserID: userID,
	}

	if err := s.projectDeployRepo.Create(ctx, deploy); err != nil {
		return nil, err
	}

	return s.deployModelToResponse(deploy), nil
}

func (s *projectService) GetProjectDeploys(ctx context.Context, projectID uint) ([]*response.ProjectDeployResponse, error) {
	deploys, err := s.projectDeployRepo.ListByProjectID(ctx, projectID)
	if err != nil {
		return nil, err
	}

	var responses []*response.ProjectDeployResponse
	for _, deploy := range deploys {
		responses = append(responses, s.deployModelToResponse(deploy))
	}

	return responses, nil
}

// 模型转换方法
func (s *projectService) modelToResponse(project *model.Project) *response.ProjectResponse {
	resp := &response.ProjectResponse{
		ID:           project.ID,
		Name:         project.Name,
		ZhName:       project.ZhName,
		Description:  project.Description,
		OwnerID:      project.OwnerID,
		GroupID:      project.GroupID,
		CreateUserID: project.CreateUserID,
		CreatedAt:    project.CreatedAt,
		UpdatedAt:    project.UpdatedAt,
	}

	if project.Owner.ID != 0 {
		resp.Owner = response.UserResponse{
			ID:        project.Owner.ID,
			Name:      project.Owner.Name,
			CreatedAt: project.Owner.CreatedAt,
			UpdatedAt: project.Owner.UpdatedAt,
		}
	}

	if project.Group != nil && project.Group.ID != 0 {
		resp.Group = &response.GroupResponse{
			ID:           project.Group.ID,
			Name:         project.Group.Name,
			Description:  project.Group.Description,
			OwnerID:      project.Group.OwnerID,
			CreateUserID: project.Group.CreateUserID,
			CreatedAt:    project.Group.CreatedAt,
			UpdatedAt:    project.Group.UpdatedAt,
		}
	}

	if project.CreateUser.ID != 0 {
		resp.CreateUser = response.UserResponse{
			ID:        project.CreateUser.ID,
			Name:      project.CreateUser.Name,
			CreatedAt: project.CreateUser.CreatedAt,
			UpdatedAt: project.CreateUser.UpdatedAt,
		}
	}

	return resp
}

func (s *projectService) memberModelToResponse(member *model.ProjectMember) *response.ProjectMemberResponse {
	resp := &response.ProjectMemberResponse{
		ID:        member.ID,
		ProjectID: member.ProjectID,
		UserID:    member.UserID,
		Role:      member.Role,
	}

	if member.User.ID != 0 {
		resp.User = response.UserResponse{
			ID:        member.User.ID,
			Name:      member.User.Name,
			CreatedAt: member.User.CreatedAt,
			UpdatedAt: member.User.UpdatedAt,
		}
	}

	return resp
}

func (s *projectService) envModelToResponse(env *model.ProjectEnv) *response.ProjectEnvResponse {
	resp := &response.ProjectEnvResponse{
		ID:           env.ID,
		ProjectID:    env.ProjectID,
		Name:         env.Name,
		EnvType:      env.EnvType,
		CreateUserID: env.CreateUserID,
		CreatedAt:    env.CreatedAt,
		UpdatedAt:    env.UpdatedAt,
	}

	if env.CreateUser.ID != 0 {
		resp.CreateUser = response.UserResponse{
			ID:        env.CreateUser.ID,
			Name:      env.CreateUser.Name,
			CreatedAt: env.CreateUser.CreatedAt,
			UpdatedAt: env.CreateUser.UpdatedAt,
		}
	}

	return resp
}

func (s *projectService) domainModelToResponse(domain *model.ProjectDomain) *response.ProjectDomainResponse {
	return &response.ProjectDomainResponse{
		ID:           domain.ID,
		ProjectID:    domain.ProjectID,
		ProjectEnvID: domain.ProjectEnvID,
		Host:         domain.Host,
		CreatedAt:    domain.CreatedAt,
		UpdatedAt:    domain.UpdatedAt,
	}
}

func (s *projectService) deployModelToResponse(deploy *model.ProjectEnvDeploy) *response.ProjectDeployResponse {
	return &response.ProjectDeployResponse{
		ID:           deploy.ID,
		ProjectID:    deploy.ProjectID,
		ProjectEnvID: deploy.ProjectEnvID,
		Remark:       deploy.Remark,
		TargetType:   deploy.TargetType,
		Target:       deploy.Target,
		CreateUserID: deploy.CreateUserID,
		ActionUserID: deploy.ActionUserID,
		IsActive:     deploy.IsActive,
		CreatedAt:    deploy.CreatedAt,
		UpdatedAt:    deploy.UpdatedAt,
	}
}
