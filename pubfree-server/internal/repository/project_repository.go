package repository

import (
	"context"
	"pubfree-platform/pubfree-server/internal/model"

	"gorm.io/gorm"
)

type ProjectRepository interface {
	Create(ctx context.Context, project *model.Project) error
	GetByID(ctx context.Context, id uint) (*model.Project, error)
	GetByName(ctx context.Context, name string) (*model.Project, error)
	Update(ctx context.Context, project *model.Project) error
	Delete(ctx context.Context, id uint) error
	List(ctx context.Context, offset, limit int) ([]*model.Project, error)
	ListByGroup(ctx context.Context, groupID uint, offset, limit int) ([]*model.Project, error)
	ListByOwner(ctx context.Context, ownerID uint, offset, limit int) ([]*model.Project, error)
	Count(ctx context.Context) (int64, error)
}

type projectRepository struct {
	db *gorm.DB
}

func NewProjectRepository(db *gorm.DB) ProjectRepository {
	return &projectRepository{db: db}
}

func (r *projectRepository) Create(ctx context.Context, project *model.Project) error {
	return r.db.WithContext(ctx).Create(project).Error
}

func (r *projectRepository) GetByID(ctx context.Context, id uint) (*model.Project, error) {
	var project model.Project
	err := r.db.WithContext(ctx).
		Where("is_del = 0").
		Preload("Owner").
		Preload("Group").
		Preload("CreateUser").
		First(&project, id).Error
	return &project, err
}

func (r *projectRepository) GetByName(ctx context.Context, name string) (*model.Project, error) {
	var project model.Project
	err := r.db.WithContext(ctx).
		Where("name = ? AND is_del = 0", name).
		Preload("Owner").
		Preload("Group").
		Preload("CreateUser").
		First(&project).Error
	return &project, err
}

func (r *projectRepository) Update(ctx context.Context, project *model.Project) error {
	return r.db.WithContext(ctx).Save(project).Error
}

func (r *projectRepository) Delete(ctx context.Context, id uint) error {
	return r.db.WithContext(ctx).Model(&model.Project{}).Where("id = ?", id).Update("is_del", 1).Error
}

func (r *projectRepository) List(ctx context.Context, offset, limit int) ([]*model.Project, error) {
	var projects []*model.Project
	err := r.db.WithContext(ctx).
		Where("is_del = 0").
		Preload("Owner").
		Preload("Group").
		Preload("CreateUser").
		Offset(offset).
		Limit(limit).
		Find(&projects).Error
	return projects, err
}

func (r *projectRepository) ListByGroup(ctx context.Context, groupID uint, offset, limit int) ([]*model.Project, error) {
	var projects []*model.Project
	err := r.db.WithContext(ctx).
		Where("group_id = ? AND is_del = 0", groupID).
		Preload("Owner").
		Preload("Group").
		Preload("CreateUser").
		Offset(offset).
		Limit(limit).
		Find(&projects).Error
	return projects, err
}

func (r *projectRepository) ListByOwner(ctx context.Context, ownerID uint, offset, limit int) ([]*model.Project, error) {
	var projects []*model.Project
	err := r.db.WithContext(ctx).
		Where("owner_id = ? AND is_del = 0", ownerID).
		Preload("Owner").
		Preload("Group").
		Preload("CreateUser").
		Offset(offset).
		Limit(limit).
		Find(&projects).Error
	return projects, err
}

func (r *projectRepository) Count(ctx context.Context) (int64, error) {
	var count int64
	err := r.db.WithContext(ctx).Model(&model.Project{}).Where("is_del = 0").Count(&count).Error
	return count, err
}

// 新增的Repository接口
type GroupMemberRepository interface {
	Create(ctx context.Context, member *model.GroupMember) error
	GetByID(ctx context.Context, id uint) (*model.GroupMember, error)
	ListByGroupID(ctx context.Context, groupID uint) ([]*model.GroupMember, error)
	DeleteByGroupIDAndUserID(ctx context.Context, groupID, userID uint) error
}

type groupMemberRepository struct {
	db *gorm.DB
}

func NewGroupMemberRepository(db *gorm.DB) GroupMemberRepository {
	return &groupMemberRepository{db: db}
}

func (r *groupMemberRepository) Create(ctx context.Context, member *model.GroupMember) error {
	return r.db.WithContext(ctx).Create(member).Error
}

func (r *groupMemberRepository) GetByID(ctx context.Context, id uint) (*model.GroupMember, error) {
	var member model.GroupMember
	err := r.db.WithContext(ctx).
		Where("is_del = 0").
		Preload("User").
		First(&member, id).Error
	return &member, err
}

func (r *groupMemberRepository) ListByGroupID(ctx context.Context, groupID uint) ([]*model.GroupMember, error) {
	var members []*model.GroupMember
	err := r.db.WithContext(ctx).
		Where("group_id = ? AND is_del = 0", groupID).
		Preload("User").
		Find(&members).Error
	return members, err
}

func (r *groupMemberRepository) DeleteByGroupIDAndUserID(ctx context.Context, groupID, userID uint) error {
	return r.db.WithContext(ctx).
		Model(&model.GroupMember{}).
		Where("group_id = ? AND user_id = ?", groupID, userID).
		Update("is_del", 1).Error
}

// 项目成员Repository
type ProjectMemberRepository interface {
	Create(ctx context.Context, member *model.ProjectMember) error
	GetByID(ctx context.Context, id uint) (*model.ProjectMember, error)
	ListByProjectID(ctx context.Context, projectID uint) ([]*model.ProjectMember, error)
	DeleteByProjectIDAndUserID(ctx context.Context, projectID, userID uint) error
}

type projectMemberRepository struct {
	db *gorm.DB
}

func NewProjectMemberRepository(db *gorm.DB) ProjectMemberRepository {
	return &projectMemberRepository{db: db}
}

func (r *projectMemberRepository) Create(ctx context.Context, member *model.ProjectMember) error {
	return r.db.WithContext(ctx).Create(member).Error
}

func (r *projectMemberRepository) GetByID(ctx context.Context, id uint) (*model.ProjectMember, error) {
	var member model.ProjectMember
	err := r.db.WithContext(ctx).
		Where("is_del = 0").
		Preload("User").
		First(&member, id).Error
	return &member, err
}

func (r *projectMemberRepository) ListByProjectID(ctx context.Context, projectID uint) ([]*model.ProjectMember, error) {
	var members []*model.ProjectMember
	err := r.db.WithContext(ctx).
		Where("project_id = ? AND is_del = 0", projectID).
		Preload("User").
		Find(&members).Error
	return members, err
}

func (r *projectMemberRepository) DeleteByProjectIDAndUserID(ctx context.Context, projectID, userID uint) error {
	return r.db.WithContext(ctx).
		Model(&model.ProjectMember{}).
		Where("project_id = ? AND user_id = ?", projectID, userID).
		Update("is_del", 1).Error
}

// 项目环境Repository
type ProjectEnvRepository interface {
	Create(ctx context.Context, env *model.ProjectEnv) error
	GetByID(ctx context.Context, id uint) (*model.ProjectEnv, error)
	ListByProjectID(ctx context.Context, projectID uint) ([]*model.ProjectEnv, error)
	Delete(ctx context.Context, id uint) error
}

type projectEnvRepository struct {
	db *gorm.DB
}

func NewProjectEnvRepository(db *gorm.DB) ProjectEnvRepository {
	return &projectEnvRepository{db: db}
}

func (r *projectEnvRepository) Create(ctx context.Context, env *model.ProjectEnv) error {
	return r.db.WithContext(ctx).Create(env).Error
}

func (r *projectEnvRepository) GetByID(ctx context.Context, id uint) (*model.ProjectEnv, error) {
	var env model.ProjectEnv
	err := r.db.WithContext(ctx).
		Where("is_del = 0").
		Preload("CreateUser").
		First(&env, id).Error
	return &env, err
}

func (r *projectEnvRepository) ListByProjectID(ctx context.Context, projectID uint) ([]*model.ProjectEnv, error) {
	var envs []*model.ProjectEnv
	err := r.db.WithContext(ctx).
		Where("project_id = ? AND is_del = 0", projectID).
		Preload("CreateUser").
		Find(&envs).Error
	return envs, err
}

func (r *projectEnvRepository) Delete(ctx context.Context, id uint) error {
	return r.db.WithContext(ctx).Model(&model.ProjectEnv{}).Where("id = ?", id).Update("is_del", 1).Error
}

// 项目域名Repository
type ProjectDomainRepository interface {
	Create(ctx context.Context, domain *model.ProjectDomain) error
	GetByID(ctx context.Context, id uint) (*model.ProjectDomain, error)
	ListByProjectID(ctx context.Context, projectID uint) ([]*model.ProjectDomain, error)
	Delete(ctx context.Context, id uint) error
}

type projectDomainRepository struct {
	db *gorm.DB
}

func NewProjectDomainRepository(db *gorm.DB) ProjectDomainRepository {
	return &projectDomainRepository{db: db}
}

func (r *projectDomainRepository) Create(ctx context.Context, domain *model.ProjectDomain) error {
	return r.db.WithContext(ctx).Create(domain).Error
}

func (r *projectDomainRepository) GetByID(ctx context.Context, id uint) (*model.ProjectDomain, error) {
	var domain model.ProjectDomain
	err := r.db.WithContext(ctx).
		Where("is_del = 0").
		First(&domain, id).Error
	return &domain, err
}

func (r *projectDomainRepository) ListByProjectID(ctx context.Context, projectID uint) ([]*model.ProjectDomain, error) {
	var domains []*model.ProjectDomain
	err := r.db.WithContext(ctx).
		Where("project_id = ? AND is_del = 0", projectID).
		Find(&domains).Error
	return domains, err
}

func (r *projectDomainRepository) Delete(ctx context.Context, id uint) error {
	return r.db.WithContext(ctx).Model(&model.ProjectDomain{}).Where("id = ?", id).Update("is_del", 1).Error
}

// 项目部署Repository
type ProjectDeployRepository interface {
	Create(ctx context.Context, deploy *model.ProjectEnvDeploy) error
	GetByID(ctx context.Context, id uint) (*model.ProjectEnvDeploy, error)
	ListByProjectID(ctx context.Context, projectID uint) ([]*model.ProjectEnvDeploy, error)
	Delete(ctx context.Context, id uint) error
}

type projectDeployRepository struct {
	db *gorm.DB
}

func NewProjectDeployRepository(db *gorm.DB) ProjectDeployRepository {
	return &projectDeployRepository{db: db}
}

func (r *projectDeployRepository) Create(ctx context.Context, deploy *model.ProjectEnvDeploy) error {
	return r.db.WithContext(ctx).Create(deploy).Error
}

func (r *projectDeployRepository) GetByID(ctx context.Context, id uint) (*model.ProjectEnvDeploy, error) {
	var deploy model.ProjectEnvDeploy
	err := r.db.WithContext(ctx).
		Where("is_del = 0").
		First(&deploy, id).Error
	return &deploy, err
}

func (r *projectDeployRepository) ListByProjectID(ctx context.Context, projectID uint) ([]*model.ProjectEnvDeploy, error) {
	var deploys []*model.ProjectEnvDeploy
	err := r.db.WithContext(ctx).
		Where("project_id = ? AND is_del = 0", projectID).
		Find(&deploys).Error
	return deploys, err
}

func (r *projectDeployRepository) Delete(ctx context.Context, id uint) error {
	return r.db.WithContext(ctx).Model(&model.ProjectEnvDeploy{}).Where("id = ?", id).Update("is_del", 1).Error
}
