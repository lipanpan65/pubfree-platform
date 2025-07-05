package model

import (
	"time"

	"gorm.io/gorm"
)

type ProjectDomain struct {
	ID           uint           `gorm:"primaryKey;autoIncrement" json:"id"`
	ProjectID    uint           `gorm:"not null;index:idx_project_id" json:"project_id"`
	ProjectEnvID uint           `gorm:"not null" json:"project_env_id"`
	Host         string         `gorm:"type:varchar(255);not null" json:"host"`
	IsDel        int8           `gorm:"type:tinyint(2);not null;default:0" json:"is_del"`
	CreatedAt    time.Time      `gorm:"not null;default:CURRENT_TIMESTAMP" json:"created_at"`
	UpdatedAt    time.Time      `gorm:"not null;default:CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP" json:"updated_at"`
	DeletedAt    gorm.DeletedAt `gorm:"index" json:"-"`

	// 关联
	Project    Project    `gorm:"foreignKey:ProjectID" json:"project,omitempty"`
	ProjectEnv ProjectEnv `gorm:"foreignKey:ProjectEnvID" json:"project_env,omitempty"`
}

func (ProjectDomain) TableName() string {
	return "project_domain"
}
