package model

import (
	"time"

	"gorm.io/gorm"
)

type ProjectEnv struct {
	ID           uint           `gorm:"primaryKey;autoIncrement" json:"id"`
	ProjectID    uint           `gorm:"not null;index:idx_project_id" json:"project_id"`
	Name         string         `gorm:"type:varchar(128);not null" json:"name"`
	EnvType      int8           `gorm:"type:tinyint(2);not null" json:"env_type"`
	CreateUserID uint           `gorm:"not null" json:"create_user_id"`
	IsDel        int8           `gorm:"type:tinyint(2);not null;default:0" json:"is_del"`
	CreatedAt    time.Time      `gorm:"not null;default:CURRENT_TIMESTAMP" json:"created_at"`
	UpdatedAt    time.Time      `gorm:"not null;default:CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP" json:"updated_at"`
	DeletedAt    gorm.DeletedAt `gorm:"index" json:"-"`

	// 关联
	Project    Project            `gorm:"foreignKey:ProjectID" json:"project,omitempty"`
	CreateUser User               `gorm:"foreignKey:CreateUserID" json:"create_user,omitempty"`
	Domains    []ProjectDomain    `gorm:"foreignKey:ProjectEnvID" json:"domains,omitempty"`
	Deploys    []ProjectEnvDeploy `gorm:"foreignKey:ProjectEnvID" json:"deploys,omitempty"`
}

func (ProjectEnv) TableName() string {
	return "project_env"
}
