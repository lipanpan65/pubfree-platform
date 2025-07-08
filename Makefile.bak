# PubFree Platform Makefile
# 用于管理不同环境的部署和操作
# Author: PubFree Team
# Version: 2.0

# 默认环境
DEFAULT_ENV := dev
ENV ?= $(DEFAULT_ENV)

# 颜色定义
RED := \033[0;31m
GREEN := \033[0;32m
YELLOW := \033[1;33m
BLUE := \033[0;34m
PURPLE := \033[0;35m
CYAN := \033[0;36m
WHITE := \033[1;37m
NC := \033[0m # No Color

# 项目信息
PROJECT_NAME := PubFree Platform
VERSION := 1.0.0
DOCKER_COMPOSE_VERSION := $(shell docker-compose --version 2>/dev/null || echo "Not installed")
DOCKER_VERSION := $(shell docker --version 2>/dev/null || echo "Not installed")

# 路径定义
SCRIPTS_DIR := scripts
ENVS_DIR := environments
LOGS_DIR := logs
BACKUPS_DIR := backups
UPLOADS_DIR := uploads

# 容器名称
WEB_CONTAINER := pubfree-web-dev
SERVER_CONTAINER := pubfree-server-dev
MYSQL_CONTAINER := pubfree-mysql-dev
REDIS_CONTAINER := pubfree-redis-dev

# 声明所有目标为伪目标
.PHONY: help quick info commands dev test prod stop restart clean logs backup status build init check \
        web-install web-dev web-remove web-shell web-logs web-status web-restart web-rebuild \
        server-shell server-logs server-restart server-rebuild \
        db-shell db-logs db-backup db-restore db-reset \
        redis-shell redis-logs redis-restart redis-flush \
        docker-clean docker-prune docker-update \
        lint test-unit test-e2e \
        deploy-dev deploy-test deploy-prod \
        monitor health debug troubleshoot

# 默认目标
.DEFAULT_GOAL := help

# 主帮助菜单
help:
	@echo ""
	@echo "$(CYAN)🚀 $(PROJECT_NAME) - 开发环境管理$(NC)"
	@echo "$(CYAN)版本: $(VERSION)$(NC)"
	@echo "$(CYAN)======================================$(NC)"
	@echo ""
	@echo "$(YELLOW)📦 环境管理:$(NC)"
	@echo "  $(GREEN)make dev$(NC)                     - 启动开发环境"
	@echo "  $(GREEN)make test$(NC)                    - 启动测试环境"
	@echo "  $(GREEN)make prod$(NC)                    - 启动生产环境"
	@echo "  $(GREEN)make stop [ENV=<env>]$(NC)        - 停止指定环境"
	@echo "  $(GREEN)make restart [ENV=<env>]$(NC)     - 重启指定环境"
	@echo "  $(GREEN)make status$(NC)                  - 查看所有环境状态"
	@echo "  $(GREEN)make build [ENV=<env>]$(NC)       - 构建指定环境镜像"
	@echo "  $(GREEN)make clean$(NC)                   - 清理所有环境"
	@echo ""
	@echo "$(YELLOW)🔧 前端开发:$(NC)"
	@echo "  $(GREEN)make web-install PKGS=<pkg>$(NC)  - 安装前端包"
	@echo "  $(GREEN)make web-dev PKGS=<pkg>$(NC)      - 安装前端开发包"
	@echo "  $(GREEN)make web-remove PKGS=<pkg>$(NC)   - 移除前端包"
	@echo "  $(GREEN)make web-shell$(NC)               - 进入前端容器"
	@echo "  $(GREEN)make web-logs$(NC)                - 查看前端日志"
	@echo "  $(GREEN)make web-restart$(NC)             - 重启前端容器"
	@echo "  $(GREEN)make web-rebuild$(NC)             - 重新构建前端"
	@echo ""
	@echo "$(YELLOW)⚙️ 后端开发:$(NC)"
	@echo "  $(GREEN)make server-shell$(NC)            - 进入后端容器"
	@echo "  $(GREEN)make server-logs$(NC)             - 查看后端日志"
	@echo "  $(GREEN)make server-restart$(NC)          - 重启后端容器"
	@echo "  $(GREEN)make server-rebuild$(NC)          - 重新构建后端"
	@echo ""
	@echo "$(YELLOW)🗄️ 数据库管理:$(NC)"
	@echo "  $(GREEN)make db-shell$(NC)                - 进入MySQL容器"
	@echo "  $(GREEN)make db-logs$(NC)                 - 查看MySQL日志"
	@echo "  $(GREEN)make db-backup [ENV=<env>]$(NC)   - 备份数据库"
	@echo "  $(GREEN)make db-restore [ENV=<env>]$(NC)  - 恢复数据库"
	@echo "  $(GREEN)make db-reset$(NC)                - 重置开发数据库"
	@echo ""
	@echo "$(YELLOW)🔗 Redis管理:$(NC)"
	@echo "  $(GREEN)make redis-shell$(NC)             - 进入Redis容器"
	@echo "  $(GREEN)make redis-logs$(NC)              - 查看Redis日志"
	@echo "  $(GREEN)make redis-restart$(NC)           - 重启Redis容器"
	@echo "  $(GREEN)make redis-flush$(NC)             - 清空Redis缓存"
	@echo ""
	@echo "$(YELLOW)🐳 Docker工具:$(NC)"
	@echo "  $(GREEN)make docker-clean$(NC)            - 清理Docker资源"
	@echo "  $(GREEN)make docker-prune$(NC)            - 深度清理Docker"
	@echo "  $(GREEN)make docker-update$(NC)           - 更新Docker镜像"
	@echo ""
	@echo "$(YELLOW)🔍 监控和调试:$(NC)"
	@echo "  $(GREEN)make monitor$(NC)                 - 系统监控面板"
	@echo "  $(GREEN)make health$(NC)                  - 健康检查"
	@echo "  $(GREEN)make debug$(NC)                   - 调试信息"
	@echo "  $(GREEN)make troubleshoot$(NC)            - 故障排查"
	@echo ""
	@echo "$(YELLOW)📚 使用示例:$(NC)"
	@echo "  $(BLUE)make dev$(NC)                           # 启动开发环境"
	@echo "  $(BLUE)make web-install PKGS='mobx axios'$(NC) # 安装前端包"
	@echo "  $(BLUE)make logs ENV=dev$(NC)                  # 查看开发环境日志"
	@echo "  $(BLUE)make db-backup ENV=prod$(NC)            # 备份生产数据库"
	@echo ""
	@echo "$(YELLOW)💡 快捷命令:$(NC)"
	@echo "  $(PURPLE)make quick$(NC)     - 快速帮助"
	@echo "  $(PURPLE)make info$(NC)      - 环境信息"
	@echo "  $(PURPLE)make commands$(NC)  - 所有命令"
	@echo ""

# 快速帮助
quick:
	@echo ""
	@echo "$(CYAN)⚡ 快速命令参考$(NC)"
	@echo "$(CYAN)==================$(NC)"
	@echo ""
	@echo "$(YELLOW)🚀 启动开发:$(NC)"
	@echo "  $(GREEN)make dev$(NC)                # 启动开发环境"
	@echo "  $(GREEN)make web-shell$(NC)          # 进入前端容器"
	@echo "  $(GREEN)make server-shell$(NC)       # 进入后端容器"
	@echo ""
	@echo "$(YELLOW)📦 包管理:$(NC)"
	@echo "  $(GREEN)make web-install PKGS='包名'$(NC)  # 安装前端包"
	@echo "  $(GREEN)make web-remove PKGS='包名'$(NC)   # 移除前端包"
	@echo ""
	@echo "$(YELLOW)🔧 常用操作:$(NC)"
	@echo "  $(GREEN)make logs ENV=dev$(NC)             # 查看日志"
	@echo "  $(GREEN)make stop ENV=dev$(NC)             # 停止环境"
	@echo "  $(GREEN)make restart ENV=dev$(NC)          # 重启环境"
	@echo ""
	@echo "$(YELLOW)🆘 故障排除:$(NC)"
	@echo "  $(GREEN)make health$(NC)                   # 健康检查"
	@echo "  $(GREEN)make troubleshoot$(NC)             # 故障排查"
	@echo "  $(GREEN)make clean && make dev$(NC)        # 重置环境"
	@echo ""

# 环境信息
info:
	@echo ""
	@echo "$(CYAN)🔍 $(PROJECT_NAME) - 环境信息$(NC)"
	@echo "$(CYAN)================================$(NC)"
	@echo ""
	@echo "$(YELLOW)📊 系统信息:$(NC)"
	@echo "  项目版本: $(VERSION)"
	@echo "  Docker版本: $(shell docker --version 2>/dev/null | cut -d' ' -f3 | cut -d',' -f1 || echo '未安装')"
	@echo "  Docker Compose版本: $(shell docker-compose --version 2>/dev/null | cut -d' ' -f4 | cut -d',' -f1 || echo '未安装')"
	@echo "  操作系统: $(shell uname -s) $(shell uname -m)"
	@echo "  当前用户: $(shell whoami)"
	@echo "  工作目录: $(shell pwd)"
	@echo ""
	@echo "$(YELLOW)🔧 技术栈:$(NC)"
	@echo "  后端: Go 1.24.3 + Gin + GORM + MySQL + Redis"
	@echo "  前端: React 19 + TypeScript + Vite + Ant Design"
	@echo "  容器: Docker + Docker Compose"
	@echo "  构建: Make + Shell Scripts"
	@echo ""
	@echo "$(YELLOW)🌐 默认端口:$(NC)"
	@echo "  前端开发: http://localhost:3000"
	@echo "  后端API:  http://localhost:8080"
	@echo "  MySQL:    localhost:3306"
	@echo "  Redis:    localhost:6379"
	@echo ""
	@echo "$(YELLOW)📁 项目结构:$(NC)"
	@echo "  $(ENVS_DIR)/development   - 开发环境配置"
	@echo "  $(ENVS_DIR)/testing       - 测试环境配置"
	@echo "  $(ENVS_DIR)/production    - 生产环境配置"
	@echo "  pubfree-server           - Go 后端服务"
	@echo "  pubfree-web              - React 前端应用"
	@echo "  $(SCRIPTS_DIR)/          - 管理脚本"
	@echo ""

# 所有命令列表
commands:
	@echo ""
	@echo "$(CYAN)📋 所有可用命令$(NC)"
	@echo "$(CYAN)=================$(NC)"
	@echo ""
	@echo "$(YELLOW)环境管理:$(NC)"
	@echo "  dev, test, prod, stop, restart, status, build, clean"
	@echo ""
	@echo "$(YELLOW)前端开发:$(NC)"
	@echo "  web-install, web-dev, web-remove, web-shell, web-logs"
	@echo "  web-restart, web-rebuild"
	@echo ""
	@echo "$(YELLOW)后端开发:$(NC)"
	@echo "  server-shell, server-logs, server-restart, server-rebuild"
	@echo ""
	@echo "$(YELLOW)数据库管理:$(NC)"
	@echo "  db-shell, db-logs, db-backup, db-restore, db-reset"
	@echo ""
	@echo "$(YELLOW)Redis管理:$(NC)"
	@echo "  redis-shell, redis-logs, redis-restart, redis-flush"
	@echo ""
	@echo "$(YELLOW)Docker工具:$(NC)"
	@echo "  docker-clean, docker-prune, docker-update"
	@echo ""
	@echo "$(YELLOW)监控调试:$(NC)"
	@echo "  monitor, health, debug, troubleshoot"
	@echo ""
	@echo "$(YELLOW)实用工具:$(NC)"
	@echo "  check, init, help, quick, info, commands"
	@echo ""

# 环境启动命令
dev:
	@echo "$(YELLOW)🚀 启动开发环境...$(NC)"
	@cd $(ENVS_DIR)/development && docker-compose --env-file .env up -d --build
	@echo ""
	@echo "$(GREEN)✅ 开发环境启动完成$(NC)"
	@echo ""
	@echo "$(CYAN)🌐 访问地址:$(NC)"
	@echo "  📱 前端: $(BLUE)http://localhost:3000$(NC)"
	@echo "  🔧 后端: $(BLUE)http://localhost:8080$(NC)"
	@echo "  🗄️ 数据库: $(BLUE)localhost:3306$(NC)"
	@echo ""
	@echo "$(CYAN)💡 常用命令:$(NC)"
	@echo "  $(GREEN)make logs ENV=dev$(NC)     # 查看日志"
	@echo "  $(GREEN)make web-shell$(NC)        # 进入前端容器"
	@echo "  $(GREEN)make server-shell$(NC)     # 进入后端容器"
	@echo "  $(GREEN)make stop ENV=dev$(NC)     # 停止环境"
	@echo "  $(GREEN)make health$(NC)           # 健康检查"
	@echo ""

test:
	@echo "$(YELLOW)🧪 启动测试环境...$(NC)"
	@cd $(ENVS_DIR)/testing && docker-compose --env-file .env up -d --build
	@echo "$(GREEN)✅ 测试环境启动完成$(NC)"

prod:
	@echo "$(YELLOW)🏭 启动生产环境...$(NC)"
	@echo "$(RED)⚠️  请确保已配置生产环境的环境变量$(NC)"
	@read -p "确认启动生产环境? (y/N): " confirm && [ "$$confirm" = "y" ]
	@cd $(ENVS_DIR)/production && docker-compose --env-file .env up -d --build
	@echo "$(GREEN)✅ 生产环境启动完成$(NC)"

# 环境控制
stop:
	@echo "$(YELLOW)🛑 停止$(ENV)环境...$(NC)"
	@cd $(ENVS_DIR)/$(call env_dir,$(ENV)) && docker-compose down
	@echo "$(GREEN)✅ $(ENV)环境已停止$(NC)"

restart:
	@echo "$(YELLOW)🔄 重启$(ENV)环境...$(NC)"
	@cd $(ENVS_DIR)/$(call env_dir,$(ENV)) && docker-compose restart
	@echo "$(GREEN)✅ $(ENV)环境已重启$(NC)"

status:
	@echo ""
	@echo "$(CYAN)📊 环境状态总览$(NC)"
	@echo "$(CYAN)=================$(NC)"
	@echo ""
	@echo "$(YELLOW)🔧 开发环境:$(NC)"
	@cd $(ENVS_DIR)/development && docker-compose ps || echo "未运行"
	@echo ""
	@echo "$(YELLOW)🧪 测试环境:$(NC)"
	@cd $(ENVS_DIR)/testing && docker-compose ps || echo "未运行"
	@echo ""
	@echo "$(YELLOW)🏭 生产环境:$(NC)"
	@cd $(ENVS_DIR)/production && docker-compose ps || echo "未运行"
	@echo ""

# 前端开发工具
web-install:
	@echo "$(YELLOW)📦 安装前端包: $(PKGS)$(NC)"
	@$(SCRIPTS_DIR)/web-dev.sh install $(PKGS)

web-dev:
	@echo "$(YELLOW)📦 安装前端开发包: $(PKGS)$(NC)"
	@$(SCRIPTS_DIR)/web-dev.sh dev $(PKGS)

web-remove:
	@echo "$(YELLOW)🗑️ 移除前端包: $(PKGS)$(NC)"
	@$(SCRIPTS_DIR)/web-dev.sh remove $(PKGS)

web-shell:
	@echo "$(YELLOW)🐚 进入前端容器...$(NC)"
	@docker exec -it $(WEB_CONTAINER) /bin/bash

web-logs:
	@echo "$(YELLOW)📋 前端容器日志:$(NC)"
	@docker logs -f $(WEB_CONTAINER)

web-restart:
	@echo "$(YELLOW)🔄 重启前端容器...$(NC)"
	@docker restart $(WEB_CONTAINER)
	@echo "$(GREEN)✅ 前端容器已重启$(NC)"

web-rebuild:
	@echo "$(YELLOW)🔨 重新构建前端容器...$(NC)"
	@cd $(ENVS_DIR)/development && docker-compose build pubfree-web
	@docker restart $(WEB_CONTAINER)
	@echo "$(GREEN)✅ 前端容器重建完成$(NC)"

# 后端开发工具
server-shell:
	@echo "$(YELLOW)🐚 进入后端容器...$(NC)"
	@docker exec -it $(SERVER_CONTAINER) /bin/bash

server-logs:
	@echo "$(YELLOW)📋 后端容器日志:$(NC)"
	@docker logs -f $(SERVER_CONTAINER)

server-restart:
	@echo "$(YELLOW)🔄 重启后端容器...$(NC)"
	@docker restart $(SERVER_CONTAINER)
	@echo "$(GREEN)✅ 后端容器已重启$(NC)"

server-rebuild:
	@echo "$(YELLOW)🔨 重新构建后端容器...$(NC)"
	@cd $(ENVS_DIR)/development && docker-compose build pubfree-server
	@docker restart $(SERVER_CONTAINER)
	@echo "$(GREEN)✅ 后端容器重建完成$(NC)"

# 数据库管理
db-shell:
	@echo "$(YELLOW)🐚 进入MySQL容器...$(NC)"
	@docker exec -it $(MYSQL_CONTAINER) mysql -u root -p

db-logs:
	@echo "$(YELLOW)📋 MySQL日志:$(NC)"
	@docker logs -f $(MYSQL_CONTAINER)

db-backup:
	@echo "$(YELLOW)💾 备份$(ENV)环境数据库...$(NC)"
	@$(SCRIPTS_DIR)/backup-$(ENV).sh

db-restore:
	@echo "$(YELLOW)🔄 恢复$(ENV)环境数据库...$(NC)"
	@$(SCRIPTS_DIR)/restore.sh $(ENV)

db-reset:
	@echo "$(RED)⚠️  重置开发数据库$(NC)"
	@read -p "确认重置开发数据库? (y/N): " confirm && [ "$$confirm" = "y" ]
	@docker exec -it $(MYSQL_CONTAINER) mysql -u root -p -e "DROP DATABASE IF EXISTS pubfree_dev; CREATE DATABASE pubfree_dev;"
	@echo "$(GREEN)✅ 开发数据库已重置$(NC)"

# Redis管理
redis-shell:
	@echo "$(YELLOW)🐚 进入Redis容器...$(NC)"
	@docker exec -it $(REDIS_CONTAINER) redis-cli

redis-logs:
	@echo "$(YELLOW)📋 Redis日志:$(NC)"
	@docker logs -f $(REDIS_CONTAINER)

redis-restart:
	@echo "$(YELLOW)🔄 重启Redis容器...$(NC)"
	@docker restart $(REDIS_CONTAINER)
	@echo "$(GREEN)✅ Redis容器已重启$(NC)"

redis-flush:
	@echo "$(YELLOW)🧹 清空Redis缓存...$(NC)"
	@docker exec -it $(REDIS_CONTAINER) redis-cli FLUSHALL
	@echo "$(GREEN)✅ Redis缓存已清空$(NC)"

# Docker工具
docker-clean:
	@echo "$(YELLOW)🧹 清理Docker资源...$(NC)"
	@docker system prune -f
	@echo "$(GREEN)✅ Docker资源清理完成$(NC)"

docker-prune:
	@echo "$(YELLOW)🧹 深度清理Docker...$(NC)"
	@docker system prune -af --volumes
	@echo "$(GREEN)✅ Docker深度清理完成$(NC)"

docker-update:
	@echo "$(YELLOW)🔄 更新Docker镜像...$(NC)"
	@docker pull mysql:8.0
	@docker pull redis:7-alpine
	@docker pull node:20.19.0-alpine
	@docker pull golang:1.24.3-alpine
	@echo "$(GREEN)✅ Docker镜像更新完成$(NC)"

# 监控和调试
monitor:
	@echo "$(YELLOW)📊 系统监控面板$(NC)"
	@echo "容器状态:"
	@docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"
	@echo ""
	@echo "资源使用:"
	@docker stats --no-stream

health:
	@echo "$(YELLOW)🏥 健康检查$(NC)"
	@echo "===================="
	@echo ""
	@echo "$(CYAN)🔍 容器健康状态:$(NC)"
	@docker ps --format "table {{.Names}}\t{{.Status}}" | grep -E "(healthy|unhealthy|starting)" || echo "所有容器运行正常"
	@echo ""
	@echo "$(CYAN)🌐 服务可用性:$(NC)"
	@curl -s http://localhost:3000 > /dev/null && echo "✅ 前端服务正常" || echo "❌ 前端服务异常"
	@curl -s http://localhost:8080/health > /dev/null && echo "✅ 后端服务正常" || echo "❌ 后端服务异常"
	@echo ""
	@echo "$(CYAN)💾 数据库连接:$(NC)"
	@docker exec $(MYSQL_CONTAINER) mysqladmin ping -h localhost -u root -p$(shell grep MYSQL_ROOT_PASSWORD $(ENVS_DIR)/development/.env | cut -d'=' -f2) > /dev/null 2>&1 && echo "✅ MySQL连接正常" || echo "❌ MySQL连接异常"
	@docker exec $(REDIS_CONTAINER) redis-cli ping > /dev/null 2>&1 && echo "✅ Redis连接正常" || echo "❌ Redis连接异常"

debug:
	@echo "$(YELLOW)🐛 调试信息$(NC)"
	@echo "==============="
	@echo ""
	@echo "$(CYAN)环境变量:$(NC)"
	@echo "ENV = $(ENV)"
	@echo "PROJECT_NAME = $(PROJECT_NAME)"
	@echo "VERSION = $(VERSION)"
	@echo ""
	@echo "$(CYAN)容器状态:$(NC)"
	@docker ps -a --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"
	@echo ""
	@echo "$(CYAN)Docker信息:$(NC)"
	@docker info | head -20

troubleshoot:
	@echo "$(YELLOW)🔧 故障排查$(NC)"
	@echo "================"
	@echo ""
	@echo "$(CYAN)1. 检查Docker状态$(NC)"
	@docker version > /dev/null 2>&1 && echo "✅ Docker运行正常" || echo "❌ Docker未运行"
	@echo ""
	@echo "$(CYAN)2. 检查端口占用$(NC)"
	@lsof -i :3000 > /dev/null 2>&1 && echo "⚠️ 端口3000被占用" || echo "✅ 端口3000可用"
	@lsof -i :8080 > /dev/null 2>&1 && echo "⚠️ 端口8080被占用" || echo "✅ 端口8080可用"
	@echo ""
	@echo "$(CYAN)3. 检查配置文件$(NC)"
	@[ -f "$(ENVS_DIR)/development/.env" ] && echo "✅ 开发环境配置存在" || echo "❌ 开发环境配置缺失"
	@echo ""
	@echo "$(CYAN)4. 建议解决方案$(NC)"
	@echo "  • 端口占用: make stop ENV=dev"
	@echo "  • 配置缺失: make init"
	@echo "  • 环境异常: make clean && make dev"
	@echo "  • 权限问题: sudo make clean && make dev"

# 日志查看
logs:
	@echo "$(YELLOW)📋 查看$(ENV)环境日志$(NC)"
	@cd $(ENVS_DIR)/$(call env_dir,$(ENV)) && docker-compose logs -f

# 备份
backup:
	@echo "$(YELLOW)💾 备份$(ENV)环境数据库...$(NC)"
	@$(SCRIPTS_DIR)/backup-$(ENV).sh

# 清理
clean:
	@echo "$(YELLOW)🧹 清理所有环境...$(NC)"
	@read -p "确认清理所有环境的容器和数据? (y/N): " confirm && [ "$$confirm" = "y" ]
	@cd $(ENVS_DIR)/development && docker-compose down -v || true
	@cd $(ENVS_DIR)/testing && docker-compose down -v || true
	@cd $(ENVS_DIR)/production && docker-compose down -v || true
	@docker system prune -f
	@echo "$(GREEN)✅ 清理完成$(NC)"

# 构建
build:
	@echo "$(YELLOW)🔨 构建$(ENV)环境镜像...$(NC)"
	@cd $(ENVS_DIR)/$(call env_dir,$(ENV)) && docker-compose build
	@echo "$(GREEN)✅ 构建完成$(NC)"

# 初始化
init:
	@echo "$(YELLOW)🔧 初始化项目环境...$(NC)"
	@chmod +x $(SCRIPTS_DIR)/*.sh
	@mkdir -p $(LOGS_DIR) $(BACKUPS_DIR) $(UPLOADS_DIR)
	@echo "$(GREEN)✅ 初始化完成$(NC)"

# 检查配置
check:
	@echo "$(YELLOW)🔍 检查环境配置...$(NC)"
	@[ -f "$(ENVS_DIR)/development/.env" ] && echo "✅ 开发环境配置文件存在" || echo "❌ 开发环境配置文件不存在"
	@[ -f "$(ENVS_DIR)/testing/.env" ] && echo "✅ 测试环境配置文件存在" || echo "❌ 测试环境配置文件不存在"
	@[ -f "$(ENVS_DIR)/production/.env" ] && echo "✅ 生产环境配置文件存在" || echo "❌ 生产环境配置文件不存在"

# 辅助函数
define env_dir
$(if $(filter dev,$(1)),development,$(if $(filter test,$(1)),testing,$(if $(filter prod,$(1)),production,development)))
endef