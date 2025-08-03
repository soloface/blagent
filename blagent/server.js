import express from 'express'
import { fileURLToPath } from 'url'
import { dirname } from 'path'
import dotenv from 'dotenv'

// 加载环境变量
dotenv.config({ path: '.env.local' })

const __filename = fileURLToPath(import.meta.url)
const __dirname = dirname(__filename)

const app = express()
app.use(express.json())

// 导入API处理函数
import handler from './api/chat.js'

// 创建API路由
app.post('/api/chat', async (req, res) => {
  await handler(req, res)
})

const PORT = 3000
app.listen(PORT, () => {
  console.log(`API服务器运行在 http://localhost:${PORT}`)
})