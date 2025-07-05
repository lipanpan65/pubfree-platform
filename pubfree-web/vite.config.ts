import { defineConfig } from 'vite'
import react from '@vitejs/plugin-react'
import { resolve } from 'path'

export default defineConfig({
  plugins: [
    react({
      babel: {
        plugins: [
          ['@babel/plugin-proposal-decorators', { legacy: true }],
          ['@babel/plugin-proposal-class-properties', { loose: false }],
        ],
      },
    }),
  ],
  resolve: {
    alias: {
      '@': resolve(__dirname, './src'),
    },
  },
  define: {
    // 定义全局变量 - 根据环境动态设置
    USE_V_CONSOLE: JSON.stringify(false),
    SERVER_URL: JSON.stringify(
      process.env.VITE_SERVER_URL || 
      (process.env.NODE_ENV === 'production' ? 'http://pubfree-server:8080' : 'http://localhost:8080')
    ),
    DOMAIN_SUFFIX: JSON.stringify(process.env.VITE_DOMAIN_SUFFIX || ''),
  },
  server: {
    host: '0.0.0.0', // 添加这一行以支持 Docker
    port: 3000,
    open: false, // Docker 环境中关闭自动打开浏览器
    proxy: {
      '/api': {
        target: process.env.VITE_API_TARGET || 'http://localhost:8080',
        changeOrigin: true,
      },
    },
  },
  build: {
    outDir: 'dist',
    sourcemap: true,
  },
  // 忽略 antd 的 React 19 兼容性警告
  esbuild: {
    logOverride: { 'this-is-undefined-in-esm': 'silent' },
  },
})