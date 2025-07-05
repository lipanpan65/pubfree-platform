package request

type CreateUserRequest struct {
	Name     string `json:"name" binding:"required,min=2,max=64"`
	Password string `json:"password" binding:"required,min=6,max=128"`
}

type UpdateUserRequest struct {
	Name     string `json:"name" binding:"omitempty,min=2,max=64"`
	Password string `json:"password" binding:"omitempty,min=6,max=128"`
}

type LoginRequest struct {
	Name     string `json:"name" binding:"required"`
	Password string `json:"password" binding:"required"`
}
