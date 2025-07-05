# PubFree Platform Makefile
# 用于管理不同环境的部署和操作

.PHONY: help dev test prod clean logs backup

# 默认目标
help:
	@echo "PubFree Platform - 环境管理"
	@echo ""
	@echo "可用命令:"
	@echo "  make dev     - 启动开发环境"
	@echo "  make test    - 启动测试环境"
	@echo "  make prod    - 启动生产环境"
	@echo "  make clean   - 清理所有环境"
	@echo "  make logs    - 查看日志 (使用 ENV=dev/test/prod)"
	@echo "  make backup  - 备份数据库 (使用 ENV=test/prod)"
	@echo "  make stop    - 停止环境 (使用 ENV=dev/test/prod)"
	@echo "  make restart - 重启环境 (使用 ENV=dev/test/prod)"
	@echo ""
	@echo "示例:"
	@echo "  make dev"
	@echo "  make logs ENV=dev"
	@echo "  make stop ENV=test"
	@echo "  make backup ENV=prod"

# 开发环境
dev:
	@echo "🚀 启动开发环境..."
	@cd environments/development && docker-compose --env-file .env up -d --build
	@echo "✅ 开发环境启动完成"
	@echo "📱 前端地址: http://localhost:3000"
	@echo "🔧 后端地址: http://localhost:8080"
	@echo "🗄️ 数据库端口: 3306"

# 测试环境
test:
	@echo "🧪 启动测试环境..."
	@cd environments/testing && docker-compose --env-file .env up -d --build
	@echo "✅ 测试环境启动完成"
	@echo "📱 前端地址: http://localhost:3000"
	@echo "🔧 后端地址: http://localhost:8080"

# 生产环境
prod:
	@echo "🏭 启动生产环境..."
	@echo "⚠️  请确保已配置生产环境的环境变量"
	@read -p "确认启动生产环境? (y/N): " confirm && [ "$$confirm" = "y" ]
	@cd environments/production && docker-compose --env-file .env up -d --build
	@echo "✅ 生产环境启动完成"
	@echo "📊 监控地址: http://localhost:9090 (Prometheus)"
	@echo "📈 面板地址: http://localhost:3001 (Grafana)"

# 停止环境
stop:
	@if [ "$(ENV)" = "dev" ]; then \
		echo "🛑 停止开发环境..."; \
		cd environments/development && docker-compose down; \
	elif [ "$(ENV)" = "test" ]; then \
		echo "🛑 停止测试环境..."; \
		cd environments/testing && docker-compose down; \
	elif [ "$(ENV)" = "prod" ]; then \
		echo "🛑 停止生产环境..."; \
		cd environments/production && docker-compose down; \
	else \
		echo "❌ 请指定环境: make stop ENV=dev/test/prod"; \
	fi

# 重启环境
restart:
	@if [ "$(ENV)" = "dev" ]; then \
		echo "🔄 重启开发环境..."; \
		cd environments/development && docker-compose restart; \
	elif [ "$(ENV)" = "test" ]; then \
		echo "🔄 重启测试环境..."; \
		cd environments/testing && docker-compose restart; \
	elif [ "$(ENV)" = "prod" ]; then \
		echo "🔄 重启生产环境..."; \
		cd environments/production && docker-compose restart; \
	else \
		echo "❌ 请指定环境: make restart ENV=dev/test/prod"; \
	fi

# 查看日志
logs:
	@if [ "$(ENV)" = "dev" ]; then \
		echo "📋 开发环境日志:"; \
		cd environments/development && docker-compose logs -f; \
	elif [ "$(ENV)" = "test" ]; then \
		echo "📋 测试环境日志:"; \
		cd environments/testing && docker-compose logs -f; \
	elif [ "$(ENV)" = "prod" ]; then \
		echo "📋 生产环境日志:"; \
		cd environments/production && docker-compose logs -f; \
	else \
		echo "❌ 请指定环境: make logs ENV=dev/test/prod"; \
	fi

# 备份数据库
backup:
	@if [ "$(ENV)" = "test" ]; then \
		echo "💾 备份测试环境数据库..."; \
		./scripts/backup-test.sh; \
	elif [ "$(ENV)" = "prod" ]; then \
		echo "💾 备份生产环境数据库..."; \
		./scripts/backup-prod.sh; \
	else \
		echo "❌ 请指定环境: make backup ENV=test/prod"; \
	fi

# 清理所有环境
clean:
	@echo "🧹 清理所有环境..."
	@read -p "确认清理所有环境的容器和数据? (y/N): " confirm && [ "$$confirm" = "y" ]
	@cd environments/development && docker-compose down -v
	@cd environments/testing && docker-compose down -v
	@cd environments/production && docker-compose down -v
	@docker system prune -f
	@echo "✅ 清理完成"

# 查看状态
status:
	@echo "📊 环境状态:"
	@echo ""
	@echo "开发环境:"
	@cd environments/development && docker-compose ps
	@echo ""
	@echo "测试环境:"
	@cd environments/testing && docker-compose ps
	@echo ""
	@echo "生产环境:"
	@cd environments/production && docker-compose ps

# 构建镜像
build:
	@if [ "$(ENV)" = "dev" ]; then \
		echo "🔨 构建开发环境镜像..."; \
		cd environments/development && docker-compose build; \
	elif [ "$(ENV)" = "test" ]; then \
		echo "🔨 构建测试环境镜像..."; \
		cd environments/testing && docker-compose build; \
	elif [ "$(ENV)" = "prod" ]; then \
		echo "🔨 构建生产环境镜像..."; \
		cd environments/production && docker-compose build; \
	else \
		echo "❌ 请指定环境: make build ENV=dev/test/prod"; \
	fi

# 初始化环境
init:
	@echo "🔧 初始化项目环境..."
	@chmod +x scripts/*.sh
	@mkdir -p logs backups uploads
	@echo "✅ 初始化完成"

# 检查环境配置
check:
	@echo "🔍 检查环境配置..."
	@if [ -f "environments/development/.env" ]; then \
		echo "✅ 开发环境配置文件存在"; \
	else \
		echo "❌ 开发环境配置文件不存在"; \
	fi
	@if [ -f "environments/testing/.env" ]; then \
		echo "✅ 测试环境配置文件存在"; \
	else \
		echo "❌ 测试环境配置文件不存在"; \
	fi
	@if [ -f "environments/production/.env" ]; then \
		echo "✅ 生产环境配置文件存在"; \
	else \
		echo "❌ 生产环境配置文件不存在"; \
	fi