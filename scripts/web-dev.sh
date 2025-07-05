#!/bin/bash

WEB_CONTAINER="pubfree-web-dev"

case "$1" in
    "install")
        echo "📦 Installing packages: ${@:2}"
        docker exec -it $WEB_CONTAINER npm install ${@:2}
        echo "🔄 Restarting container for changes to take effect..."
        docker restart $WEB_CONTAINER
        echo "✅ Done! Check the logs: make logs ENV=dev"
        ;;
    "dev")
        echo "🔧 Installing dev packages: ${@:2}"
        docker exec -it $WEB_CONTAINER npm install --save-dev ${@:2}
        echo "🔄 Restarting container..."
        docker restart $WEB_CONTAINER
        echo "✅ Done!"
        ;;
    "remove")
        echo "🗑️ Removing packages: ${@:2}"
        docker exec -it $WEB_CONTAINER npm uninstall ${@:2}
        echo "🔄 Restarting container..."
        docker restart $WEB_CONTAINER
        echo "✅ Done!"
        ;;
    "shell")
        echo "🐚 Opening shell in container..."
        docker exec -it $WEB_CONTAINER /bin/bash
        ;;
    "logs")
        echo "📋 Showing container logs..."
        docker logs -f $WEB_CONTAINER
        ;;
    "status")
        echo "📊 Container status:"
        docker ps --filter "name=$WEB_CONTAINER" --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"
        ;;
    *)
        echo "🌐 PubFree Web Development Helper"
        echo "Usage: $0 {install|dev|remove|shell|logs|status} [packages...]"
        echo ""
        echo "Commands:"
        echo "  install <pkg...>  - Install packages"
        echo "  dev <pkg...>      - Install dev packages"
        echo "  remove <pkg...>   - Remove packages"
        echo "  shell            - Open bash shell"
        echo "  logs             - Show container logs"
        echo "  status           - Show container status"
        echo ""
        echo "Examples:"
        echo "  $0 install mobx mobx-react-lite"
        echo "  $0 dev @types/node"
        echo "  $0 remove lodash"
        echo "  $0 shell"
        ;;
esac
