#!/bin/bash
echo "🚀 Starting PubFree Server in development mode..."
echo "📦 Module: pubfree-platform/pubfree-server"
echo "🌐 Environment: $APP_ENV"
echo "🗄️ Database: $DB_HOST:$DB_PORT/$DB_NAME"
echo "🔗 Redis: $REDIS_HOST:$REDIS_PORT"
echo "🏠 Server will start on port 8080"
echo "❤️ Health check: http://localhost:8080/health"
echo "=================================="
exec ./server "$@"
EOF