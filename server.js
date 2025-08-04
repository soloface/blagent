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

// 服务构建后的前端静态文件
app.use(express.static(path.join(__dirname, 'dist')))
// 备用静态文件服务（开发环境）
app.use(express.static('public'))
app.use(express.static('.'))

// API路由
app.post('/api/chat', async (req, res) => {
  await handler(req, res)
})

// 健康检查端点
app.get('/health', (req, res) => {
  res.json({ status: 'ok', message: 'API服务器运行正常' })
})

// SPA路由处理 - 所有非API请求都返回index.html
app.get('*', (req, res) => {
  // 优先尝试服务构建后的文件
  const distIndexPath = path.join(__dirname, 'dist', 'index.html')
  const rootIndexPath = path.join(__dirname, 'index.html')
  
  // 检查是否存在构建后的文件
  try {
    res.sendFile(distIndexPath)
  } catch (error) {
    // 如果构建文件不存在，使用根目录的index.html
    res.sendFile(rootIndexPath)
  }
})

const PORT = process.env.PORT || 3000
app.listen(PORT, () => {
  console.log(`全栈应用运行在端口 ${PORT}，提供完整的Web应用服务`)
})