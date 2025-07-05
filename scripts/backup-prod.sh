#!/bin/bash

# PubFree 平台 - 生产环境数据库备份脚本
# 作者: PubFree Team
# 创建时间: 2025-01-01

set -e  # 遇到错误立即退出

# 配置变量
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
BACKUP_DIR="$PROJECT_ROOT/backups"
ENV_FILE="$PROJECT_ROOT/environments/production/.env"
LOG_FILE="$BACKUP_DIR/backup-prod.log"

# 生产环境特殊配置
BACKUP_KEEP_DAYS=${BACKUP_KEEP_DAYS:-30}  # 生产环境保留30天
BACKUP_REMOTE_DIR=${BACKUP_REMOTE_DIR:-""}  # 远程备份目录
SLACK_WEBHOOK=${SLACK_WEBHOOK:-""}  # Slack 通知
EMAIL_RECIPIENTS=${EMAIL_RECIPIENTS:-""}  # 邮件通知

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
    local container_name="pubfree-mysql-prod"
    
    if ! docker ps | grep -q "$container_name"; then
        error "MySQL 容器未运行: $container_name"
        error "请先启动生产环境: make prod"
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
    
    # 检查 openssl（用于加密）
    if ! command -v openssl &> /dev/null; then
        warning "openssl 未安装，备份文件将不加密"
    fi
    
    success "依赖工具检查通过"
}

# 创建备份目录
create_backup_dir() {
    if [ ! -d "$BACKUP_DIR" ]; then
        mkdir -p "$BACKUP_DIR"
        log "创建备份目录: $BACKUP_DIR"
    fi
    
    if [ ! -d "$BACKUP_DIR/prod" ]; then
        mkdir -p "$BACKUP_DIR/prod"
        log "创建生产环境备份目录: $BACKUP_DIR/prod"
    fi
    
    # 设置目录权限
    chmod 700 "$BACKUP_DIR/prod"
}

# 获取数据库统计信息
get_database_stats() {
    local stats_file="$BACKUP_DIR/prod/db_stats_$(date +%Y%m%d_%H%M%S).txt"
    
    log "收集数据库统计信息..."
    
    cat > "$stats_file" << EOF
数据库统计信息 - $(date)
================================

数据库名称: $MYSQL_DATABASE
备份时间: $(date)

表统计:
EOF
    
    # 获取表统计信息
    docker exec pubfree-mysql-prod mysql \
        --user="$MYSQL_USER" \
        --password="$MYSQL_PASSWORD" \
        --database="$MYSQL_DATABASE" \
        --execute="
        SELECT 
            table_name as '表名',
            table_rows as '行数',
            ROUND(((data_length + index_length) / 1024 / 1024), 2) as '大小(MB)'
        FROM information_schema.tables 
        WHERE table_schema = '$MYSQL_DATABASE' 
        ORDER BY (data_length + index_length) DESC;
        " >> "$stats_file"
    
    echo "$stats_file"
}

# 执行数据库备份
backup_database() {
    local timestamp=$(date +%Y%m%d_%H%M%S)
    local backup_file="$BACKUP_DIR/prod/pubfree_prod_${timestamp}.sql"
    local compressed_file="${backup_file}.gz"
    local encrypted_file="${compressed_file}.enc"
    
    log "开始备份生产数据库: $MYSQL_DATABASE"
    log "备份文件: $backup_file"
    
    # 创建数据库统计文件
    local stats_file=$(get_database_stats)
    
    # 使用 docker exec 连接到 MySQL 容器执行备份
    docker exec pubfree-mysql-prod mysqldump \
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
        --hex-blob \
        --complete-insert \
        --master-data=2 \
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
    
    # 加密备份文件（如果设置了加密密码）
    if [ -n "$BACKUP_ENCRYPT_PASSWORD" ] && command -v openssl &> /dev/null; then
        log "加密备份文件..."
        openssl enc -aes-256-cbc -salt -in "$compressed_file" -out "$encrypted_file" -pass pass:"$BACKUP_ENCRYPT_PASSWORD"
        
        if [ $? -eq 0 ]; then
            rm "$compressed_file"
            compressed_file="$encrypted_file"
            success "备份文件加密完成"
        else
            warning "备份文件加密失败，保留未加密版本"
        fi
    fi
    
    # 获取文件大小
    local file_size=$(du -h "$compressed_file" | cut -f1)
    success "数据库备份完成"
    success "备份文件: $compressed_file"
    success "统计文件: $stats_file"
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
    
    # 如果是加密文件，验证加密完整性
    if [[ "$backup_file" == *.enc ]]; then
        if [ -n "$BACKUP_ENCRYPT_PASSWORD" ]; then
            # 尝试解密一小部分验证
            openssl enc -aes-256-cbc -d -in "$backup_file" -pass pass:"$BACKUP_ENCRYPT_PASSWORD" 2>/dev/null | head -c 1024 > /dev/null
            if [ $? -ne 0 ]; then
                error "加密备份文件验证失败"
                return 1
            fi
        else
            warning "无法验证加密文件：缺少解密密码"
        fi
    elif [[ "$backup_file" == *.gz ]]; then
        # 检查 gzip 文件完整性
        if ! gzip -t "$backup_file"; then
            error "压缩备份文件损坏"
            return 1
        fi
    fi
    
    success "备份文件验证通过"
    return 0
}

# 上传到远程存储
upload_to_remote() {
    local backup_file="$1"
    
    if [ -z "$BACKUP_REMOTE_DIR" ]; then
        log "未配置远程备份目录，跳过远程上传"
        return 0
    fi
    
    log "上传备份文件到远程存储..."
    
    # 这里可以根据需要实现不同的远程存储方案
    # 例如：rsync, scp, aws s3, Google Cloud Storage 等
    
    # 示例：使用 rsync 上传
    if command -v rsync &> /dev/null; then
        rsync -avz --progress "$backup_file" "$BACKUP_REMOTE_DIR/"
        if [ $? -eq 0 ]; then
            success "备份文件上传完成"
        else
            error "备份文件上传失败"
            return 1
        fi
    else
        warning "rsync 未安装，无法上传到远程存储"
    fi
    
    return 0
}

# 清理旧备份
cleanup_old_backups() {
    local keep_days=${BACKUP_KEEP_DAYS:-30}
    local backup_dir="$BACKUP_DIR/prod"
    
    log "清理 $keep_days 天前的备份文件..."
    
    # 清理本地备份
    find "$backup_dir" -name "pubfree_prod_*.sql.gz*" -mtime +$keep_days -type f -delete
    find "$backup_dir" -name "db_stats_*.txt" -mtime +$keep_days -type f -delete
    
    local remaining_count=$(find "$backup_dir" -name "pubfree_prod_*.sql.gz*" -type f | wc -l)
    success "清理完成，当前保留 $remaining_count 个备份文件"
}

# 发送通知
send_notification() {
    local backup_file="$1"
    local file_size=$(du -h "$backup_file" | cut -f1)
    local message="生产环境数据库备份完成\\n文件: $(basename "$backup_file")\\n大小: $file_size\\n时间: $(date)"
    
    # Slack 通知
    if [ -n "$SLACK_WEBHOOK" ]; then
        curl -X POST -H 'Content-type: application/json' \
            --data "{\"text\":\"$message\"}" \
            "$SLACK_WEBHOOK" 2>/dev/null
        
        if [ $? -eq 0 ]; then
            success "Slack 通知发送成功"
        else
            warning "Slack 通知发送失败"
        fi
    fi
    
    # 邮件通知
    if [ -n "$EMAIL_RECIPIENTS" ] && command -v mail &> /dev/null; then
        echo -e "$message" | mail -s "PubFree 生产环境数据库备份完成" "$EMAIL_RECIPIENTS"
        
        if [ $? -eq 0 ]; then
            success "邮件通知发送成功"
        else
            warning "邮件通知发送失败"
        fi
    fi
}

# 检查磁盘空间
check_disk_space() {
    local backup_dir="$BACKUP_DIR/prod"
    local available_space=$(df "$backup_dir" | tail -1 | awk '{print $4}')
    local required_space=1048576  # 1GB in KB
    
    if [ "$available_space" -lt "$required_space" ]; then
        error "磁盘空间不足，可用空间: $(echo "$available_space" | awk '{print $1/1024/1024 " GB"}')"
        exit 1
    fi
    
    success "磁盘空间检查通过"
}

# 显示帮助信息
show_help() {
    echo "PubFree 生产环境数据库备份脚本"
    echo ""
    echo "用法: $0 [选项]"
    echo ""
    echo "选项:"
    echo "  -h, --help        显示帮助信息"
    echo "  -v, --verify      只验证现有备份文件"
    echo "  -c, --cleanup     只清理旧备份文件"
    echo "  --no-cleanup      不清理旧备份文件"
    echo "  --no-remote       不上传到远程存储"
    echo "  --no-notify       不发送通知"
    echo ""
    echo "环境变量:"
    echo "  BACKUP_KEEP_DAYS        备份保留天数（默认：30）"
    echo "  BACKUP_REMOTE_DIR       远程备份目录"
    echo "  BACKUP_ENCRYPT_PASSWORD 备份加密密码"
    echo "  SLACK_WEBHOOK           Slack 通知 webhook"
    echo "  EMAIL_RECIPIENTS        邮件通知收件人"
    echo ""
    echo "示例:"
    echo "  $0                      # 执行完整备份"
    echo "  $0 --verify             # 验证现有备份"
    echo "  $0 --cleanup            # 清理旧备份"
    echo "  $0 --no-remote          # 不上传到远程"
    echo ""
}

# 主函数
main() {
    local verify_only=false
    local cleanup_only=false
    local skip_cleanup=false
    local skip_remote=false
    local skip_notify=false
    
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
            --no-remote)
                skip_remote=true
                shift
                ;;
            --no-notify)
                skip_notify=true
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
    log "开始生产环境数据库备份..."
    create_backup_dir
    check_disk_space
    
    # 只清理旧备份
    if [ "$cleanup_only" = true ]; then
        cleanup_old_backups
        success "清理完成"
        exit 0
    fi
    
    # 只验证备份
    if [ "$verify_only" = true ]; then
        local latest_backup=$(find "$BACKUP_DIR/prod" -name "pubfree_prod_*.sql.gz*" -type f | sort | tail -1)
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
    else
        error "备份验证失败"
        exit 1
    fi
    
    # 上传到远程存储
    if [ "$skip_remote" != true ]; then
        upload_to_remote "$backup_file"
    fi
    
    # 发送通知
    if [ "$skip_notify" != true ]; then
        send_notification "$backup_file"
    fi
    
    # 清理旧备份
    if [ "$skip_cleanup" != true ]; then
        cleanup_old_backups
    fi
    
    success "生产环境数据库备份完成！"
    success "备份文件: $backup_file"
    
    # 显示备份统计
    local total_backups=$(find "$BACKUP_DIR/prod" -name "pubfree_prod_*.sql.gz*" -type f | wc -l)
    local total_size=$(du -sh "$BACKUP_DIR/prod" | cut -f1)
    log "备份统计: 共 $total_backups 个文件，总大小 $total_size"
}

# 捕获中断信号
trap 'error "备份被中断"; exit 1' INT TERM

# 执行主函数
main "$@"