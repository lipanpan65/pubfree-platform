-- 创建数据库
CREATE DATABASE IF NOT EXISTS pubfree DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

USE pubfree;

-- 用户表
CREATE TABLE IF NOT EXISTS `user` (
    id         int(11)      NOT NULL AUTO_INCREMENT COMMENT '自增id',
    name       varchar(64)  NOT NULL COMMENT '用户名',
    password   varchar(128) NOT NULL COMMENT '密码',
    is_del     tinyint(2)   NOT NULL DEFAULT 0 COMMENT '是否逻辑删除',
    created_at datetime     NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '记录创建时间',
    updated_at datetime     NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '记录更新时间',
    PRIMARY KEY (id),
    INDEX idx_name (name)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='用户表';

-- 空间表
CREATE TABLE IF NOT EXISTS `group` (
    id             int(11)      NOT NULL AUTO_INCREMENT COMMENT '自增 id',
    name           varchar(128) NOT NULL COMMENT '空间名称',
    description    varchar(255) DEFAULT NULL COMMENT '空间描述说明',
    owner_id       int(11)      NOT NULL COMMENT '空间拥有者 id',
    create_user_id int(11)      NOT NULL COMMENT '空间创建者 id',
    is_del         tinyint(2)   NOT NULL DEFAULT 0 COMMENT '是否逻辑删除',
    created_at     datetime     NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '记录创建时间',
    updated_at     datetime     NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '记录更新时间',
    PRIMARY KEY (id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='空间表';

-- 空间成员表
CREATE TABLE IF NOT EXISTS `group_member` (
    id         int(11)    NOT NULL AUTO_INCREMENT COMMENT '自增id',
    group_id   int(11)    NOT NULL COMMENT '空间 id',
    user_id    int(11)    NOT NULL COMMENT '用户 id',
    role       int(8)     NOT NULL COMMENT '角色',
    is_del     tinyint(2) NOT NULL DEFAULT 0 COMMENT '是否逻辑删除',
    created_at datetime   NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '记录创建时间',
    updated_at datetime   NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '记录更新时间',
    PRIMARY KEY (id),
    INDEX idx_group_id (group_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='空间成员表';

-- 项目基本信息表
CREATE TABLE IF NOT EXISTS `project` (
    id             int(11)      NOT NULL AUTO_INCREMENT COMMENT '自增id',
    name           varchar(128) NOT NULL COMMENT '项目英文名',
    zh_name        varchar(128) NOT NULL COMMENT '项目中文名',
    description    varchar(255) DEFAULT NULL COMMENT '项目描述',
    owner_id       int(11)      NOT NULL COMMENT '项目拥有者id',
    group_id       int(11)      DEFAULT NULL COMMENT '项目关联的空间id',
    create_user_id int(11)      NOT NULL COMMENT '创建人id',
    is_del         tinyint(2)   NOT NULL DEFAULT 0 COMMENT '是否逻辑删除',
    created_at     datetime     NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '记录创建时间',
    updated_at     datetime     NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '记录更新时间',
    PRIMARY KEY (id),
    INDEX idx_name (name)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='项目基本信息表';

-- 项目成员信息表
CREATE TABLE IF NOT EXISTS `project_member` (
    id         int(11)    NOT NULL AUTO_INCREMENT COMMENT '自增 id',
    project_id int(11)    NOT NULL COMMENT '项目 id',
    user_id    int(11)    NOT NULL COMMENT '用户 id',
    role       tinyint(2) NOT NULL COMMENT '角色',
    is_del     tinyint(2) NOT NULL DEFAULT 0 COMMENT '是否逻辑删除',
    created_at datetime   NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '记录创建时间',
    updated_at datetime   NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '记录更新时间',
    PRIMARY KEY (id),
    INDEX idx_project_id (project_id),
    INDEX idx_user_id (user_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='项目成员信息';

-- 项目环境表
CREATE TABLE IF NOT EXISTS `project_env` (
    id             int(11)      NOT NULL AUTO_INCREMENT COMMENT '自增id',
    project_id     int(11)      NOT NULL COMMENT '项目 id',
    name           varchar(128) NOT NULL COMMENT '环境名称',
    env_type       tinyint(2)   NOT NULL COMMENT '环境类型，test、beta、gray、prod',
    create_user_id int(11)      NOT NULL COMMENT '创建者 id',
    is_del         tinyint(2)   NOT NULL DEFAULT 0 COMMENT '是否逻辑删除',
    created_at     datetime     NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '记录创建时间',
    updated_at     datetime     NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '记录更新时间',
    PRIMARY