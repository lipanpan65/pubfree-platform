#!/bin/bash

# PubFree 平台 - 测试环境数据库备份脚本
# 作者: PubFree Team
# 创建时间: 2025-01-01

set -e  # 遇到错误立即退出

# 配置变量
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
BACKUP_DIR="$PROJECT_ROOT/backups"
ENV_FILE="$PROJECT_ROOT/environments/testing/.env"
LOG_FILE="$BACKUP_DIR/backup-test.log"

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 日志函数
log() {
    echo -e "${BLUE}[$(date '+%Y-%m-%d %H:%M:%S')]${NC} $1" | tee -a "$LOG_FILE"
}

error() {
    echo -e "${RED}[ERROR]${NC} $1" | tee -a "$LOG_FILE"
}

success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1" | tee -a "$LOG_FILE"
}

warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1" | tee -a "$LOG_FILE"
}

# 检查环境文件
check_env() {
    if [ ! -f "$ENV_FILE" ]; then
        error "环境配置文件不存在: $ENV_FILE"
        exit 1
    fi
    
    # 加载环境变量
    source "$ENV_FILE"
    
    # 检查必要的环境变量
    if [ -z "$MYSQL_USER" ] || [ -z "$MYSQL_PASSWORD" ] || [ -z "$MYSQL_DATABASE" ]; then
        error "缺少必要的数据库配置环境变量"
        exit 1
    fi
    
    success "环境配置检查通过"
}

# 检查 Docker 容器状态
check_container() {
    local container_name="pubfree-mysql-test"
    
    if ! docker ps | grep -q "$container_name"; then
        error "MySQL 容器未运行: $container_name"
        error "请先启动测试环境: make test"
        exit 1
    fi
    
    success "MySQL 容器状态正常"
}

# 检查依赖工具
check_dependencies() {
    # 检查 Docker
    if ! command -v docker &> /dev/null; then
        error "Docker 未安装或未在 PATH 中"
        exit 1
    fi
    
    # 检查 gzip
    if ! command -v gzip &> /dev/null; then
        error "gzip 未安装"
        exit 1
    fi
    
    success "依赖工具检查通过"
}

# 创建备份目录
create_backup_dir() {
    if [ ! -d "$BACKUP_DIR" ]; then
        mkdir -p "$BACKUP_DIR"
        log "创建备份目录: $BACKUP_DIR"
    fi
    
    if [ ! -d "$BACKUP_DIR/test" ]; then
        mkdir -p "$BACKUP_DIR/test"
        log "创建测试环境备份目录: $BACKUP_DIR/test"
    fi
}

# 执行数据库备份
backup_database() {
    local timestamp=$(date +%Y%m%d_%H%M%S)
    local backup_file="$BACKUP_DIR/test/pubfree_test_${timestamp}.sql"
    local compressed_file="${backup_file}.gz"
    
    log "开始备份数据库: $MYSQL_DATABASE"
    log "备份文件: $backup_file"
    
    # 使用 docker exec 连接到 MySQL 容器执行备份
    docker exec pubfree-mysql-test mysqldump \
        --user="$MYSQL_USER" \
        --password="$MYSQL_PASSWORD" \
        --single-transaction \
        --routines \
        --triggers \
        --events \
        --add-drop-database \
        --add-drop-table \
        --create-options \
        --disable-keys \
        --extended-insert \
        --quick \
        --lock-tables=false \
        --set-gtid-purged=OFF \
        --databases "$MYSQL_DATABASE" > "$backup_file"
    
    if [ $? -ne 0 ]; then
        error "数据库备份失败"
        exit 1
    fi
    
    # 压缩备份文件
    log "压缩备份文件..."
    gzip "$backup_file"
    
    if [ $? -ne 0 ]; then
        error "备份文件压缩失败"
        exit 1
    fi
    
    # 获取文件大小
    local file_size=$(du -h "$compressed_file" | cut -f1)
    success "数据库备份完成"
    success "备份文件: $compressed_file"
    success "文件大小: $file_size"
    
    # 返回备份文件路径供其他函数使用
    echo "$compressed_file"
}

# 验证备份文件
verify_backup() {
    local backup_file="$1"
    
    log "验证备份文件: $backup_file"
    
    # 检查文件是否存在
    if [ ! -f "$backup_file" ]; then
        error "备份文件不存在: $backup_file"
        return 1
    fi
    
    # 检查文件大小
    local file_size=$(stat -f%z "$backup_file" 2>/dev/null || stat -c%s "$backup_file" 2>/dev/null)
    if [ "$file_size" -lt 1024 ]; then
        error "备份文件过小，可能备份失败"
        return 1
    fi
    
    # 检查 gzip 文件完整性
    if ! gzip -t "$backup_file"; then
        error "备份文件损坏"
        return 1
    fi
    
    success "备份文件验证通过"
    return 0
}

# 清理旧备份
cleanup_old_backups() {
    local keep_days=${BACKUP_KEEP_DAYS:-7}  # 默认保留7天
    local backup_dir="$BACKUP_DIR/test"
    
    log "清理 $keep_days 天前的备份文件..."
    
    find "$backup_dir" -name "pubfree_test_*.sql.gz" -mtime +$keep_days -type f -delete
    
    local remaining_count=$(find "$backup_dir" -name "pubfree_test_*.sql.gz" -type f | wc -l)
    success "清理完成，当前保留 $remaining_count 个备份文件"
}

# 发送通知（可选）
send_notification() {
    local backup_file="$1"
    local file_size=$(du -h "$backup_file" | cut -f1)
    
    # 这里可以添加邮件通知、Slack 通知等
    # 示例：curl -X POST -H 'Content-type: application/json' \
    #       --data '{"text":"测试环境数据库备份完成\n文件: '"$backup_file"'\n大小: '"$file_size"'"}' \
    #       YOUR_SLACK_WEBHOOK_URL
    
    log "备份通知: 文件大小 $file_size"
}

# 显示帮助信息
show_help() {
    echo "PubFree 测试环境数据库备份脚本"
    echo ""
    echo "用法: $0 [选项]"
    echo ""
    echo "选项:"
    echo "  -h, --help     显示帮助信息"
    echo "  -v, --verify   只验证现有备份文件"
    echo "  -c, --cleanup  只清理旧备份文件"
    echo "  --no-cleanup   不清理旧备份文件"
    echo ""
    echo "环境变量:"
    echo "  BACKUP_KEEP_DAYS  备份保留天数（默认：7）"
    echo ""
    echo "示例:"
    echo "  $0                 # 执行完整备份"
    echo "  $0 --verify        # 验证现有备份"
    echo "  $0 --cleanup       # 清理旧备份"
    echo ""
}

# 主函数
main() {
    local verify_only=false
    local cleanup_only=false
    local skip_cleanup=false
    
    # 解析参数
    while [[ $# -gt 0 ]]; do
        case $1 in
            -h|--help)
                show_help
                exit 0
                ;;
            -v|--verify)
                verify_only=true
                shift
                ;;
            -c|--cleanup)
                cleanup_only=true
                shift
                ;;
            --no-cleanup)
                skip_cleanup=true
                shift
                ;;
            *)
                error "未知参数: $1"
                show_help
                exit 1
                ;;
        esac
    done
    
    # 初始化
    log "开始测试环境数据库备份..."
    create_backup_dir
    
    # 只清理旧备份
    if [ "$cleanup_only" = true ]; then
        cleanup_old_backups
        success "清理完成"
        exit 0
    fi
    
    # 只验证备份
    if [ "$verify_only" = true ]; then
        local latest_backup=$(find "$BACKUP_DIR/test" -name "pubfree_test_*.sql.gz" -type f | sort | tail -1)
        if [ -z "$latest_backup" ]; then
            error "没有找到备份文件"
            exit 1
        fi
        verify_backup "$latest_backup"
        success "验证完成"
        exit 0
    fi
    
    # 执行完整备份流程
    check_dependencies
    check_env
    check_container
    
    # 执行备份
    backup_file=$(backup_database)
    
    # 验证备份
    if verify_backup "$backup_file"; then
        success "备份验证通过"
        send_notification "$backup_file"
    else
        error "备份验证失败"
        exit 1
    fi
    
    # 清理旧备份
    if [ "$skip_cleanup" != true ]; then
        cleanup_old_backups
    fi
    
    success "测试环境数据库备份完成！"
    success "备份文件: $backup_file"
    
    # 显示备份统计
    local total_backups=$(find "$BACKUP_DIR/test" -name "pubfree_test_*.sql.gz" -type f | wc -l)
    local total_size=$(du -sh "$BACKUP_DIR/test" | cut -f1)
    log "备份统计: 共 $total_backups 个文件，总大小 $total_size"
}

# 捕获中断信号
trap 'error "备份被中断"; exit 1' INT TERM

# 执行主函数
main "$@"