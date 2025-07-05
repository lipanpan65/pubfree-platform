package service

import (
	"context"
	"pubfree-platform/pubfree-server/internal/dto/request"
	"pubfree-platform/pubfree-server/internal/dto/response"
	"pubfree-platform/pubfree-server/internal/model"
	"pubfree-platform/pubfree-server/internal/repository"
)

type GroupService interface {
	CreateGroup(ctx context.Context, userID uint, req *request.CreateGroupRequest) (*response.GroupResponse, error)
	GetGroup(ctx context.Context, id uint) (*response.GroupResponse, error)
	UpdateGroup(ctx context.Context, id uint, req *request.UpdateGroupRequest) (*response.GroupResponse, error)
	DeleteGroup(ctx context.Context, id uint) error
	ListGroups(ctx context.Context, page, pageSize int) ([]*response.GroupResponse, int64, error)
	GetGroupMembers(ctx context.Context, groupID uint) ([]*response.GroupMemberResponse, error)
	AddGroupMember(ctx context.Context, groupID uint, req *request.AddGroupMemberRequest) (*response.GroupMemberResponse, error)
	RemoveGroupMember(ctx context.Context, groupID, userID uint) error
}

type groupService struct {
	groupRepo       repository.GroupRepository
	groupMemberRepo repository.GroupMemberRepository
}

func NewGroupService(groupRepo repository.GroupRepository, groupMemberRepo repository.GroupMemberRepository) GroupService {
	return &groupService{
		groupRepo:       groupRepo,
		groupMemberRepo: groupMemberRepo,
	}
}

func (s *groupService) CreateGroup(ctx context.Context, userID uint, req *request.CreateGroupRequest) (*response.GroupResponse, error) {
	group := &model.Group{
		Name:         req.Name,
		Description:  req.Description,
		OwnerID:      userID,
		CreateUserID: userID,
	}

	if err := s.groupRepo.Create(ctx, group); err != nil {
		return nil, err
	}

	// 自动将创建者添加为成员
	member := &model.GroupMember{
		GroupID: group.ID,
		UserID:  userID,
		Role:    1, // 管理员角色
	}
	_ = s.groupMemberRepo.Create(ctx, member)

	return s.modelToResponse(group), nil
}

func (s *groupService) GetGroup(ctx context.Context, id uint) (*response.GroupResponse, error) {
	group, err := s.groupRepo.GetByID(ctx, id)
	if err != nil {
		return nil, err
	}
	return s.modelToResponse(group), nil
}

func (s *groupService) UpdateGroup(ctx context.Context, id uint, req *request.UpdateGroupRequest) (*response.GroupResponse, error) {
	group, err := s.groupRepo.GetByID(ctx, id)
	if err != nil {
		return nil, err
	}

	if req.Name != "" {
		group.Name = req.Name
	}
	if req.Description != nil {
		group.Description = req.Description
	}

	if err := s.groupRepo.Update(ctx, group); err != nil {
		return nil, err
	}

	return s.modelToResponse(group), nil
}

func (s *groupService) DeleteGroup(ctx context.Context, id uint) error {
	return s.groupRepo.Delete(ctx, id)
}

func (s *groupService) ListGroups(ctx context.Context, page, pageSize int) ([]*response.GroupResponse, int64, error) {
	offset := (page - 1) * pageSize
	groups, err := s.groupRepo.List(ctx, offset, pageSize)
	if err != nil {
		return nil, 0, err
	}

	total, err := s.groupRepo.Count(ctx)
	if err != nil {
		return nil, 0, err
	}

	var responses []*response.GroupResponse
	for _, group := range groups {
		responses = append(responses, s.modelToResponse(group))
	}

	return responses, total, nil
}

func (s *groupService) GetGroupMembers(ctx context.Context, groupID uint) ([]*response.GroupMemberResponse, error) {
	members, err := s.groupMemberRepo.ListByGroupID(ctx, groupID)
	if err != nil {
		return nil, err
	}

	var responses []*response.GroupMemberResponse
	for _, member := range members {
		responses = append(responses, s.memberModelToResponse(member))
	}

	return responses, nil
}

func (s *groupService) AddGroupMember(ctx context.Context, groupID uint, req *request.AddGroupMemberRequest) (*response.GroupMemberResponse, error) {
	member := &model.GroupMember{
		GroupID: groupID,
		UserID:  req.UserID,
		Role:    req.Role,
	}

	if err := s.groupMemberRepo.Create(ctx, member); err != nil {
		return nil, err
	}

	return s.memberModelToResponse(member), nil
}

func (s *groupService) RemoveGroupMember(ctx context.Context, groupID, userID uint) error {
	return s.groupMemberRepo.DeleteByGroupIDAndUserID(ctx, groupID, userID)
}

func (s *groupService) modelToResponse(group *model.Group) *response.GroupResponse {
	resp := &response.GroupResponse{
		ID:           group.ID,
		Name:         group.Name,
		Description:  group.Description,
		OwnerID:      group.OwnerID,
		CreateUserID: group.CreateUserID,
		CreatedAt:    group.CreatedAt,
		UpdatedAt:    group.UpdatedAt,
	}

	if group.Owner.ID != 0 {
		resp.Owner = response.UserResponse{
			ID:        group.Owner.ID,
			Name:      group.Owner.Name,
			CreatedAt: group.Owner.CreatedAt,
			UpdatedAt: group.Owner.UpdatedAt,
		}
	}

	if group.CreateUser.ID != 0 {
		resp.CreateUser = response.UserResponse{
			ID:        group.CreateUser.ID,
			Name:      group.CreateUser.Name,
			CreatedAt: group.CreateUser.CreatedAt,
			UpdatedAt: group.CreateUser.UpdatedAt,
		}
	}

	return resp
}

func (s *groupService) memberModelToResponse(member *model.GroupMember) *response.GroupMemberResponse {
	resp := &response.GroupMemberResponse{
		ID:      member.ID,
		GroupID: member.GroupID,
		UserID:  member.UserID,
		Role:    member.Role,
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
