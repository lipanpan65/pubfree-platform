package model

import (
	"time"

	"gorm.io/gorm"
)

type Project struct {
	ID           uint           `gorm:"primaryKey;autoIncrement" json:"id"`
	Name         string         `gorm:"type:varchar(128);not null;index:idx_name" json:"name"`
	ZhName       string         `gorm:"type:varchar(128);not null" json:"zh_name"`
	Description  *string        `gorm:"type:varchar(255)" json:"description"`
	OwnerID      uint           `gorm:"not null" json:"owner_id"`
	GroupID      *uint          `gorm:"default:null" json:"group_id"`
	CreateUserID uint           `gorm:"not null" json:"create_user_id"`
	IsDel        int8           `gorm:"type:tinyint(2);not null;default:0" json:"is_del"`
	CreatedAt    time.Time      `gorm:"not null;default:CURRENT_TIMESTAMP" json:"created_at"`
	UpdatedAt    time.Time      `gorm:"not null;default:CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP" json:"updated_at"`
	DeletedAt    gorm.DeletedAt `gorm:"index" json:"-"`

	// 关联
	Owner      User               `gorm:"foreignKey:OwnerID" json:"owner,omitempty"`
	Group      *Group             `gorm:"foreignKey:GroupID" json:"group,omitempty"`
	CreateUser User               `gorm:"foreignKey:CreateUserID" json:"create_user,omitempty"`
	Members    []ProjectMember    `gorm:"foreignKey:ProjectID" json:"members,omitempty"`
	Envs       []ProjectEnv       `gorm:"foreignKey:ProjectID" json:"envs,omitempty"`
	Domains    []ProjectDomain    `gorm:"foreignKey:ProjectID" json:"domains,omitempty"`
	Deploys    []ProjectEnvDeploy `gorm:"foreignKey:ProjectID" json:"deploys,omitempty"`
}

func (Project) TableName() string {
	return "project"
}
