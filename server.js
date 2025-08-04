import express from 'express'
import dotenv from 'dotenv'
import path from 'path'
import { fileURLToPath } from 'url'

// 获取当前文件的目录路径
const __filename = fileURLToPath(import.meta.url)
const __dirname = path.dirname(__filename)

// 加载环境变量
dotenv.config({ path: '.env.local' })

const app = express()
app.use(express.json())

// 导入API处理函数
let handler;
try {
  const module = await import('./api/chat.js');
  handler = module.default;
} catch (error) {
  console.error('导入API处理函数失败:', error);
  process.exit(1);
}

// 静态文件服务
app.use(express.static('public'))
app.use(express.static('.'))

// 创建API路由
app.post('/api/chat', async (req, res) => {
  await handler(req, res)
})

// 添加健康检查端点
app.get('/health', (req, res) => {
  res.json({ status: 'ok', message: 'API服务器运行正常' })
})

// 根路径处理 - 返回主页
app.get('/', (req, res) => {
  res.sendFile(path.join(__dirname, 'index.html'))
})

// 处理所有其他路由，返回主页（用于SPA路由）
app.get('*', (req, res) => {
  res.sendFile(path.join(__dirname, 'index.html'))
})

const PORT = process.env.PORT || 3000
app.listen(PORT, () => {
  console.log(`服务器运行在端口 ${PORT}，提供完整的Web应用服务`)
})