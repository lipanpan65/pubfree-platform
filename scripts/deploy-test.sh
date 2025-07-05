#!/bin/bash

# 测试环境部署脚本
set -e

echo "🧪 开始部署测试环境..."

# 检查Docker是否运行
if ! docker info > /dev/null 2>&1; then
    echo "❌ Docker未运行，请先启动Docker"
    exit 1
fi

# 进入项目根目录
cd "$(dirname "$0")/.."

# 检查环境配置文件
if [ ! -f "environments/testing/.env" ]; then
    echo "❌ 测试环境配置文件不存在"
    echo "请复制 environments/testing/.env.example 到 environments/testing/.env"
    exit 1
fi

# 创建必要的目录
mkdir -p logs/testing
mkdir -p uploads/testing
mkdir -p backups/testing

# 备份当前数据库（如果存在）
if docker ps | grep -q "pubfree-mysql-test"; then
    echo "💾 备份当前数据库..."
    ./scripts/backup-test.sh
fi

# 进入测试环境目录
cd environments/testing

# 停止现有容器
echo "🛑 停止现有容器..."
docker-compose down

# 拉取最新镜像
echo "📥 拉取最新基础镜像..."
docker-compose pull

# 构建并启动容器
echo "🔨 构建并启动容器..."
docker-compose --env-file .env up -d --build

# 等待服务启动
echo "⏳ 等待服务启动..."
sleep 60

# 检查服务状态
echo "🔍 检查服务状态..."
docker-compose ps

# 健康检查
echo "🏥 执行健康检查..."
max_attempts=30
attempt=0

while [ $attempt -lt $max_attempts ]; do
    if curl -f http://localhost:8080/health > /dev/null 2>&1; then
        echo "✅ 后端服务正常"
        break
    else
        echo "⏳ 等待后端服务启动... ($((attempt + 1))/$max_attempts)"
        sleep 10
        attempt=$((attempt + 1))
    fi
done

if [ $attempt -eq $max_attempts ]; then
    echo "❌ 后端服务启动失败"
    docker-compose logs pubfree-server
    exit 1
fi

# 检查前端服务
if curl -f http://localhost:3000 > /dev/null 2>&1; then
    echo "✅ 前端服务正常"
else
    echo "❌ 前端服务异常"
    docker-compose logs pubfree-web
    exit 1
fi

# 运行测试
echo "🧪 运行集成测试..."
# 这里可以添加测试脚本
# ./scripts/run-tests.sh

echo "🎉 测试环境部署完成！"
echo ""
echo "📱 前端地址: http://localhost:3000"
echo "🔧 后端地址: http://localhost:8080"
echo "🌐 Nginx地址: http://localhost"
echo ""
echo "查看日志: docker-compose logs -f"
echo "停止服务: docker-compose down"