package model

import (
	"time"

	"gorm.io/gorm"
)

type ProjectMember struct {
	ID        uint           `gorm:"primaryKey;autoIncrement" json:"id"`
	ProjectID uint           `gorm:"not null;index:idx_project_id" json:"project_id"`
	UserID    uint           `gorm:"not null;index:idx_user_id" json:"user_id"`
	Role      int8           `gorm:"type:tinyint(2);not null" json:"role"`
	IsDel     int8           `gorm:"type:tinyint(2);not null;default:0" json:"is_del"`
	CreatedAt time.Time      `gorm:"not null;default:CURRENT_TIMESTAMP" json:"created_at"`
	UpdatedAt time.Time      `gorm:"not null;default:CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP" json:"updated_at"`
	DeletedAt gorm.DeletedAt `gorm:"index" json:"-"`

	// 关联
	Project Project `gorm:"foreignKey:ProjectID" json:"project,omitempty"`
	User    User    `gorm:"foreignKey:UserID" json:"user,omitempty"`
}

func (ProjectMember) TableName() string {
	return "project_member"
}
