package request

type CreateGroupRequest struct {
	Name        string  `json:"name" binding:"required,min=2,max=128"`
	Description *string `json:"description" binding:"omitempty,max=255"`
}

type UpdateGroupRequest struct {
	Name        string  `json:"name" binding:"omitempty,min=2,max=128"`
	Description *string `json:"description" binding:"omitempty,max=255"`
}

type AddGroupMemberRequest struct {
	UserID uint `json:"user_id" binding:"required"`
	Role   int8 `json:"role" binding:"required,min=1,max=10"`
}
