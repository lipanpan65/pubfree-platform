# PubFree Platform Makefile - Enhanced with Multi-platform Support
# 用于管理不同环境的部署和操作 + 跨平台支持
# Author: PubFree Team
# Version: 2.1 (Multi-platform Enhanced)

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
VERSION := 2.1
DOCKER_COMPOSE_VERSION := $(shell docker-compose --version 2>/dev/null || echo "Not installed")
DOCKER_VERSION := $(shell docker --version 2>/dev/null || echo "Not installed")

# ========================================
# 跨平台支持配置（新增）
# ========================================
# 主机架构检测
HOST_ARCH := $(shell uname -m)
HOST_OS := $(shell uname -s)

# 架构映射
ARCH_MAP_x86_64 := amd64
ARCH_MAP_aarch64 := arm64
ARCH_MAP_arm64 := arm64
TARGET_ARCH := $(or $(ARCH_MAP_$(HOST_ARCH)),amd64)

# 操作系统映射
OS_MAP_Darwin := linux
OS_MAP_Linux := linux
TARGET_OS := $(or $(OS_MAP_$(HOST_OS)),linux)

# 平台定义
DOCKER_PLATFORM := linux/$(TARGET_ARCH)
BUILD_PLATFORM := linux/amd64
TARGET_PLATFORM := linux/amd64

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

# 声明所有目标为伪目标（增强版）
.PHONY: help quick info commands dev test prod stop restart clean logs backup status build init check \
        web-install web-dev web-remove web-shell web-logs web-status web-restart web-rebuild \
        server-shell server-logs server-restart server-rebuild \
        db-shell db-logs db-backup db-restore db-reset \
        redis-shell redis-logs redis-restart redis-flush \
        docker-clean docker-prune docker-update \
        lint test-unit test-e2e \
        deploy-dev deploy-test deploy-prod \
        monitor health debug troubleshoot \
        dev-smart dev-amd64 dev-arm64 dev-native dev-wizard \
        fix-platform-issues multiplatform-status verify-platform-fix \
        clean-rebuild quick-fix test-multiplatform dev-monitor \
        help-multiplatform

# 默认目标
.DEFAULT_GOAL := help

# 增强的主帮助菜单
help:
	@echo ""
	@echo "$(CYAN)🚀 $(PROJECT_NAME) - 开发环境管理（跨平台增强版）$(NC)"
	@echo "$(CYAN)版本: $(VERSION)$(NC)"
	@echo "$(CYAN)主机: $(HOST_OS)/$(HOST_ARCH) → 目标: $(TARGET_PLATFORM)$(NC)"
	@echo "$(CYAN)======================================$(NC)"
	@echo ""
	@echo "$(YELLOW)📦 环境管理:$(NC)"
	@echo "  $(GREEN)make dev$(NC)                     - 启动开发环境（智能模式）"
	@echo "  $(GREEN)make dev-wizard$(NC)              - 开发环境启动向导 ⭐"
	@echo "  $(GREEN)make dev-smart$(NC)               - 智能启动（推荐）"
	@echo "  $(GREEN)make test$(NC)                    - 启动测试环境"
	@echo "  $(GREEN)make prod$(NC)                    - 启动生产环境"
	@echo "  $(GREEN)make stop [ENV=<env>]$(NC)        - 停止指定环境"
	@echo "  $(GREEN)make restart [ENV=<env>]$(NC)     - 重启指定环境"
	@echo "  $(GREEN)make remove [ENV=<env>]$(NC)      - 删除指定环境容器"
	@echo "  $(GREEN)make stop-remove [ENV=<env>]$(NC) - 停止并删除指定环境"
	@echo "  $(GREEN)make status$(NC)                  - 查看所有环境状态"
	@echo "  $(GREEN)make build [ENV=<env>]$(NC)       - 构建指定环境镜像"
	@echo "  $(GREEN)make clean$(NC)                   - 清理所有环境"
	@echo ""
	@echo "$(YELLOW)🌍 跨平台支持:$(NC)"
	@echo "  $(GREEN)make dev-amd64$(NC)               - AMD64 模式（部署兼容）"
	@echo "  $(GREEN)make dev-arm64$(NC)               - ARM64 模式（Apple Silicon）"
	@echo "  $(GREEN)make dev-native$(NC)              - 本地架构（最佳性能）"
	@echo "  $(GREEN)make fix-platform-issues$(NC)     - 修复跨平台问题 🔧"
	@echo "  $(GREEN)make multiplatform-status$(NC)    - 跨平台状态诊断"
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
	@echo "  $(GREEN)make quick-fix$(NC)               - 快速故障排除 ⚡"
	@echo "  $(GREEN)make dev-monitor$(NC)             - 实时环境监控"
	@echo ""
	@echo "$(YELLOW)📚 使用示例:$(NC)"
	@echo "  $(BLUE)make dev-wizard$(NC)                    # 启动向导（新手推荐）"
	@echo "  $(BLUE)make dev-smart$(NC)                     # 智能启动"
	@echo "  $(BLUE)make fix-platform-issues$(NC)           # 修复架构问题"
	@echo "  $(BLUE)make web-install PKGS='mobx axios'$(NC) # 安装前端包"
	@echo "  $(BLUE)make logs ENV=dev$(NC)                  # 查看开发环境日志"
	@echo ""
	@echo "$(YELLOW)💡 快捷命令:$(NC)"
	@echo "  $(PURPLE)make quick$(NC)      - 快速帮助"
	@echo "  $(PURPLE)make info$(NC)       - 环境信息"
	@echo "  $(PURPLE)make commands$(NC)   - 所有命令"
	@echo "  $(PURPLE)make help-multiplatform$(NC) - 跨平台帮助"
	@echo ""

# 快速帮助（增强版）
quick:
	@echo ""
	@echo "$(CYAN)⚡ 快速命令参考（跨平台增强版）$(NC)"
	@echo "$(CYAN)==================$(NC)"
	@echo ""
	@echo "$(YELLOW)🚀 启动开发:$(NC)"
	@echo "  $(GREEN)make dev-wizard$(NC)           # 启动向导（推荐新手）"
	@echo "  $(GREEN)make dev-smart$(NC)            # 智能启动"
	@echo "  $(GREEN)make dev$(NC)                  # 标准启动"
	@echo "  $(GREEN)make web-shell$(NC)            # 进入前端容器"
	@echo "  $(GREEN)make server-shell$(NC)         # 进入后端容器"
	@echo ""
	@echo "$(YELLOW)🔧 常见问题:$(NC)"
	@echo "  $(GREEN)make fix-platform-issues$(NC)  # 修复架构问题"
	@echo "  $(GREEN)make quick-fix$(NC)            # 快速故障排除"
	@echo "  $(GREEN)make clean-rebuild$(NC)        # 完全重建"
	@echo "  $(GREEN)make multiplatform-status$(NC) # 诊断架构状态"
	@echo ""
	@echo "$(YELLOW)⚡ 当前主机:$(NC)"
	@echo "  架构: $(CYAN)$(HOST_ARCH)$(NC)"
	@echo "  系统: $(CYAN)$(HOST_OS)$(NC)"
	@echo "  目标: $(CYAN)$(TARGET_PLATFORM)$(NC)"
	@echo ""

# 环境信息（增强版）
info:
	@echo ""
	@echo "$(CYAN)🔍 $(PROJECT_NAME) - 环境信息（跨平台增强版）$(NC)"
	@echo "$(CYAN)================================$(NC)"
	@echo ""
	@echo "$(YELLOW)📊 系统信息:$(NC)"
	@echo "  项目版本: $(VERSION)"
	@echo "  Docker版本: $(shell docker --version 2>/dev/null | cut -d' ' -f3 | cut -d',' -f1 || echo '未安装')"
	@echo "  Docker Compose版本: $(shell docker-compose --version 2>/dev/null | cut -d' ' -f4 | cut -d',' -f1 || echo '未安装')"
	@echo "  操作系统: $(HOST_OS) $(HOST_ARCH)"
	@echo "  当前用户: $(shell whoami)"
	@echo "  工作目录: $(shell pwd)"
	@echo ""
	@echo "$(YELLOW)🌍 跨平台配置:$(NC)"
	@echo "  主机架构: $(HOST_ARCH)"
	@echo "  目标架构: $(TARGET_ARCH)"
	@echo "  构建平台: $(BUILD_PLATFORM)"
	@echo "  目标平台: $(TARGET_PLATFORM)"
	@echo "  Docker平台: $(DOCKER_PLATFORM)"
	@echo ""
	@echo "$(YELLOW)🔧 技术栈:$(NC)"
	@echo "  后端: Go 1.24.3 + Gin + GORM + MySQL + Redis"
	@echo "  前端: React 19 + TypeScript + Vite + Ant Design"
	@echo "  容器: Docker + Docker Compose（跨平台支持）"
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

# 所有命令列表（增强版）
commands:
	@echo ""
	@echo "$(CYAN)📋 所有可用命令（跨平台增强版）$(NC)"
	@echo "$(CYAN)=================$(NC)"
	@echo ""
	@echo "$(YELLOW)环境管理:$(NC)"
	@echo "  dev, test, prod, stop, restart, status, build, clean"
	@echo ""
	@echo "$(YELLOW)跨平台环境:$(NC)"
	@echo "  dev-wizard, dev-smart, dev-amd64, dev-arm64, dev-native"
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
	@echo "  monitor, health, debug, troubleshoot, quick-fix, dev-monitor"
	@echo ""
	@echo "$(YELLOW)跨平台工具:$(NC)"
	@echo "  fix-platform-issues, multiplatform-status, verify-platform-fix"
	@echo "  clean-rebuild, test-multiplatform"
	@echo ""
	@echo "$(YELLOW)实用工具:$(NC)"
	@echo "  check, init, help, quick, info, commands, help-multiplatform"
	@echo ""

# ========================================
# 增强的环境启动命令
# ========================================

# 智能开发环境启动（替换原有的 dev 命令）
dev:
	@echo "$(YELLOW)🚀 启动开发环境（智能模式）...$(NC)"
	@echo "$(CYAN)主机信息: $(HOST_OS)/$(HOST_ARCH)$(NC)"
	@echo "$(CYAN)目标平台: $(TARGET_PLATFORM)$(NC)"
	@cd $(ENVS_DIR)/development && \
		BUILDPLATFORM=$(BUILD_PLATFORM) \
		TARGETPLATFORM=$(TARGET_PLATFORM) \
		TARGETOS=linux \
		TARGETARCH=amd64 \
		docker-compose --env-file .env up -d --build
	@echo ""
	@echo "$(GREEN)✅ 开发环境启动完成$(NC)"
	@echo ""
	@echo "$(CYAN)🌐 访问地址:$(NC)"
	@echo "  📱 前端: $(BLUE)http://localhost:3000$(NC)"
	@echo "  🔧 后端: $(BLUE)http://localhost:8080$(NC)"
	@echo "  🗄️ 数据库: $(BLUE)localhost:3306$(NC)"
	@echo ""
	@echo "$(CYAN)💡 常用命令:$(NC)"
	@echo "  $(GREEN)make multiplatform-status$(NC)  # 查看跨平台状态"
	@echo "  $(GREEN)make logs ENV=dev$(NC)          # 查看日志"
	@echo "  $(GREEN)make web-shell$(NC)             # 进入前端容器"
	@echo "  $(GREEN)make server-shell$(NC)          # 进入后端容器"
	@echo "  $(GREEN)make stop ENV=dev$(NC)          # 停止环境"
	@echo "  $(GREEN)make health$(NC)                # 健康检查"
	@echo ""

# ========================================
# 新增的跨平台命令
# ========================================

# 开发环境启动向导
dev-wizard:
	@echo "$(YELLOW)🧙 开发环境启动向导$(NC)"
	@echo "========================"
	@echo ""
	@echo "主机信息: $(CYAN)$(HOST_OS)/$(HOST_ARCH)$(NC)"
	@echo ""
	@echo "请选择启动模式:"
	@echo "  $(GREEN)1.$(NC) 智能模式 (推荐) - 自动选择最佳架构"
	@echo "  $(GREEN)2.$(NC) AMD64 模式 - 部署兼容，适合生产环境测试"
	@echo "  $(GREEN)3.$(NC) 本地架构 - 最佳性能，适合日常开发"
	@echo "  $(GREEN)4.$(NC) ARM64 模式 - Apple Silicon 原生"
	@echo "  $(GREEN)5.$(NC) 修复模式 - 解决架构问题"
	@echo ""
	@read -p "请输入选择 (1-5): " choice; \
	case $$choice in \
		1) echo "$(CYAN)启动智能模式...$(NC)" && make dev-smart ;; \
		2) echo "$(CYAN)启动 AMD64 模式...$(NC)" && make dev-amd64 ;; \
		3) echo "$(CYAN)启动本地架构模式...$(NC)" && make dev-native ;; \
		4) echo "$(CYAN)启动 ARM64 模式...$(NC)" && make dev-arm64 ;; \
		5) echo "$(CYAN)启动修复模式...$(NC)" && make fix-platform-issues ;; \
		*) echo "$(RED)无效选择，使用智能模式$(NC)" && make dev-smart ;; \
	esac

# 智能开发环境启动
dev-smart:
	@echo "$(YELLOW)🤖 智能启动开发环境...$(NC)"
	@echo "$(CYAN)检测主机架构: $(HOST_ARCH)$(NC)"
	@if [ "$(HOST_ARCH)" = "x86_64" ]; then \
		echo "$(CYAN)使用 AMD64 原生模式$(NC)"; \
		make dev-amd64; \
	elif [ "$(HOST_ARCH)" = "aarch64" ] || [ "$(HOST_ARCH)" = "arm64" ]; then \
		echo "$(CYAN)检测到 ARM64，使用兼容模式（AMD64）$(NC)"; \
		make dev-amd64; \
	else \
		echo "$(YELLOW)未知架构，使用默认模式$(NC)"; \
		make dev; \
	fi

# AMD64 强制模式（部署兼容）
dev-amd64:
	@echo "$(YELLOW)🚀 启动 AMD64 开发环境...$(NC)"
	@echo "$(CYAN)强制使用 AMD64 架构$(NC)"
	@cd $(ENVS_DIR)/development && \
		BUILDPLATFORM=linux/amd64 \
		TARGETPLATFORM=linux/amd64 \
		TARGETOS=linux \
		TARGETARCH=amd64 \
		docker-compose --env-file .env up -d --build
	@echo "$(GREEN)✅ AMD64 环境启动完成$(NC)"

# ARM64 强制模式（Apple Silicon 优化）
dev-arm64:
	@echo "$(YELLOW)🚀 启动 ARM64 开发环境...$(NC)"
	@echo "$(CYAN)强制使用 ARM64 架构$(NC)"
	@cd $(ENVS_DIR)/development && \
		BUILDPLATFORM=linux/arm64 \
		TARGETPLATFORM=linux/arm64 \
		TARGETOS=linux \
		TARGETARCH=arm64 \
		docker-compose --env-file .env up -d --build
	@echo "$(GREEN)✅ ARM64 环境启动完成$(NC)"

# 本地架构开发（最佳性能）
dev-native:
	@echo "$(YELLOW)🚀 启动本地架构开发环境...$(NC)"
	@echo "$(CYAN)使用本地架构: $(HOST_OS)/$(HOST_ARCH)$(NC)"
	@cd $(ENVS_DIR)/development && \
		BUILDPLATFORM=linux/$(TARGET_ARCH) \
		TARGETPLATFORM=linux/$(TARGET_ARCH) \
		TARGETOS=linux \
		TARGETARCH=$(TARGET_ARCH) \
		docker-compose --env-file .env up -d --build
	@echo "$(GREEN)✅ 本地架构环境启动完成$(NC)"

# 完整的平台问题修复
fix-platform-issues:
	@echo "$(YELLOW)🔧 修复跨平台问题$(NC)"
	@echo "=================================="
	@echo ""
	@echo "$(CYAN)步骤 1/6: 诊断环境$(NC)"
	@make multiplatform-status
	@echo ""
	@echo "$(CYAN)步骤 2/6: 停止所有服务$(NC)"
	@make stop ENV=dev || true
	@echo ""
	@echo "$(CYAN)步骤 3/6: 清理本地冲突文件$(NC)"
	@rm -f pubfree-server/server
	@rm -rf pubfree-web/node_modules
	@rm -f pubfree-web/package-lock.json
	@echo ""
	@echo "$(CYAN)步骤 4/6: 完全清理容器$(NC)"
	@cd $(ENVS_DIR)/development && docker-compose down --rmi all -v 2>/dev/null || true
	@docker system prune -f
	@echo ""
	@echo "$(CYAN)步骤 5/6: 重新构建（跨平台模式）$(NC)"
	@cd $(ENVS_DIR)/development && \
		DOCKER_BUILDKIT=1 \
		BUILDPLATFORM=$(BUILD_PLATFORM) \
		TARGETPLATFORM=$(TARGET_PLATFORM) \
		TARGETOS=linux \
		TARGETARCH=amd64 \
		docker-compose build --no-cache
	@echo ""
	@echo "$(CYAN)步骤 6/6: 启动环境$(NC)"
	@make dev
	@echo ""
	@echo "$(GREEN)✅ 跨平台问题修复完成！$(NC)"
	@sleep 15
	@make verify-platform-fix

# 跨平台状态诊断
multiplatform-status:
	@echo "$(YELLOW)🔍 跨平台状态诊断$(NC)"
	@echo "======================"
	@echo ""
	@echo "$(CYAN)主机信息:$(NC)"
	@echo "操作系统: $(HOST_OS)"
	@echo "主机架构: $(HOST_ARCH)"
	@echo "Docker版本: $(shell docker --version | cut -d' ' -f3 | cut -d',' -f1)"
	@echo "Docker Compose版本: $(shell docker-compose --version | cut -d' ' -f4 | cut -d',' -f1)"
	@echo ""
	@echo "$(CYAN)平台映射:$(NC)"
	@echo "目标架构: $(TARGET_ARCH)"
	@echo "目标系统: $(TARGET_OS)"
	@echo "构建平台: $(BUILD_PLATFORM)"
	@echo "目标平台: $(TARGET_PLATFORM)"
	@echo ""
	@echo "$(CYAN)Docker 平台支持:$(NC)"
	@docker buildx ls 2>/dev/null | head -5 || echo "Buildx 不可用"
	@echo ""
	@echo "$(CYAN)本地文件检查:$(NC)"
	@if [ -f "pubfree-server/server" ]; then \
		echo "⚠️ 发现本地 server 文件: $(shell ls -la pubfree-server/server | awk '{print $$5, $$6, $$7, $$8}')"; \
		echo "   建议删除: rm pubfree-server/server"; \
	else \
		echo "✅ 无本地 server 文件冲突"; \
	fi
	@if [ -d "pubfree-web/node_modules" ]; then \
		echo "⚠️ 发现本地 node_modules"; \
		echo "   如有问题可删除: rm -rf pubfree-web/node_modules"; \
	else \
		echo "✅ 无本地 node_modules 冲突"; \
	fi

# 验证平台修复结果
verify-platform-fix:
	@echo "$(YELLOW)🔍 验证跨平台修复结果$(NC)"
	@echo "============================="
	@echo ""
	@echo "$(CYAN)主机信息:$(NC)"
	@echo "操作系统: $(HOST_OS)"
	@echo "主机架构: $(HOST_ARCH)"
	@echo "目标平台: $(TARGET_PLATFORM)"
	@echo ""
	@echo "$(CYAN)容器状态:$(NC)"
	@docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Image}}" | grep pubfree || echo "容器未运行"
	@echo ""
	@echo "$(CYAN)后端服务检查:$(NC)"
	@if docker ps -q --filter "name=$(SERVER_CONTAINER)" > /dev/null 2>&1; then \
		echo "容器状态: ✅ 运行中"; \
		echo -n "容器架构: "; docker exec $(SERVER_CONTAINER) uname -m 2>/dev/null || echo "无法获取"; \
		echo -n "二进制格式: "; docker exec $(SERVER_CONTAINER) file /app/server 2>/dev/null | cut -d: -f2 | tr -d ' ' || echo "无法获取"; \
		echo -n "服务响应: "; curl -s http://localhost:8080/health >/dev/null 2>&1 && echo "✅ 正常" || echo "❌ 异常"; \
	else \
		echo "❌ 后端容器未运行"; \
	fi
	@echo ""
	@echo "$(CYAN)前端服务检查:$(NC)"
	@if docker ps -q --filter "name=$(WEB_CONTAINER)" > /dev/null 2>&1; then \
		echo "容器状态: ✅ 运行中"; \
		echo -n "服务响应: "; curl -s http://localhost:3000 >/dev/null 2>&1 && echo "✅ 正常" || echo "❌ 异常"; \
	else \
		echo "❌ 前端容器未运行"; \
	fi

# 完全重建环境
clean-rebuild:
	@echo "$(YELLOW)🔄 完全重建开发环境...$(NC)"
	@echo "$(RED)⚠️ 这将删除所有容器、镜像和数据$(NC)"
	@read -p "确认继续? (y/N): " confirm && [ "$$confirm" = "y" ]
	@echo ""
	@echo "$(CYAN)停止所有服务...$(NC)"
	@make stop ENV=dev || true
	@echo ""
	@echo "$(CYAN)清理所有资源...$(NC)"
	@cd $(ENVS_DIR)/development && docker-compose down --rmi all -v
	@docker system prune -af
	@echo ""
	@echo "$(CYAN)清理本地文件...$(NC)"
	@rm -f pubfree-server/server
	@rm -rf pubfree-web/node_modules
	@rm -f pubfree-web/package-lock.json
	@echo ""
	@echo "$(CYAN)重新构建...$(NC)"
	@make dev-smart
	@echo ""
	@echo "$(GREEN)✅ 完全重建完成$(NC)"

# 快速故障排除
quick-fix:
	@echo "$(YELLOW)⚡ 快速故障排除$(NC)"
	@echo "=================="
	@echo ""
	@echo "$(CYAN)1. 检查常见问题$(NC)"
	@make multiplatform-status
	@echo ""
	@echo "$(CYAN)2. 重启服务$(NC)"
	@make restart ENV=dev
	@echo ""
	@echo "$(CYAN)3. 验证服务$(NC)"
	@sleep 10
	@make health
	@echo ""
	@if ! curl -s http://localhost:8080/health >/dev/null 2>&1; then \
		echo "$(RED)❌ 后端服务异常，执行深度修复...$(NC)"; \
		make fix-platform-issues; \
	else \
		echo "$(GREEN)✅ 服务运行正常$(NC)"; \
	fi

# 多平台构建测试
test-multiplatform:
	@echo "$(YELLOW)🧪 测试多平台构建...$(NC)"
	@echo "======================"
	@echo ""
	@echo "$(CYAN)测试 AMD64 构建...$(NC)"
	@cd pubfree-server && \
		DOCKER_BUILDKIT=1 docker buildx build \
		--platform linux/amd64 \
		--file Dockerfile.dev \
		--tag pubfree-server:test-amd64 \
		--load .
	@echo "$(GREEN)✅ AMD64 构建成功$(NC)"
	@echo ""
	@echo "$(CYAN)测试 ARM64 构建...$(NC)"
	@cd pubfree-server && \
		DOCKER_BUILDKIT=1 docker buildx build \
		--platform linux/arm64 \
		--file Dockerfile.dev \
		--tag pubfree-server:test-arm64 \
		--load .
	@echo "$(GREEN)✅ ARM64 构建成功$(NC)"
	@echo ""
	@echo "$(CYAN)清理测试镜像...$(NC)"
	@docker rmi pubfree-server:test-amd64 pubfree-server:test-arm64 2>/dev/null || true
	@echo "$(GREEN)✅ 多平台构建测试完成$(NC)"

# 开发模式监控
dev-monitor:
	@echo "$(YELLOW)📊 开发环境监控$(NC)"
	@echo "=================="
	@while true; do \
		clear; \
		echo "$(CYAN)=== PubFree 开发环境实时监控 ===$(NC)"; \
		echo "时间: $(date)"; \
		echo "主机: $(HOST_OS)/$(HOST_ARCH) → 目标: $(TARGET_PLATFORM)"; \
		echo ""; \
		echo "$(YELLOW)容器状态:$(NC)"; \
		docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}" | grep pubfree || echo "无运行容器"; \
		echo ""; \
		echo "$(YELLOW)服务健康:$(NC)"; \
		curl -s http://localhost:8080/health >/dev/null 2>&1 && echo "✅ 后端: 正常" || echo "❌ 后端: 异常"; \
		curl -s http://localhost:3000 >/dev/null 2>&1 && echo "✅ 前端: 正常" || echo "❌ 前端: 异常"; \
		echo ""; \
		echo "$(YELLOW)资源使用:$(NC)"; \
		docker stats --no-stream --format "table {{.Name}}\t{{.CPUPerc}}\t{{.MemUsage}}" | grep pubfree || echo "无数据"; \
		echo ""; \
		echo "按 Ctrl+C 退出监控"; \
		sleep 5; \
	done

# 跨平台帮助信息
help-multiplatform:
	@echo ""
	@echo "$(YELLOW)🌍 跨平台开发详细帮助$(NC)"
	@echo "=========================="
	@echo ""
	@echo "$(CYAN)🎯 推荐使用流程:$(NC)"
	@echo "  1. $(GREEN)make dev-wizard$(NC)              # 新手启动向导"
	@echo "  2. $(GREEN)make multiplatform-status$(NC)    # 检查环境状态"
	@echo "  3. $(GREEN)make dev-smart$(NC)               # 智能启动开发环境"
	@echo "  4. $(GREEN)make health$(NC)                  # 验证服务健康"
	@echo ""
	@echo "$(CYAN)🔧 启动模式选择:$(NC)"
	@echo "  $(GREEN)make dev-smart$(NC)               - 智能模式（推荐）"
	@echo "  $(GREEN)make dev-amd64$(NC)               - AMD64 模式（部署兼容）"
	@echo "  $(GREEN)make dev-arm64$(NC)               - ARM64 模式（Apple Silicon）"
	@echo "  $(GREEN)make dev-native$(NC)              - 本地架构（最佳性能）"
	@echo ""
	@echo "$(CYAN)🆘 问题解决:$(NC)"
	@echo "  $(GREEN)make fix-platform-issues$(NC)     - 一键修复跨平台问题"
	@echo "  $(GREEN)make quick-fix$(NC)               - 快速故障排除"
	@echo "  $(GREEN)make clean-rebuild$(NC)           - 完全重建环境"
	@echo "  $(GREEN)make multiplatform-status$(NC)    - 诊断平台状态"
	@echo "  $(GREEN)make verify-platform-fix$(NC)     - 验证修复结果"
	@echo ""
	@echo "$(CYAN)🧪 测试和监控:$(NC)"
	@echo "  $(GREEN)make test-multiplatform$(NC)      - 测试多平台构建"
	@echo "  $(GREEN)make dev-monitor$(NC)             - 实时环境监控"
	@echo ""
	@echo "$(CYAN)📋 当前环境信息:$(NC)"
	@echo "  主机架构: $(CYAN)$(HOST_ARCH)$(NC)"
	@echo "  主机系统: $(CYAN)$(HOST_OS)$(NC)"
	@echo "  目标架构: $(CYAN)$(TARGET_ARCH)$(NC)"
	@echo "  构建平台: $(CYAN)$(BUILD_PLATFORM)$(NC)"
	@echo "  目标平台: $(CYAN)$(TARGET_PLATFORM)$(NC)"
	@echo ""
	@echo "$(YELLOW)🆘 常见问题速查:$(NC)"
	@echo "  $(BLUE)Exec format error$(NC):           make fix-platform-issues"
	@echo "  $(BLUE)容器启动失败$(NC):               make quick-fix"
	@echo "  $(BLUE)架构不兼容$(NC):                 make dev-wizard"
	@echo "  $(BLUE)性能问题$(NC):                   make dev-native"
	@echo "  $(BLUE)Rollup/npm 错误$(NC):            make clean-rebuild"
	@echo "  $(BLUE)不知道用哪个命令$(NC):           make dev-wizard"
	@echo ""

# ========================================
# 保持原有的环境启动命令
# ========================================

test:
	@echo "$(YELLOW)🧪 启动测试环境...$(NC)"
	@cd $(ENVS_DIR)/testing && docker-compose --env-file .env up -d --build
	@echo "$(GREEN)✅ 测试环境启动完成$(NC)"

prod:
	@echo "$(YELLOW)🏭 启动生产环境...$(NC)"
	@echo "$(RED)⚠️  请确保已配置生产环境的环境变量$(NC)"
	@read -p "确认启动生产环境? (y/N): " confirm && [ "$confirm" = "y" ]
	@cd $(ENVS_DIR)/production && docker-compose --env-file .env up -d --build
	@echo "$(GREEN)✅ 生产环境启动完成$(NC)"

# 环境控制
stop:
	@echo "$(YELLOW)🛑 停止$(ENV)环境...$(NC)"
	@if [ "$(ENV)" = "dev" ]; then \
		echo "$(CYAN)停止开发环境容器...$(NC)"; \
		docker stop $(WEB_CONTAINER) $(SERVER_CONTAINER) $(MYSQL_CONTAINER) $(REDIS_CONTAINER) 2>/dev/null || true; \
	else \
		cd $(ENVS_DIR)/$(call env_dir,$(ENV)) && docker-compose down --no-build; \
	fi
	@echo "$(GREEN)✅ $(ENV)环境已停止$(NC)"

# 删除容器
remove:
	@echo "$(YELLOW)🗑️ 删除$(ENV)环境容器...$(NC)"
	@cd $(ENVS_DIR)/$(call env_dir,$(ENV)) && docker-compose rm -f
	@echo "$(GREEN)✅ $(ENV)环境容器已删除$(NC)"

# 停止并删除容器
stop-remove:
	@make stop ENV=$(ENV)
	@make remove ENV=$(ENV)

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

db-init:
	@echo "$(YELLOW)🔧 初始化开发数据库...$(NC)"
	@docker exec -it $(MYSQL_CONTAINER) mysql -u root -p -e "source /docker-entrypoint-initdb.d/init.sql"
	@echo "$(GREEN)✅ 开发数据库已初始化$(NC)"

db-init-dev:
	@echo "$(YELLOW)🔧 初始化开发数据库...$(NC)"
	@docker exec -it $(MYSQL_CONTAINER) mysql -u root -p -e "source /docker-entrypoint-initdb.d/init.sql"
	@echo "$(GREEN)✅ 开发数据库已初始化$(NC)"


db-rebuild:
	@echo "$(YELLOW)🔨 重建开发数据库...$(NC)"
	@docker exec -it $(MYSQL_CONTAINER) mysql -u root -p -e "DROP DATABASE IF EXISTS pubfree_dev; CREATE DATABASE pubfree_dev;"
	@docker exec -it $(MYSQL_CONTAINER) mysql -u root -p -e "source /docker-entrypoint-initdb.d/init.sql"
	@echo "$(GREEN)✅ 开发数据库已重建$(NC)"

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
	@docker pull node:20.19.0-slim
	@docker pull golang:1.24.3-alpine
	@echo "$(GREEN)✅ Docker镜像更新完成$(NC)"

# 监控和调试（增强版）
monitor:
	@echo "$(YELLOW)📊 系统监控面板（跨平台增强版）$(NC)"
	@echo "容器状态:"
	@docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"
	@echo ""
	@echo "平台信息:"
	@echo "主机: $(HOST_OS)/$(HOST_ARCH) → 目标: $(TARGET_PLATFORM)"
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
	@echo "$(YELLOW)🐛 调试信息（跨平台增强版）$(NC)"
	@echo "==============="
	@echo ""
	@echo "$(CYAN)环境变量:$(NC)"
	@echo "ENV = $(ENV)"
	@echo "PROJECT_NAME = $(PROJECT_NAME)"
	@echo "VERSION = $(VERSION)"
	@echo "HOST_ARCH = $(HOST_ARCH)"
	@echo "TARGET_ARCH = $(TARGET_ARCH)"
	@echo "TARGET_PLATFORM = $(TARGET_PLATFORM)"
	@echo ""
	@echo "$(CYAN)容器状态:$(NC)"
	@docker ps -a --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"
	@echo ""
	@echo "$(CYAN)Docker信息:$(NC)"
	@docker info | head -20

troubleshoot:
	@echo "$(YELLOW)🔧 故障排查（跨平台增强版）$(NC)"
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
	@echo "$(CYAN)4. 检查架构兼容性$(NC)"
	@echo "主机架构: $(HOST_ARCH)"
	@echo "目标架构: $(TARGET_ARCH)"
	@if [ -f "pubfree-server/server" ]; then \
		echo "⚠️ 发现本地server文件，可能导致架构冲突"; \
	else \
		echo "✅ 无本地server文件冲突"; \
	fi
	@echo ""
	@echo "$(CYAN)5. 建议解决方案$(NC)"
	@echo "  • 跨平台问题: make fix-platform-issues"
	@echo "  • 端口占用: make stop ENV=dev"
	@echo "  • 配置缺失: make init"
	@echo "  • 环境异常: make clean-rebuild"
	@echo "  • 架构问题: make dev-wizard"

# 日志查看
logs:
	@echo "$(YELLOW)📋 查看$(ENV)环境日志$(NC)"
	@cd $(ENVS_DIR)/$(call env_dir,$(ENV)) && docker-compose logs -f

# 备份
backup:
	@echo "$(YELLOW)💾 备份$(ENV)环境数据库...$(NC)"
	@$(SCRIPTS_DIR)/backup-$(ENV).sh

# 清理
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