import express from 'express'
import { fileURLToPath } from 'url'
import { dirname, join } from 'path'
import dotenv from 'dotenv'

// 加载环境变量
dotenv.config({ path: '.env.local' })

const __filename = fileURLToPath(import.meta.url)
const __dirname = dirname(__filename)

const app = express()
app.use(express.json())

// 添加静态文件服务
app.use(express.static(join(__dirname, 'dist')))

// 导入API处理函数
import handler from './api/chat.js'

// 创建API路由
app.post('/api/chat', async (req, res) => {
  await handler(req, res)
})

// 添加通配符路由，处理所有其他请求
app.get('*', (req, res) => {
  res.sendFile(join(__dirname, 'dist', 'index.html'))
})

const PORT = 3000
app.listen(PORT, () => {
  console.log(`API服务器运行在 http://localhost:${PORT}`)
})