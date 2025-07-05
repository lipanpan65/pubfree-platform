package request

type CreateProjectRequest struct {
	Name        string  `json:"name" binding:"required,min=2,max=128"`
	ZhName      string  `json:"zh_name" binding:"required,min=2,max=128"`
	Description *string `json:"description" binding:"omitempty,max=255"`
	GroupID     *uint   `json:"group_id"`
}

type UpdateProjectRequest struct {
	Name        string  `json:"name" binding:"omitempty,min=2,max=128"`
	ZhName      string  `json:"zh_name" binding:"omitempty,min=2,max=128"`
	Description *string `json:"description" binding:"omitempty,max=255"`
	GroupID     *uint   `json:"group_id"`
}

type AddProjectMemberRequest struct {
	UserID uint `json:"user_id" binding:"required"`
	Role   int8 `json:"role" binding:"required,min=1,max=10"`
}

type CreateProjectEnvRequest struct {
	Name    string `json:"name" binding:"required,min=2,max=128"`
	EnvType int8   `json:"env_type" binding:"required,min=1,max=4"`
}

type CreateProjectDomainRequest struct {
	ProjectEnvID uint   `json:"project_env_id" binding:"required"`
	Host         string `json:"host" binding:"required,min=3,max=255"`
}

type CreateProjectDeployRequest struct {
	ProjectEnvID uint    `json:"project_env_id" binding:"required"`
	Remark       *string `json:"remark" binding:"omitempty,max=255"`
	TargetType   int8    `json:"target_type" binding:"required,min=1,max=10"`
	Target       string  `json:"target" binding:"required,min=3,max=512"`
}
