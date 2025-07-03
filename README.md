# pubfree-web


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


