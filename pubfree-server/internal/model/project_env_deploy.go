package model

import (
	"time"

	"gorm.io/gorm"
)

type ProjectEnvDeploy struct {
	ID           uint           `gorm:"primaryKey;autoIncrement" json:"id"`
	ProjectID    uint           `gorm:"not null;index:idx_project_id" json:"project_id"`
	ProjectEnvID uint           `gorm:"not null;index:idx_project_env_id" json:"project_env_id"`
	Remark       *string        `gorm:"type:varchar(255)" json:"remark"`
	TargetType   int8           `gorm:"type:tinyint(2);not null" json:"target_type"`
	Target       string         `gorm:"type:varchar(512);not null" json:"target"`
	CreateUserID uint           `gorm:"not null" json:"create_user_id"`
	ActionUserID uint           `gorm:"not null" json:"action_user_id"`
	IsActive     *int8          `gorm:"type:tinyint(2);default:0" json:"is_active"`
	IsDel        int8           `gorm:"type:tinyint(2);not null;default:0" json:"is_del"`
	CreatedAt    time.Time      `gorm:"not null;default:CURRENT_TIMESTAMP" json:"created_at"`
	UpdatedAt    time.Time      `gorm:"not null;default:CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP" json:"updated_at"`
	DeletedAt    gorm.DeletedAt `gorm:"index" json:"-"`

	// 关联
	Project    Project    `gorm:"foreignKey:ProjectID" json:"project,omitempty"`
	ProjectEnv ProjectEnv `gorm:"foreignKey:ProjectEnvID" json:"project_env,omitempty"`
	CreateUser User       `gorm:"foreignKey:CreateUserID" json:"create_user,omitempty"`
	ActionUser User       `gorm:"foreignKey:ActionUserID" json:"action_user,omitempty"`
}

func (ProjectEnvDeploy) TableName() string {
	return "project_env_deploy"
}
