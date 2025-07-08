package config

import (
	"fmt"
	"os"
	"strings"
	"time"

	"github.com/spf13/viper"
)

// Config 全局配置结构
type Config struct {
	Server   ServerConfig   `mapstructure:"server"`
	Database DatabaseConfig `mapstructure:"database"`
	Redis    RedisConfig    `mapstructure:"redis"`
	JWT      JWTConfig      `mapstructure:"jwt"`
	Logger   LoggerConfig   `mapstructure:"logger"`
	App      AppConfig      `mapstructure:"app"`
}

// ServerConfig 服务器配置
type ServerConfig struct {
	Name         string        `mapstructure:"name"`
	Mode         string        `mapstructure:"mode"`
	Port         string        `mapstructure:"port"`
	ReadTimeout  time.Duration `mapstructure:"read_timeout"`
	WriteTimeout time.Duration `mapstructure:"write_timeout"`
	MaxHeaderMB  int           `mapstructure:"max_header_mb"`
}

// DatabaseConfig 数据库配置
type DatabaseConfig struct {
	Driver          string        `mapstructure:"driver"`
	Host            string        `mapstructure:"host"`
	Port            int           `mapstructure:"port"`
	Username        string        `mapstructure:"username"`
	Password        string        `mapstructure:"password"`
	DBName          string        `mapstructure:"dbname"`
	Charset         string        `mapstructure:"charset"`
	ParseTime       bool          `mapstructure:"parse_time"`
	Loc             string        `mapstructure:"loc"`
	MaxIdleConns    int           `mapstructure:"max_idle_conns"`
	MaxOpenConns    int           `mapstructure:"max_open_conns"`
	ConnMaxLifetime time.Duration `mapstructure:"conn_max_lifetime"`
	LogMode         bool          `mapstructure:"log_mode"`
}

// RedisConfig Redis配置
type RedisConfig struct {
	Host     string `mapstructure:"host"`
	Port     int    `mapstructure:"port"`
	Password string `mapstructure:"password"`
	DB       int    `mapstructure:"db"`
	PoolSize int    `mapstructure:"pool_size"`
}

// JWTConfig JWT配置
type JWTConfig struct {
	Secret    string        `mapstructure:"secret"`
	ExpiresAt time.Duration `mapstructure:"expires_at"` // ✅ time.Duration 类型
	Issuer    string        `mapstructure:"issuer"`
}

// LoggerConfig 日志配置
type LoggerConfig struct {
	Level      string `mapstructure:"level"`
	Format     string `mapstructure:"format"`
	Output     string `mapstructure:"output"`
	Filename   string `mapstructure:"filename"`
	MaxSize    int    `mapstructure:"max_size"`
	MaxAge     int    `mapstructure:"max_age"`
	MaxBackups int    `mapstructure:"max_backups"`
	Compress   bool   `mapstructure:"compress"`
}

// AppConfig 应用配置
type AppConfig struct {
	Name        string `mapstructure:"name"`
	Version     string `mapstructure:"version"`
	Description string `mapstructure:"description"`
	Debug       bool   `mapstructure:"debug"`
	Timezone    string `mapstructure:"timezone"`
}

// 全局配置实例
var GlobalConfig *Config

// LoadConfig 加载配置文件
func LoadConfig() (*Config, error) {
	// 1. 首先获取环境变量，确定使用哪个配置文件
	env := os.Getenv("APP_ENV")
	if env == "" {
		env = "dev" // 默认使用开发环境
	}

	// 2. 设置配置文件路径
	viper.AddConfigPath("configs")
	viper.AddConfigPath(".")
	viper.SetConfigType("yaml")

	// 3. 根据环境加载对应的配置文件
	configFile := fmt.Sprintf("config.%s", env)
	viper.SetConfigName(configFile)

	// 4. 配置环境变量
	viper.AutomaticEnv()
	viper.SetEnvKeyReplacer(strings.NewReplacer(".", "_"))

	// 5. 设置环境变量映射
	setupEnvBindings()

	// 6. 读取配置文件
	if err := viper.ReadInConfig(); err != nil {
		fmt.Printf("无法读取环境配置文件 %s.yaml，尝试使用默认配置文件\n", configFile)

		// 如果环境特定配置文件不存在，尝试读取默认配置
		viper.SetConfigName("config")
		if err := viper.ReadInConfig(); err != nil {
			return nil, fmt.Errorf("读取配置文件失败: %w", err)
		}
	}

	// 7. 解析配置
	var config Config
	if err := viper.Unmarshal(&config); err != nil {
		return nil, fmt.Errorf("解析配置文件失败: %w", err)
	}

	// 8. 应用环境变量覆盖
	applyEnvOverrides(&config)

	// 9. 验证配置
	if err := validateConfig(&config); err != nil {
		return nil, fmt.Errorf("配置验证失败: %w", err)
	}

	GlobalConfig = &config
	fmt.Printf("成功加载配置文件: %s.yaml (环境: %s)\n", configFile, env)
	return &config, nil
}

// setupEnvBindings 设置环境变量绑定
func setupEnvBindings() {
	// 数据库相关
	viper.BindEnv("database.host", "DB_HOST")
	viper.BindEnv("database.port", "DB_PORT")
	viper.BindEnv("database.username", "DB_USER")
	viper.BindEnv("database.password", "DB_PASSWORD")
	viper.BindEnv("database.dbname", "DB_NAME")

	// Redis相关
	viper.BindEnv("redis.host", "REDIS_HOST")
	viper.BindEnv("redis.port", "REDIS_PORT")
	viper.BindEnv("redis.password", "REDIS_PASSWORD")

	// JWT相关
	viper.BindEnv("jwt.secret", "JWT_SECRET")
	viper.BindEnv("jwt.expires_at", "JWT_EXPIRE_TIME")

	// 服务器相关
	viper.BindEnv("server.mode", "GIN_MODE")
	viper.BindEnv("server.port", "SERVER_PORT")

	// 日志相关
	viper.BindEnv("logger.level", "LOG_LEVEL")
}

// applyEnvOverrides 应用环境变量覆盖
func applyEnvOverrides(config *Config) {
	// 数据库配置覆盖
	if host := os.Getenv("DB_HOST"); host != "" {
		config.Database.Host = host
	}
	if port := viper.GetInt("DB_PORT"); port != 0 {
		config.Database.Port = port
	}
	if user := os.Getenv("DB_USER"); user != "" {
		config.Database.Username = user
	}
	if password := os.Getenv("DB_PASSWORD"); password != "" {
		config.Database.Password = password
	}
	if dbname := os.Getenv("DB_NAME"); dbname != "" {
		config.Database.DBName = dbname
	}

	// Redis配置覆盖
	if host := os.Getenv("REDIS_HOST"); host != "" {
		config.Redis.Host = host
	}
	if port := viper.GetInt("REDIS_PORT"); port != 0 {
		config.Redis.Port = port
	}
	if password := os.Getenv("REDIS_PASSWORD"); password != "" {
		config.Redis.Password = password
	}

	// JWT配置覆盖
	if secret := os.Getenv("JWT_SECRET"); secret != "" {
		config.JWT.Secret = secret
	}
	if expireTime := os.Getenv("JWT_EXPIRE_TIME"); expireTime != "" {
		if duration, err := time.ParseDuration(expireTime); err == nil {
			config.JWT.ExpiresAt = duration
		}
	}

	// 服务器配置覆盖
	if mode := os.Getenv("GIN_MODE"); mode != "" {
		config.Server.Mode = mode
	}
	if port := os.Getenv("SERVER_PORT"); port != "" {
		config.Server.Port = port
	}

	// 日志配置覆盖
	if level := os.Getenv("LOG_LEVEL"); level != "" {
		config.Logger.Level = level
	}
}

// validateConfig 验证配置
func validateConfig(config *Config) error {
	if config.Server.Port == "" {
		return fmt.Errorf("server.port 不能为空")
	}
	if config.Database.Host == "" {
		return fmt.Errorf("database.host 不能为空")
	}
	if config.Database.Username == "" {
		return fmt.Errorf("database.username 不能为空")
	}
	if config.Database.DBName == "" {
		return fmt.Errorf("database.dbname 不能为空")
	}
	if config.JWT.Secret == "" {
		return fmt.Errorf("jwt.secret 不能为空")
	}
	return nil
}

// GetDSN 获取数据库连接字符串
func (c *DatabaseConfig) GetDSN() string {
	return fmt.Sprintf("%s:%s@tcp(%s:%d)/%s?charset=%s&parseTime=%t&loc=%s",
		c.Username,
		c.Password,
		c.Host,
		c.Port,
		c.DBName,
		c.Charset,
		c.ParseTime,
		c.Loc,
	)
}

// GetRedisAddr 获取Redis连接地址
func (c *RedisConfig) GetRedisAddr() string {
	return fmt.Sprintf("%s:%d", c.Host, c.Port)
}

// 获取当前环境
func GetEnv() string {
	env := os.Getenv("APP_ENV")
	if env == "" {
		return "dev"
	}
	return env
}

// 判断是否为开发环境
func IsDev() bool {
	return GetEnv() == "dev"
}

// 判断是否为生产环境
func IsProd() bool {
	return GetEnv() == "prod"
}

// 判断是否为测试环境
func IsTest() bool {
	return GetEnv() == "test"
}
