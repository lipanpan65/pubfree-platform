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
    // 定义全局变量
    USE_V_CONSOLE: JSON.stringify(false),
    SERVER_URL: JSON.stringify('http://localhost:8080'),
    DOMAIN_SUFFIX: JSON.stringify(''),
  },
  server: {
    port: 3000,
    open: true,
    proxy: {
      '/api': {
        target: 'http://localhost:8080',
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