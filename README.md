# pubfree-web


<<<<<<< HEAD
```
nvm install v20.19.0
nvm alias pubfree v20.19.0
nvm use pubfree

npm create vite@latest pubfree-web -- --template react-ts
cd pubfree-web
npm install
npm install antd @ant-design/icons
npm install -D @types/node
cd ..

```

创建后端
```
mkdir pubfree-server
cd pubfree-server
go mod init pubfree-platform/pubfree-server
go get github.com/gin-gonic/gin
go get github.com/gin-contrib/cors
cd ..

```

创建其他目录

mkdir -p {docs,scripts,.github/workflows}


=======





```
# 在 pubfree-platform 目录下
mkdir pubfree-server
cd pubfree-server

# 初始化 Go 模块
go mod init pubfree-platform/pubfree-server

# 安装核心依赖
go get github.com/gin-gonic/gin
go get github.com/gin-contrib/cors
go get gorm.io/gorm
go get gorm.io/driver/mysql
go get github.com/golang-jwt/jwt/v4
go get github.com/spf13/viper
go get github.com/google/uuid


# 创建目录结构
mkdir -p {cmd,internal/{handler,service,repository,model,middleware,config},pkg/{utils,response},docs,scripts}

# 创建配置文件目录
mkdir -p configs

```





```
# 安装 asdf (如果还没安装)
brew install asdf

# 安装 Go 插件
asdf plugin add golang

# 安装 Go 1.24.3
asdf install golang 1.24.3
asdf global golang 1.24.3

# 验证
go version

```




# 初始化项目
make init

# 启动开发环境
make dev

# 启动测试环境
make test

# 启动生产环境（需要确认）
make prod

# 查看日志
make logs ENV=dev

# 备份数据
make backup ENV=prod
>>>>>>> pubfree-server





# 测试环境备份
make backup ENV=test

# 生产环境备份
make backup ENV=prod

# 带参数的备份
./scripts/backup-test.sh --no-cleanup
./scripts/backup-prod.sh --no-remote --no-notify




# 列出可用备份
./scripts/restore.sh -l test

# 交互式恢复
./scripts/restore.sh dev

# 使用最新备份
./scripts/restore.sh test --latest

# 恢复指定文件
./scripts/restore.sh prod backup_file.sql.gz --force




# 开发环境
cd pubfree-web
docker build -f Dockerfile.dev -t pubfree-web:dev .

# 生产环境
docker build -f Dockerfile.prod -t pubfree-web:prod .

# 测试运行
docker run -p 3000:3000 pubfree-web:dev



# 本地开发（使用 localhost:8080）
npm run dev

# Docker 开发（使用环境变量）
VITE_API_TARGET=http://pubfree-server:8080 npm run dev

# 或者使用 Docker Compose
make dev



# 构建开发环境
cd pubfree-web
docker build -f Dockerfile.dev -t pubfree-web:dev .

# 构建生产环境
docker build -f Dockerfile.prod -t pubfree-web:prod .

# 运行开发环境
docker run -p 3000:3000 -e VITE_API_TARGET=http://pubfree-server:8080 pubfree-web:dev

# 运行生产环境
docker run -p 80:80 pubfree-web:prod



# 验证 Node.js 版本
docker run --rm pubfree-web:dev node --version
# 输出: v20.19.0

# 验证 npm 版本
docker run --rm pubfree-web:dev npm --version
# 输出: 10.9.0（Node.js 20.19.0 自带的 npm 版本）

# 检查构建大小
docker images | grep pubfree-web




pubfree-web:
  build: 
    context: ../../pubfree-web
    dockerfile: Dockerfile.dev
  container_name: pubfree-web-dev
  ports:
    - "${WEB_PORT}:3000"
  environment:
    - NODE_ENV=development
    - VITE_API_TARGET=http://pubfree-server:8080
    - VITE_SERVER_URL=http://pubfree-server:8080
    - VITE_ENV=development
  depends_on:
    - pubfree-server
  volumes:
    - ../../pubfree-web:/app
    - /app/node_modules
  restart: unless-stopped
  networks:
    - pubfree-dev-network



# 安装包（推荐方式）
make web-add PKG="mobx mobx-react-lite"

# 或者直接使用脚本
./scripts/dev-web.sh add mobx mobx-react-lite

# 移除包
make web-remove PKG="mobx"

# 进入容器调试
make web-shell

# 查看日志
make web-logs



# 方式1：使用 Make 命令
make web-install PKGS="mobx mobx-react-lite"
make web-dev PKGS="@types/mobx"

# 方式2：直接使用脚本
./scripts/web-dev.sh install mobx mobx-react-lite
./scripts/web-dev.sh dev @types/mobx

# 方式3：手动操作
docker exec -it pubfree-web-dev npm install mobx mobx-react-lite
docker restart pubfree-web-dev