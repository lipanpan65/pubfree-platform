package response

import "time"

type ProjectResponse struct {
	ID           uint           `json:"id"`
	Name         string         `json:"name"`
	ZhName       string         `json:"zh_name"`
	Description  *string        `json:"description"`
	OwnerID      uint           `json:"owner_id"`
	GroupID      *uint          `json:"group_id"`
	CreateUserID uint           `json:"create_user_id"`
	Owner        UserResponse   `json:"owner,omitempty"`
	Group        *GroupResponse `json:"group,omitempty"`
	CreateUser   UserResponse   `json:"create_user,omitempty"`
	CreatedAt    time.Time      `json:"created_at"`
	UpdatedAt    time.Time      `json:"updated_at"`
}

type ProjectMemberResponse struct {
	ID        uint         `json:"id"`
	ProjectID uint         `json:"project_id"`
	UserID    uint         `json:"user_id"`
	Role      int8         `json:"role"`
	User      UserResponse `json:"user"`
	CreatedAt time.Time    `json:"created_at"`
	UpdatedAt time.Time    `json:"updated_at"`
}

type ProjectEnvResponse struct {
	ID           uint         `json:"id"`
	ProjectID    uint         `json:"project_id"`
	Name         string       `json:"name"`
	EnvType      int8         `json:"env_type"`
	CreateUserID uint         `json:"create_user_id"`
	CreateUser   UserResponse `json:"create_user,omitempty"`
	CreatedAt    time.Time    `json:"created_at"`
	UpdatedAt    time.Time    `json:"updated_at"`
}

type ProjectDomainResponse struct {
	ID           uint      `json:"id"`
	ProjectID    uint      `json:"project_id"`
	ProjectEnvID uint      `json:"project_env_id"`
	Host         string    `json:"host"`
	CreatedAt    time.Time `json:"created_at"`
	UpdatedAt    time.Time `json:"updated_at"`
}

type ProjectDeployResponse struct {
	ID           uint      `json:"id"`
	ProjectID    uint      `json:"project_id"`
	ProjectEnvID uint      `json:"project_env_id"`
	Remark       *string   `json:"remark"`
	TargetType   int8      `json:"target_type"`
	Target       string    `json:"target"`
	CreateUserID uint      `json:"create_user_id"`
	ActionUserID uint      `json:"action_user_id"`
	IsActive     *int8     `json:"is_active"`
	CreatedAt    time.Time `json:"created_at"`
	UpdatedAt    time.Time `json:"updated_at"`
}
