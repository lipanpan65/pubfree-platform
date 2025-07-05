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
