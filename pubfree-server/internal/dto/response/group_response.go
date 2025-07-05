package response

import "time"

type GroupResponse struct {
	ID           uint         `json:"id"`
	Name         string       `json:"name"`
	Description  *string      `json:"description"`
	OwnerID      uint         `json:"owner_id"`
	CreateUserID uint         `json:"create_user_id"`
	Owner        UserResponse `json:"owner,omitempty"`
	CreateUser   UserResponse `json:"create_user,omitempty"`
	CreatedAt    time.Time    `json:"created_at"`
	UpdatedAt    time.Time    `json:"updated_at"`
}

type GroupMemberResponse struct {
	ID      uint         `json:"id"`
	GroupID uint         `json:"group_id"`
	UserID  uint         `json:"user_id"`
	Role    int8         `json:"role"`
	User    UserResponse `json:"user"`
}
