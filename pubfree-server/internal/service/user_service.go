package service

import (
	"context"
	"errors"
	"pubfree-platform/pubfree-server/internal/dto/request"
	"pubfree-platform/pubfree-server/internal/dto/response"
	"pubfree-platform/pubfree-server/internal/model"
	"pubfree-platform/pubfree-server/internal/repository"

	"golang.org/x/crypto/bcrypt"
	"gorm.io/gorm"
)

type UserService interface {
	CreateUser(ctx context.Context, req *request.CreateUserRequest) (*response.UserResponse, error)
	GetUser(ctx context.Context, id uint) (*response.UserResponse, error)
	UpdateUser(ctx context.Context, id uint, req *request.UpdateUserRequest) (*response.UserResponse, error)
	DeleteUser(ctx context.Context, id uint) error
	ListUsers(ctx context.Context, page, pageSize int) ([]*response.UserResponse, int64, error)
	Login(ctx context.Context, req *request.LoginRequest) (*response.LoginResponse, error)
}

type userService struct {
	userRepo repository.UserRepository
}

func NewUserService(userRepo repository.UserRepository) UserService {
	return &userService{userRepo: userRepo}
}

func (s *userService) CreateUser(ctx context.Context, req *request.CreateUserRequest) (*response.UserResponse, error) {
	// 检查用户名是否已存在
	if _, err := s.userRepo.GetByName(ctx, req.Name); err == nil {
		return nil, errors.New("用户名已存在")
	}

	// 加密密码
	hashedPassword, err := bcrypt.GenerateFromPassword([]byte(req.Password), bcrypt.DefaultCost)
	if err != nil {
		return nil, err
	}

	user := &model.User{
		Name:     req.Name,
		Password: string(hashedPassword),
	}

	if err := s.userRepo.Create(ctx, user); err != nil {
		return nil, err
	}

	return s.modelToResponse(user), nil
}

func (s *userService) GetUser(ctx context.Context, id uint) (*response.UserResponse, error) {
	user, err := s.userRepo.GetByID(ctx, id)
	if err != nil {
		return nil, err
	}
	return s.modelToResponse(user), nil
}

func (s *userService) UpdateUser(ctx context.Context, id uint, req *request.UpdateUserRequest) (*response.UserResponse, error) {
	user, err := s.userRepo.GetByID(ctx, id)
	if err != nil {
		return nil, err
	}

	if req.Name != "" {
		user.Name = req.Name
	}

	if req.Password != "" {
		hashedPassword, err := bcrypt.GenerateFromPassword([]byte(req.Password), bcrypt.DefaultCost)
		if err != nil {
			return nil, err
		}
		user.Password = string(hashedPassword)
	}

	if err := s.userRepo.Update(ctx, user); err != nil {
		return nil, err
	}

	return s.modelToResponse(user), nil
}

func (s *userService) DeleteUser(ctx context.Context, id uint) error {
	return s.userRepo.Delete(ctx, id)
}

func (s *userService) ListUsers(ctx context.Context, page, pageSize int) ([]*response.UserResponse, int64, error) {
	offset := (page - 1) * pageSize
	users, err := s.userRepo.List(ctx, offset, pageSize)
	if err != nil {
		return nil, 0, err
	}

	total, err := s.userRepo.Count(ctx)
	if err != nil {
		return nil, 0, err
	}

	var responses []*response.UserResponse
	for _, user := range users {
		responses = append(responses, s.modelToResponse(user))
	}

	return responses, total, nil
}

func (s *userService) Login(ctx context.Context, req *request.LoginRequest) (*response.LoginResponse, error) {
	user, err := s.userRepo.GetByName(ctx, req.Name)
	if err != nil {
		if errors.Is(err, gorm.ErrRecordNotFound) {
			return nil, errors.New("用户名或密码错误")
		}
		return nil, err
	}

	if err := bcrypt.CompareHashAndPassword([]byte(user.Password), []byte(req.Password)); err != nil {
		return nil, errors.New("用户名或密码错误")
	}

	// 这里应该生成JWT token，简化示例
	token := "jwt_token_here"

	return &response.LoginResponse{
		Token: token,
		User:  *s.modelToResponse(user),
	}, nil
}

func (s *userService) modelToResponse(user *model.User) *response.UserResponse {
	return &response.UserResponse{
		ID:        user.ID,
		Name:      user.Name,
		CreatedAt: user.CreatedAt,
		UpdatedAt: user.UpdatedAt,
	}
}
