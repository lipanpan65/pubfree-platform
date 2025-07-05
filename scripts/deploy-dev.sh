#!/bin/bash

# 开发环境部署脚本
set -e

echo "🚀 开始部署开发环境..."

# 检查Docker是否运行
if ! docker info > /dev/null 2>&1; then
    echo "❌ Docker未运行，请先启动Docker"
    exit 1
fi

# 进入项目根目录
cd "$(dirname "$0")/.."

# 检查环境配置文件
if [ ! -f "environments/development/.env" ]; then
    echo "❌ 开发环境配置文件不存在"
    echo "请复制 environments/development/.env.example 到 environments/development/.env"
    exit 1
fi

# 创建必要的目录
mkdir -p logs/development
mkdir -p uploads/development
mkdir -p backups/development

# 设置权限
chmod +x scripts/*.sh

# 进入开发环境目录
cd environments/development

# 停止现有容器
echo "🛑 停止现有容器..."
docker-compose down

# 构建并启动容器
echo "🔨 构建并启动容器..."
docker-compose --env-file .env up -d --build

# 等待服务启动
echo "⏳ 等待服务启动..."
sleep 30

# 检查服务状态
echo "🔍 检查服务状态..."
docker-compose ps

# 健康检查
echo "🏥 执行健康检查..."
if curl -f http://localhost:8080/health > /dev/null 2>&1; then
    echo "✅ 后端服务正常"
else
    echo "❌ 后端服务异常"
    docker-compose logs pubfree-server
    exit 1
fi

if curl -f http://localhost:3000 > /dev/null 2>&1; then
    echo "✅ 前端服务正常"
else
    echo "❌ 前端服务异常"
    docker-compose logs pubfree-web
    exit 1
fi

echo "🎉 开发环境部署完成！"
echo ""
echo "📱 前端地址: http://localhost:3000"
echo "🔧 后端地址: http://localhost:8080"
echo "🗄️ 数据库端口: 3306"
echo "🔍 Redis端口: 6379"
echo ""
echo "查看日志: docker-compose logs -f"
echo "停止服务: docker-compose down"