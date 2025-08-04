# BLAgent

一个基于 React + Vite 构建的智能代理应用，集成阿里百炼 API，提供智能对话功能。

## 🚀 功能特性

- 🎨 现代化的 React 18 用户界面
- ⚡ 基于 Vite 的快速开发环境
- 🔧 Express.js 后端 API 服务
- 🤖 集成阿里百炼 AI 对话功能
- 📝 支持 Markdown 格式渲染
- 🔄 自动重试机制和错误处理

## 📋 项目架构
blagent/
├── src/                    # React 前端源码
│   ├── App.jsx            # 主应用组件
│   ├── components/        # 可复用组件
│   └── assets/           # 静态资源
├── api/                   # API 路由处理
│   └── chat.js           # 聊天 API 处理函数
├── server.js             # Express 后端服务器
├── vite.config.js        # Vite 配置（包含 API 代理）
├── .env.local            # 环境变量配置
└── package.json          # 项目依赖和脚本


## 🛠️ 环境准备

### 系统要求
- Node.js >= 16.0.0
- npm >= 8.0.0

### 环境变量配置

创建 `.env.local` 文件并配置：

```bash
# 阿里百炼 API 配置
BAILIAN_API_KEY=你的阿里百炼API密钥
BAILIAN_APP_ID=你的应用ID

# 可选：服务器端口配置
PORT=3000
```

**获取 API 密钥：**
1. 访问 [阿里云百炼平台](https://bailian.console.aliyun.com/)
2. 创建应用并获取 APP_ID
3. 在 API-KEY 管理中创建并获取 API_KEY

## 📦 安装依赖

```bash
npm install
```

## 🚀 启动方式

### 开发环境

**方法一：分步启动**
```bash
# 终端 1：启动后端服务
node server.js

# 终端 2：启动前端开发服务
npm run dev
```

**方法二：同时启动**
```bash
npm run dev:full
```

### 生产环境

```bash
# 构建前端
npm run build

# 启动生产服务器
npm start
```

## 🌐 访问地址

- **开发环境前端**: http://localhost:5173
- **开发环境后端**: http://localhost:3000
- **生产环境**: http://localhost:3000
- **健康检查**: http://localhost:3000/health
- **API 接口**: POST http://localhost:3000/api/chat

## 🔧 API 使用示例

```bash
curl -X POST http://localhost:3000/api/chat \
  -H "Content-Type: application/json" \
  -d '{"message": "你好，请介绍一下你自己"}'
```

## 🚀 部署方案

### 传统服务器部署

1. **克隆项目**
   ```bash
   git clone https://github.com/soloface/blagent.git
   cd blagent
   ```

2. **安装依赖**
   ```bash
   npm install
   ```

3. **配置环境变量**
   ```bash
   echo "BAILIAN_API_KEY=你的API密钥" > .env.local
   echo "BAILIAN_APP_ID=你的应用ID" >> .env.local
   ```

4. **构建前端**
   ```bash
   npm run build
   ```

5. **使用 PM2 管理进程**
   ```bash
   # 安装 PM2
   npm install -g pm2
   
   # 启动应用
   pm2 start server.js --name "blagent"
   
   # 设置开机自启
   pm2 startup
   pm2 save
   ```

6. **验证部署**
   ```bash
   pm2 status
   curl http://localhost:3000/health
   ```

### Docker 部署（待测试）

```dockerfile
# Dockerfile 示例（待完善）
FROM node:18-alpine
WORKDIR /app
COPY package*.json ./
RUN npm install
COPY . .
RUN npm run build
EXPOSE 3000
CMD ["npm", "start"]
```

## 🛠️ 开发脚本

```json
{
  "scripts": {
    "dev": "vite",                   // 启动前端开发服务器
    "build": "vite build",           // 构建生产版本
    "start": "node server.js",       // 启动生产服务器
    "dev:server": "node server.js",  // 仅启动后端服务
    "dev:client": "vite",            // 仅启动前端服务
    "dev:full": "concurrently \"npm run dev:server\" \"npm run dev:client\""  // 同时启动前后端
  }
}
```

## 🔍 常用管理命令

```bash
# PM2 管理
pm2 status          # 查看服务状态
pm2 logs blagent    # 查看日志
pm2 restart blagent # 重启服务
pm2 stop blagent    # 停止服务

# 更新部署
git pull origin main # 拉取最新代码
npm run build        # 重新构建
pm2 restart blagent # 重启服务
```

## 📚 技术栈

- **前端**: React 18 + Vite + CSS3
- **后端**: Node.js + Express.js
- **AI 服务**: 阿里百炼 API
- **部署**: PM2 进程管理