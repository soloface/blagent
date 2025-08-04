import express from 'express'
import dotenv from 'dotenv'

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

// 创建API路由
app.post('/api/chat', async (req, res) => {
  await handler(req, res)
})

// 添加健康检查端点（可选）
app.get('/health', (req, res) => {
  res.json({ status: 'ok', message: 'API服务器运行正常' })
})

const PORT = process.env.PORT || 3000
app.listen(PORT, () => {
  console.log(`API服务器运行在端口 ${PORT}，仅提供API服务`)
})