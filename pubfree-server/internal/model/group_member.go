package model

import (
	"time"

	"gorm.io/gorm"
)

type GroupMember struct {
	ID        uint           `gorm:"primaryKey;autoIncrement" json:"id"`
	GroupID   uint           `gorm:"not null;index:idx_group_id" json:"group_id"`
	UserID    uint           `gorm:"not null" json:"user_id"`
	Role      int8           `gorm:"type:int(8);not null" json:"role"`
	IsDel     int8           `gorm:"type:tinyint(2);not null;default:0" json:"is_del"`
	CreatedAt time.Time      `gorm:"not null;default:CURRENT_TIMESTAMP" json:"created_at"`
	UpdatedAt time.Time      `gorm:"not null;default:CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP" json:"updated_at"`
	DeletedAt gorm.DeletedAt `gorm:"index" json:"-"`

	// 关联
	Group Group `gorm:"foreignKey:GroupID" json:"group,omitempty"`
	User  User  `gorm:"foreignKey:UserID" json:"user,omitempty"`
}

func (GroupMember) TableName() string {
	return "group_member"
}
