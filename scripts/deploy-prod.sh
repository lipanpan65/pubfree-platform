#!/bin/bash

# 生产环境部署脚本
set -e

echo "🏭 开始部署生产环境..."

# 检查是否为root用户
if [[ $EUID -ne 0 ]]; then
   echo "❌ 请使用root用户运行此脚本"
   exit 1
fi

# 检查Docker是否运行
if ! docker info > /dev/null 2>&1; then
    echo "❌ Docker未运行，请先启动Docker"
    exit 1
fi

# 进入项目根目录
cd "$(dirname "$0")/.."

# 检查环境配置文件
if [ ! -f "environments/production/.env" ]; then
    echo "❌ 生产环境配置文件不存在"
    echo "请复制 environments/production/.env.example 到 environments/production/.env"
    exit 1
fi

# 检查配置文件中的敏感信息
echo "🔍 检查配置文件..."
if grep -q "CHANGE_ME" environments/production/.env; then
    echo "❌ 请修改生产环境配置文件中的默认密码"
    exit 1
fi

# 确认部署
echo "⚠️  即将部署到生产环境，请确认以下信息："
echo "   - 已备份当前数据库"
echo "   - 已更新所有配置文件"
echo "   - 已测试所有功能"
echo ""
read -p "确认部署到生产环境? (yes/NO): " confirm
if [ "$confirm" != "yes" ]; then
    echo "❌ 部署取消"
    exit 1
fi

# 创建必要的目录
mkdir -p logs/production
mkdir -p uploads/production
mkdir -p backups/production

# 设置权限
chmod 755 logs/production
chmod 755 uploads/production
chmod 755 backups/production

# 备份当前数据库（如果存在）
if docker ps | grep -q "pubfree-mysql-prod"; then
    echo "💾 备份当前数据库..."
    ./scripts/backup-prod.sh
fi

# 进入生产环境目录
cd environments/production

# 停止现有容器（优雅关闭）
echo "🛑 停止现有容器..."
docker-compose down --timeout 30

# 拉取最新镜像
echo "📥 拉取最新镜像..."
docker-compose pull

# 构建并启动容器
echo "🔨 构建并启动容器..."
docker-compose --env-file .env up -d --build

# 等待服务启动
echo "⏳ 等待服务启动..."
sleep 120

# 检查服务状态
echo "🔍 检查服务状态..."
docker-compose ps

# 健康检查
echo "🏥 执行健康检查..."
max_attempts=60
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

# 检查Nginx
if curl -f http://localhost > /dev/null 2>&1; then
    echo "✅ Nginx服务正常"
else
    echo "❌ Nginx服务异常"
    docker-compose logs nginx
    exit 1
fi

# 设置定时任务（备份）
echo "📅 设置定时任务..."
crontab -l > /tmp/crontab.bak 2>/dev/null || true
echo "0 2 * * * $(pwd)/scripts/backup-prod.sh" >> /tmp/crontab.bak
crontab /tmp/crontab.bak
rm /tmp/crontab.bak

# 设置日志轮转
echo "📋 设置日志轮转..."
cat > /etc/logrotate.d/pubfree << EOF
$(pwd)/logs/production/*.log {
    daily
    rotate 30
    compress
    delaycompress
    missingok
    notifempty
    create 644 root root
}
EOF

echo "🎉 生产环境部署完成！"
echo ""
echo "🌐 网站地址: https://pubfree.cn"
echo "📊 监控地址: http://localhost:9090 (Prometheus)"
echo "📈 面板地址: http://localhost:3001 (Grafana)"
echo ""
echo "重要提醒："
echo "1. 请配置域名解析"
echo "2. 请配置SSL证书"
echo "3. 请设置防火墙规则"
echo "4. 请定期查看监控数据"
echo ""
echo "查看日志: docker-compose logs -f"
echo "停止服务: docker-compose down"