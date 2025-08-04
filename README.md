# BLAgent

一个基于 React + Vite 构建的智能代理应用，集成阿里百炼 API，提供智能对话功能。

## 🚀 功能特性

- 🎨 现代化的 React 18 用户界面
- ⚡ 基于 Vite 的快速开发环境
- 🔧 Express.js 后端 API 服务
- 🤖 集成阿里百炼 AI 对话功能
- 📝 支持 Markdown 格式渲染
- 🔄 自动重试机制和错误处理
- 🌐 支持多个 API 端点自动切换

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

1. 确保项目根目录存在 `.env.local` 文件
2. 配置以下环境变量：

```bash
# 阿里百炼 API 配置
BAILIAN_API_KEY=你的阿里百炼API密钥
BAILIAN_APP_ID=你的应用ID

# 可选：服务器端口配置
PORT=3000
```

**获取 API 密钥步骤：**
1. 访问 [阿里云百炼平台](https://bailian.console.aliyun.com/)
2. 创建应用并获取 APP_ID
3. 在 API-KEY 管理中创建并获取 API_KEY

## 📦 安装依赖

```bash
# 安装项目依赖
npm install
```

## 🚀 启动流程

### 开发环境启动

**方法一：分步启动（推荐）**

1. **启动后端 API 服务器**
   ```bash
   # 终端 1：启动后端服务
   node server.js
   ```
   
   成功启动后会看到：
   ```
   API服务器运行在端口 3000，仅提供API服务
   ```

2. **启动前端开发服务器**
   ```bash
   # 终端 2：启动前端开发服务
   npm run dev
   ```
   
   成功启动后会看到：
   ```
   Local:   http://localhost:5173/
   Network: use --host to expose
   ```

**方法二：使用 concurrently 同时启动**

1. 安装 concurrently（可选）：
   ```bash
   npm install --save-dev concurrently
   ```

2. 在 package.json 中添加脚本：
   ```json
   {
     "scripts": {
       "dev:server": "node server.js",
       "dev:client": "vite",
       "dev:full": "concurrently \"npm run dev:server\" \"npm run dev:client\""
     }
   }
   ```

3. 同时启动前后端：
   ```bash
   npm run dev:full
   ```

### 生产环境部署

**本地生产环境测试：**

1. **构建前端应用**
   ```bash
   npm run build
   ```
   
   构建产物会生成在 `dist/` 目录

2. **启动生产服务器**
   ```bash
   npm start
   ```
   
   这将启动 Express 服务器，同时提供 API 和静态文件服务

## 🌐 访问地址

### 开发环境
- **前端应用**: http://localhost:5173
- **后端 API**: http://localhost:3000
- **健康检查**: http://localhost:3000/health
- **聊天 API**: POST http://localhost:3000/api/chat

### 生产环境
- **完整应用**: http://localhost:3000
- **API 接口**: http://localhost:3000/api/*

## 🔧 API 使用说明

### 聊天接口

**请求示例：**
```bash
curl -X POST http://localhost:3000/api/chat \
  -H "Content-Type: application/json" \
  -d '{
    "message": "你好，请介绍一下你自己"
  }'
```

**响应示例：**
```json
{
  "response": "你好！我是一个AI助手，可以帮助你回答问题、提供信息和进行对话。有什么我可以帮助你的吗？"
}
```

**错误响应：**
```json
{
  "error": "服务器错误",
  "message": "具体错误信息",
  "type": "错误类型"
}
```

## 🚀 部署方案

### Vercel 部署（推荐）

项目已配置 `vercel.json`，支持一键部署到 Vercel：

1. **安装 Vercel CLI**
   ```bash
   npm install -g vercel
   ```

2. **登录 Vercel**
   ```bash
   vercel login
   ```

3. **部署项目**
   ```bash
   vercel
   ```

4. **配置环境变量**
   在 Vercel 控制台中设置：
   - `BAILIAN_API_KEY`
   - `BAILIAN_APP_ID`

### Docker 部署

1. **创建 Dockerfile**
   ```dockerfile
   FROM node:18-alpine
   
   WORKDIR /app
   
   COPY package*.json ./
   RUN npm ci --only=production
   
   COPY . .
   RUN npm run build
   
   EXPOSE 3000
   
   CMD ["npm", "start"]
   ```

2. **构建镜像**
   ```bash
   docker build -t blagent .
   ```

3. **运行容器**
   ```bash
   docker run -p 3000:3000 \
     -e BAILIAN_API_KEY=你的API密钥 \
     -e BAILIAN_APP_ID=你的应用ID \
     blagent
   ```

### 传统服务器部署

1. **上传代码到服务器**
   ```bash
   # 使用 git 克隆或 scp 上传
   git clone https://github.com/你的用户名/blagent.git
   cd blagent
   ```

2. **安装依赖并构建**
   ```bash
   npm install
   npm run build
   ```

3. **配置环境变量**
   ```bash
   # 创建 .env.local 文件
   echo "BAILIAN_API_KEY=你的API密钥" > .env.local
   echo "BAILIAN_APP_ID=你的应用ID" >> .env.local
   ```

4. **使用 PM2 管理进程**
   ```bash
   # 安装 PM2
   npm install -g pm2
   
   # 启动应用
   pm2 start server.js --name "blagent"
   
   # 设置开机自启
   pm2 startup
   pm2 save
   ```

## 🛠️ 开发脚本说明

```json
{
  "scripts": {
    "dev": "vite",                    // 启动前端开发服务器
    "build": "vite build",           // 构建生产版本
    "lint": "eslint .",              // 代码检查
    "preview": "vite preview",       // 预览构建结果
    "start": "node server.js",       // 启动生产服务器
    "dev:server": "node server.js",  // 仅启动后端服务
    "dev:client": "vite",            // 仅启动前端服务
    "dev:full": "concurrently \"npm run dev:server\" \"npm run dev:client\""  // 同时启动前后端
  }
}
```

## 🔍 故障排除

### 常见问题

1. **API 调用失败**
   - 检查 `.env.local` 文件中的 API 密钥是否正确
   - 确认网络连接正常
   - 查看控制台错误日志

2. **前端无法访问后端**
   - 确认后端服务器已启动（端口 3000）
   - 检查 `vite.config.js` 中的代理配置
   - 确认防火墙设置

3. **构建失败**
   - 清除 node_modules 并重新安装：`rm -rf node_modules && npm install`
   - 检查 Node.js 版本是否符合要求

### 日志查看

- **开发环境**：直接在终端查看实时日志
- **生产环境**：使用 PM2 查看日志
  ```bash
  pm2 logs blagent
  ```

## 📚 技术栈

### 前端
- **React 18** - 用户界面库
- **Vite** - 构建工具和开发服务器
- **React Markdown** - Markdown 渲染
- **CSS3** - 样式设计

### 后端
- **Node.js** - 运行时环境
- **Express.js** - Web 框架
- **dotenv** - 环境变量管理
- **node-fetch** - HTTP 请求库

### AI 服务
- **阿里百炼 API** - 智能对话服务
- **自动重试机制** - 提高服务可靠性
- **多端点支持** - 确保服务可用性

## 📄 许可证

本项目采用 MIT 许可证。详见 [LICENSE](LICENSE) 文件。

## 🤝 贡献

欢迎提交 Issue 和 Pull Request！

## 📞 支持

如有问题，请通过以下方式联系：
- 提交 GitHub Issue
- 发送邮件至：[你的邮箱]