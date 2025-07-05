package main

import (
	"context"
	"fmt"
	"net/http"
	"os"
	"os/signal"
	"syscall"
	"time"

	"pubfree-platform/pubfree-server/internal/config"
	"pubfree-platform/pubfree-server/internal/model"
	"pubfree-platform/pubfree-server/internal/router"
	"pubfree-platform/pubfree-server/pkg/logger"

	"github.com/gin-gonic/gin"
	"gorm.io/gorm"
)

func main() {
	// 加载配置
	cfg, err := config.LoadConfig()
	if err != nil {
		fmt.Printf("加载配置失败: %v\n", err)
		os.Exit(1)
	}

	// 初始化日志
	logger.Init(cfg.Logger)
	logger.Logger.Info("配置加载成功")

	// 设置Gin模式
	gin.SetMode(cfg.Server.Mode)

	// 初始化数据库
	db, err := config.InitDB(cfg.Database)
	if err != nil {
		logger.Logger.Fatalf("数据库初始化失败: %v", err)
	}

	// 自动迁移数据库表
	if err := autoMigrate(db); err != nil {
		logger.Logger.Fatalf("数据库迁移失败: %v", err)
	}

	// 初始化路由
	r := router.SetupRouter(db)

	// 添加中间件
	r.Use(logger.GinLogger())
	r.Use(logger.GinRecovery())
	r.Use(corsMiddleware())

	// 添加健康检查接口
	r.GET("/health", func(c *gin.Context) {
		c.JSON(http.StatusOK, gin.H{
			"status":  "ok",
			"time":    time.Now().Format("2006-01-02 15:04:05"),
			"app":     cfg.App.Name,
			"version": cfg.App.Version,
		})
	})

	// 创建HTTP服务器
	srv := &http.Server{
		Addr:           cfg.Server.Port,
		Handler:        r,
		ReadTimeout:    cfg.Server.ReadTimeout,
		WriteTimeout:   cfg.Server.WriteTimeout,
		MaxHeaderBytes: cfg.Server.MaxHeaderMB << 20,
	}

	// 在goroutine中启动服务器
	go func() {
		logger.Logger.Infof("服务器启动在端口: %s", cfg.Server.Port)
		if err := srv.ListenAndServe(); err != nil && err != http.ErrServerClosed {
			logger.Logger.Fatalf("服务器启动失败: %v", err)
		}
	}()

	// 等待中断信号来优雅地关闭服务器
	quit := make(chan os.Signal, 1)
	signal.Notify(quit, syscall.SIGINT, syscall.SIGTERM)
	<-quit
	logger.Logger.Info("正在关闭服务器...")

	// 设置5秒的超时时间用于优雅关闭
	ctx, cancel := context.WithTimeout(context.Background(), 5*time.Second)
	defer cancel()

	if err := srv.Shutdown(ctx); err != nil {
		logger.Logger.Errorf("服务器强制关闭: %v", err)
	} else {
		logger.Logger.Info("服务器已优雅关闭")
	}
}

// autoMigrate 自动迁移数据库表
func autoMigrate(db *gorm.DB) error {
	logger.Logger.Info("开始数据库迁移...")

	err := db.AutoMigrate(
		&model.User{},
		&model.Group{},
		&model.GroupMember{},
		&model.Project{},
		&model.ProjectMember{},
		&model.ProjectEnv{},
		&model.ProjectDomain{},
		&model.ProjectEnvDeploy{},
	)

	if err != nil {
		return err
	}

	logger.Logger.Info("数据库迁移完成")
	return nil
}

// corsMiddleware CORS中间件
func corsMiddleware() gin.HandlerFunc {
	return func(c *gin.Context) {
		method := c.Request.Method
		origin := c.Request.Header.Get("Origin")

		if origin != "" {
			c.Header("Access-Control-Allow-Origin", origin)
			c.Header("Access-Control-Allow-Methods", "POST, GET, OPTIONS, PUT, DELETE, UPDATE")
			c.Header("Access-Control-Allow-Headers", "Origin, X-Requested-With, Content-Type, Accept, Authorization, Token")
			c.Header("Access-Control-Expose-Headers", "Content-Length, Access-Control-Allow-Origin, Access-Control-Allow-Headers, Cache-Control, Content-Language, Content-Type")
			c.Header("Access-Control-Allow-Credentials", "true")
		}

		if method == "OPTIONS" {
			c.AbortWithStatus(http.StatusNoContent)
			return
		}

		c.Next()
	}
}
