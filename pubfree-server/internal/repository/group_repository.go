package repository

import (
	"context"
	"pubfree-platform/pubfree-server/internal/model"

	"gorm.io/gorm"
)

type GroupRepository interface {
	Create(ctx context.Context, group *model.Group) error
	GetByID(ctx context.Context, id uint) (*model.Group, error)
	GetByIDWithMembers(ctx context.Context, id uint) (*model.Group, error)
	Update(ctx context.Context, group *model.Group) error
	Delete(ctx context.Context, id uint) error
	List(ctx context.Context, offset, limit int) ([]*model.Group, error)
	ListByOwner(ctx context.Context, ownerID uint, offset, limit int) ([]*model.Group, error)
	Count(ctx context.Context) (int64, error)
}

type groupRepository struct {
	db *gorm.DB
}

func NewGroupRepository(db *gorm.DB) GroupRepository {
	return &groupRepository{db: db}
}

func (r *groupRepository) Create(ctx context.Context, group *model.Group) error {
	return r.db.WithContext(ctx).Create(group).Error
}

func (r *groupRepository) GetByID(ctx context.Context, id uint) (*model.Group, error) {
	var group model.Group
	err := r.db.WithContext(ctx).
		Where("is_del = 0").
		Preload("Owner").
		Preload("CreateUser").
		First(&group, id).Error
	return &group, err
}

func (r *groupRepository) GetByIDWithMembers(ctx context.Context, id uint) (*model.Group, error) {
	var group model.Group
	err := r.db.WithContext(ctx).
		Where("is_del = 0").
		Preload("Owner").
		Preload("CreateUser").
		Preload("Members.User").
		First(&group, id).Error
	return &group, err
}

func (r *groupRepository) Update(ctx context.Context, group *model.Group) error {
	return r.db.WithContext(ctx).Save(group).Error
}

func (r *groupRepository) Delete(ctx context.Context, id uint) error {
	return r.db.WithContext(ctx).Model(&model.Group{}).Where("id = ?", id).Update("is_del", 1).Error
}

func (r *groupRepository) List(ctx context.Context, offset, limit int) ([]*model.Group, error) {
	var groups []*model.Group
	err := r.db.WithContext(ctx).
		Where("is_del = 0").
		Preload("Owner").
		Preload("CreateUser").
		Offset(offset).
		Limit(limit).
		Find(&groups).Error
	return groups, err
}

func (r *groupRepository) ListByOwner(ctx context.Context, ownerID uint, offset, limit int) ([]*model.Group, error) {
	var groups []*model.Group
	err := r.db.WithContext(ctx).
		Where("owner_id = ? AND is_del = 0", ownerID).
		Preload("Owner").
		Preload("CreateUser").
		Offset(offset).
		Limit(limit).
		Find(&groups).Error
	return groups, err
}

func (r *groupRepository) Count(ctx context.Context) (int64, error) {
	var count int64
	err := r.db.WithContext(ctx).Model(&model.Group{}).Where("is_del = 0").Count(&count).Error
	return count, err
}
