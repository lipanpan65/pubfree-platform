package model

import (
	"time"

	"gorm.io/gorm"
)

type Group struct {
	ID           uint           `gorm:"primaryKey;autoIncrement" json:"id"`
	Name         string         `gorm:"type:varchar(128);not null" json:"name"`
	Description  *string        `gorm:"type:varchar(255)" json:"description"`
	OwnerID      uint           `gorm:"not null" json:"owner_id"`
	CreateUserID uint           `gorm:"not null" json:"create_user_id"`
	IsDel        int8           `gorm:"type:tinyint(2);not null;default:0" json:"is_del"`
	CreatedAt    time.Time      `gorm:"not null;default:CURRENT_TIMESTAMP" json:"created_at"`
	UpdatedAt    time.Time      `gorm:"not null;default:CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP" json:"updated_at"`
	DeletedAt    gorm.DeletedAt `gorm:"index" json:"-"`

	// 关联
	Owner      User          `gorm:"foreignKey:OwnerID" json:"owner,omitempty"`
	CreateUser User          `gorm:"foreignKey:CreateUserID" json:"create_user,omitempty"`
	Members    []GroupMember `gorm:"foreignKey:GroupID" json:"members,omitempty"`
	Projects   []Project     `gorm:"foreignKey:GroupID" json:"projects,omitempty"`
}

func (Group) TableName() string {
	return "group"
}
