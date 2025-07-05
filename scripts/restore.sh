#!/bin/bash

# PubFree 平台 - 数据库恢复脚本
# 作者: PubFree Team
# 创建时间: 2025-01-01

set -e  # 遇到错误立即退出

# 配置变量
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
BACKUP_DIR="$PROJECT_ROOT/backups"
LOG_FILE="$BACKUP_DIR/restore.log"

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

# 显示帮助信息
show_help() {
    echo "PubFree 数据库恢复脚本"
    echo ""
    echo "用法: $0 [选项] <环境> [备份文件]"
    echo ""
    echo "环境:"
    echo "  dev     开发环境"
    echo "  test    测试环境"
    echo "  prod    生产环境"
    echo ""
    echo "选项:"
    echo "  -h, --help       显示帮助信息"
    echo "  -l, --list       列出可用的备份文件"
    echo "  -f, --force      强制恢复，不询问确认"
    echo "  --latest         使用最新的备份文件"
    echo "  --decrypt PASS   解密密码（用于加密备份）"
    echo ""
    echo "示例:"
    echo "  $0 dev                                    # 交互式选择开发环境备份文件"
    echo "  $0 test --latest                          # 使用最新的测试环境备份"
    echo "  $0 prod backup_file.sql.gz               # 恢复指定的备份文件"
    echo "  $0 -l test                               # 列出测试环境的备份文件"
    echo "  $0 prod --decrypt mypassword backup.enc  # 恢复加密备份"
    echo ""
}

# 列出备份文件
list_backups() {
    local env="$1"
    local backup_env_dir="$BACKUP_DIR/$env"
    
    if [ ! -d "$backup_env_dir" ]; then
        error "备份目录不存在: $backup_env_dir"
        exit 1
    fi
    
    echo "可用的 $env 环境备份文件:"
    echo "================================"
    
    local files=$(find "$backup_env_dir" -name "pubfree_${env}_*.sql.gz*" -type f | sort -r)
    
    if [ -z "$files" ]; then
        echo "没有找到备份文件"
        exit 1
    fi
    
    local count=1
    for file in $files; do
        local filename=$(basename "$file")
        local filesize=$(du -h "$file" | cut -f1)
        local filetime=$(stat -f%Sm -t%Y-%m-%d\ %H:%M:%S "$file" 2>/dev/null || stat -c%y "$file" 2>/dev/null | cut -d'.' -f1)
        
        echo "$count. $filename"
        echo "   大小: $filesize"
        echo "   时间: $filetime"
        echo ""
        
        ((count++))
    done
}

# 选择备份文件
select_backup() {
    local env="$1"
    local backup_env_dir="$BACKUP_DIR/$env"
    
    local files=$(find "$backup_env_dir" -name "pubfree_${env}_*.sql.gz*" -type f | sort -r)
    
    if [ -z "$files" ]; then
        error "没有找到 $env 环境的备份文件"
        exit 1
    fi
    
    echo "请选择要恢复的备份文件:"
    echo "================================"
    
    local count=1
    local file_array=()
    
    for file in $files; do
        local filename=$(basename "$file")
        local filesize=$(du -h "$file" | cut -f1)
        local filetime=$(stat -f%Sm -t%Y-%m-%d\ %H:%M:%S "$file" 2>/dev/null || stat -c%y "$file" 2>/dev/null | cut -d'.' -f1)
        
        echo "$count. $filename ($filesize, $filetime)"
        file_array+=("$file")
        ((count++))
    done
    
    echo ""
    read -p "请输入序号 (1-$((count-1))): " selection
    
    if ! [[ "$selection" =~ ^[0-9]+$ ]] || [ "$selection" -lt 1 ] || [ "$selection" -gt $((count-1)) ]; then
        error "无效的选择"
        exit 1
    fi
    
    echo "${file_array[$((selection-1))]}"
}

# 获取最新备份文件
get_latest_backup() {
    local env="$1"
    local backup_env_dir="$BACKUP_DIR/$env"
    
    local latest_file=$(find "$backup_env_dir" -name "pubfree_${env}_*.sql.gz*" -type f | sort -r | head -1)
    
    if [ -z "$latest_file" ]; then
        error "没有找到 $env 环境的备份文件"
        exit 1
    fi
    
    echo "$latest_file"
}

# 验证环境
validate_env() {
    local env="$1"
    
    case "$env" in
        dev|test|prod)
            return 0
            ;;
        *)
            error "无效的环境: $env"
            error "支持的环境: dev, test, prod"
            exit 1
            ;;
    esac
}

# 检查容器状态
check_container() {
    local env="$1"
    local container_name="pubfree-mysql-$env"
    
    if ! docker ps | grep -q "$container_name"; then
        error "MySQL 容器未运行: $container_name"
        error "请先启动 $env 环境: make $env"
        exit 1
    fi
    
    success "MySQL 容器状态正常"
}

# 加载环境配置
load_env_config() {
    local env="$1"
    local env_file="$PROJECT_ROOT/environments/$env/.env"
    
    if [ "$env" = "dev" ]; then
        env_file="$PROJECT_ROOT/environments/development/.env"
    elif [ "$env" = "test" ]; then
        env_file="$PROJECT_ROOT/environments/testing/.env"
    elif [ "$env" = "prod" ]; then
        env_file="$PROJECT_ROOT/environments/production/.env"
    fi
    
    if [ ! -f "$env_file" ]; then
        error "环境配置文件不存在: $env_file"
        exit 1
    fi
    
    source "$env_file"
    
    if [ -z "$MYSQL_USER" ] || [ -z "$MYSQL_PASSWORD" ] || [ -z "$MYSQL_DATABASE" ]; then
        error "缺少必要的数据库配置环境变量"
        exit 1
    fi
    
    success "环境配置加载成功"
}

# 解压备份文件
decompress_backup() {
    local backup_file="$1"
    local decrypt_password="$2"
    local temp_dir=$(mktemp -d)
    
    log "解压备份文件: $backup_file"
    
    if [[ "$backup_file" == *.enc ]]; then
        # 解密文件
        if [ -z "$decrypt_password" ]; then
            error "加密备份文件需要提供解密密码"
            exit 1
        fi
        
        local decrypted_file="$temp_dir/decrypted.sql.gz"
        openssl enc -aes-256-cbc -d -in "$backup_file" -out "$decrypted_file" -pass pass:"$decrypt_password"
        
        if [ $? -ne 0 ]; then
            error "解密失败"
            rm -rf "$temp_dir"
            exit 1
        fi
        
        backup_file="$decrypted_file"
    fi
    
    if [[ "$backup_file" == *.gz ]]; then
        # 解压文件
        local decompressed_file="$temp_dir/backup.sql"
        gunzip -c "$backup_file" > "$decompressed_file"
        
        if [ $? -ne 0 ]; then
            error "解压失败"
            rm -rf "$temp_dir"
            exit 1
        fi
        
        echo "$decompressed_file"
    else
        echo "$backup_file"
    fi
}

# 创建数据库备份（恢复前）
create_pre_restore_backup() {
    local env="$1"
    local timestamp=$(date +%Y%m%d_%H%M%S)
    local backup_file="$BACKUP_DIR/$env/pre_restore_backup_${timestamp}.sql.gz"
    
    log "创建恢复前备份: $backup_file"
    
    docker exec "pubfree-mysql-$env" mysqldump \
        --user="$MYSQL_USER" \
        --password="$MYSQL_PASSWORD" \
        --single-transaction \
        --routines \
        --triggers \
        --events \
        --databases "$MYSQL_DATABASE" | gzip > "$backup_file"
    
    if [ $? -eq 0 ]; then
        success "恢复前备份创建成功: $backup_file"
    else
        warning "恢复前备份创建失败"
    fi
}

# 恢复数据库
restore_database() {
    local env="$1"
    local backup_file="$2"
    local container_name="pubfree-mysql-$env"
    
    log "开始恢复数据库..."
    log "环境: $env"
    log "备份文件: $backup_file"
    log "目标数据库: $MYSQL_DATABASE"
    
    # 恢复数据库
    docker exec -i "$container_name" mysql \
        --user="$MYSQL_USER" \
        --password="$MYSQL_PASSWORD" < "$backup_file"
    
    if [ $? -eq 0 ]; then
        success "数据库恢复完成"
    else
        error "数据库恢复失败"
        exit 1
    fi
}

# 验证恢复结果
verify_restore() {
    local env="$1"
    local container_name="pubfree-mysql-$env"
    
    log "验证恢复结果..."
    
    # 检查表是否存在
    local table_count=$(docker exec "$container_name" mysql \
        --user="$MYSQL_USER" \
        --password="$MYSQL_PASSWORD" \
        --database="$MYSQL_DATABASE" \
        --execute="SELECT COUNT(*) FROM information_schema.tables WHERE table_schema = '$MYSQL_DATABASE';" \
        --silent --skip-column-names)
    
    if [ "$table_count" -gt 0 ]; then
        success "恢复验证通过，共 $table_count 个表"
    else
        error "恢复验证失败，未找到数据表"
        exit 1
    fi
}

# 清理临时文件
cleanup_temp_files() {
    local temp_dir="$1"
    
    if [ -n "$temp_dir" ] && [ -d "$temp_dir" ]; then
        rm -rf "$temp_dir"
        log "清理临时文件完成"
    fi
}

# 主函数
main() {
    local env=""
    local backup_file=""
    local list_only=false
    local force=false
    local use_latest=false
    local decrypt_password=""
    
    # 解析参数
    while [[ $# -gt 0 ]]; do
        case $1 in
            -h|--help)
                show_help
                exit 0
                ;;
            -l|--list)
                list_only=true
                shift
                ;;
            -f|--force)
                force=true
                shift
                ;;
            --latest)
                use_latest=true
                shift
                ;;
            --decrypt)
                decrypt_password="$2"
                shift 2
                ;;
            dev|test|prod)
                env="$1"
                shift
                ;;
            *)
                if [ -z "$backup_file" ]; then
                    backup_file="$1"
                else
                    error "未知参数: $1"
                    show_help
                    exit 1
                fi
                shift
                ;;
        esac
    done
    
    # 验证环境参数
    if [ -z "$env" ]; then
        error "请指定环境参数"
        show_help
        exit 1
    fi
    
    validate_env "$env"
    
    # 只列出备份文件
    if [ "$list_only" = true ]; then
        list_backups "$env"
        exit 0
    fi
    
    # 确定备份文件
    if [ "$use_latest" = true ]; then
        backup_file=$(get_latest_backup "$env")
    elif [ -z "$backup_file" ]; then
        backup_file=$(select_backup "$env")
    else
        # 如果是相对路径，转换为绝对路径
        if [[ "$backup_file" != /* ]]; then
            backup_file="$BACKUP_DIR/$env/$backup_file"
        fi
        
        if [ ! -f "$backup_file" ]; then
            error "备份文件不存在: $backup_file"
            exit 1
        fi
    fi
    
    # 确认恢复操作
    if [ "$force" != true ]; then
        echo ""
        warning "⚠️  数据库恢复操作将覆盖现有数据！"
        echo "环境: $env"
        echo "备份文件: $(basename "$backup_file")"
        echo "目标数据库: $MYSQL_DATABASE"
        echo ""
        read -p "确认执行恢复操作? (y/N): " confirm
        
        if [ "$confirm" != "y" ] && [ "$confirm" != "Y" ]; then
            log "恢复操作已取消"
            exit 0
        fi
    fi
    
    # 开始恢复流程
    log "开始数据库恢复流程..."
    
    # 加载环境配置
    load_env_config "$env"
    
    # 检查容器状态
    check_container "$env"
    
    # 创建恢复前备份
    create_pre_restore_backup "$env"
    
    # 解压备份文件
    local decompressed_file=$(decompress_backup "$backup_file" "$decrypt_password")
    
    # 恢复数据库
    restore_database "$env" "$decompressed_file"
    
    # 验证恢复结果
    verify_restore "$env"
    
    # 清理临时文件
    cleanup_temp_files "$(dirname "$decompressed_file")"
    
    success "数据库恢复完成！"
    success "环境: $env"
    success "备份文件: $(basename "$backup_file")"
    
    # 提示重启服务
    log "建议重启应用服务以确保数据一致性:"
    log "make restart ENV=$env"
}

# 捕获中断信号
trap 'error "恢复被中断"; exit 1' INT TERM

# 执行主函数
main "$@"