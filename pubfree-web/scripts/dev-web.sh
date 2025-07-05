#!/bin/bash

WEB_CONTAINER="pubfree-web-dev"

case "$1" in
    "add")
        echo "📦 Adding package: $2"
        docker exec -it $WEB_CONTAINER npm install $2
        echo "✅ Package added! Hot reload will pick up changes."
        ;;
    "remove")
        echo "🗑️ Removing package: $2"
        docker exec -it $WEB_CONTAINER npm uninstall $2
        echo "✅ Package removed!"
        ;;
    "shell")
        echo "🐚 Opening shell in web container..."
        docker exec -it $WEB_CONTAINER /bin/bash
        ;;
    "logs")
        echo "📋 Web container logs:"
        docker logs -f $WEB_CONTAINER
        ;;
    "restart")
        echo "🔄 Restarting web container..."
        docker restart $WEB_CONTAINER
        ;;
    *)
        echo "🌐 PubFree Web Development Helper"
        echo "Usage: $0 {add|remove|shell|logs|restart} [package-name]"
        echo ""
        echo "Examples:"
        echo "  $0 add mobx mobx-react-lite"
        echo "  $0 remove lodash"
        echo "  $0 shell"
        echo "  $0 logs"
        echo "  $0 restart"
        ;;
esac
EOF