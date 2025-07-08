#!/bin/bash
set -e

echo "🚀 Starting PubFree Server in development mode..."
echo "📦 Module: pubfree-platform/pubfree-server"
echo "🌐 Environment: $APP_ENV"
echo "🗄️ Database: $DB_HOST:$DB_PORT/$DB_NAME"
echo "🔗 Redis: $REDIS_HOST:$REDIS_PORT"
echo "🏠 Server will start on port 8080"
echo "❤️ Health check: http://localhost:8080/health"
echo "=================================="

# 跨平台调试信息
echo "🔍 Platform information:"
echo "Container OS: $(uname -s)"
echo "Container architecture: $(uname -m)"
echo "Platform environment: ${PLATFORM_ARCH:-not set}"
echo ""

echo "🔍 Binary information:"
# 检查 file 命令是否可用
if command -v file >/dev/null 2>&1; then
    echo "Binary file info:"
    file ./server 2>/dev/null || echo "Unable to get file info"
else
    echo "file command not available"
fi

echo "Binary permissions:"
ls -la ./server

echo "Current user: $(whoami)"
echo "Current directory: $(pwd)"
echo "=================================="

# 预启动检查
echo "🔍 Pre-start checks:"

# 检查二进制文件是否存在
if [ ! -f "./server" ]; then
    echo "❌ Server binary not found!"
    exit 1
fi

# 检查二进制文件是否可执行
if [ ! -x "./server" ]; then
    echo "❌ Server binary is not executable!"
    echo "Attempting to fix permissions..."
    chmod +x ./server
fi

# 检查架构兼容性
CONTAINER_ARCH=$(uname -m)
if command -v file >/dev/null 2>&1; then
    BINARY_INFO=$(file ./server 2>/dev/null || echo "unknown")
    echo "Container arch: $CONTAINER_ARCH"
    echo "Binary info: $BINARY_INFO"
    
    # 简单的架构匹配检查
    case "$CONTAINER_ARCH" in
        "x86_64"|"amd64")
            if echo "$BINARY_INFO" | grep -q "x86-64\|x86_64\|amd64"; then
                echo "✅ Architecture match: AMD64"
            else
                echo "⚠️ Possible architecture mismatch detected"
                echo "Binary info: $BINARY_INFO"
            fi
            ;;
        "aarch64"|"arm64")
            if echo "$BINARY_INFO" | grep -q "aarch64\|arm64"; then
                echo "✅ Architecture match: ARM64"
            else
                echo "⚠️ Possible architecture mismatch detected"
                echo "Binary info: $BINARY_INFO"
            fi
            ;;
        *)
            echo "ℹ️ Unknown architecture: $CONTAINER_ARCH"
            ;;
    esac
fi

echo "=================================="

# 启动服务器
echo "🚀 Starting server..."

# 添加启动超时检查
timeout 10s ./server --version 2>/dev/null || {
    EXIT_CODE=$?
    if [ $EXIT_CODE -eq 124 ]; then
        echo "⚠️ Server version check timed out (this might be normal)"
    else
        echo "❌ Server version check failed with exit code: $EXIT_CODE"
        echo "This might indicate an architecture mismatch or configuration error"
        echo ""
        echo "🔧 Troubleshooting suggestions:"
        echo "1. Check if binary was built for correct architecture"
        echo "2. Verify container platform settings"
        echo "3. Check server configuration files"
        exit 1
    fi
}

echo "✅ Server binary validation passed"
echo "🚀 Starting main server process..."

# 启动主进程
exec ./server "$@"