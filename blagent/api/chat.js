// 在开发环境中加载 .env.local 文件
import dotenv from 'dotenv'
if (process.env.NODE_ENV !== 'production') {
  dotenv.config({ path: '.env.local' })
}

export default async function handler(req, res) {
  if (req.method !== 'POST') {
    return res.status(405).json({ error: '只支持POST请求' })
  }

  const { message } = req.body
  
  // 从环境变量获取API密钥和应用ID
  const apiKey = process.env.BAILIAN_API_KEY
  const appId = process.env.BAILIAN_APP_ID

  if (!apiKey || !appId) {
    return res.status(500).json({ error: '服务器未正确配置API密钥或应用ID' })
  }

  if (!message) {
    return res.status(400).json({ error: '缺少消息内容' })
  }

  try {
    // 调用阿里百炼API
    const response = await fetch(`https://dashscope.aliyuncs.com/api/v1/apps/${appId}/completion`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': `Bearer ${apiKey}`
      },
      body: JSON.stringify({
        input: {
          prompt: message
        },
        parameters: {},
        debug: {}
      })
    })

    const data = await response.json()
    
    if (data.output && data.output.text) {
      return res.status(200).json({ response: data.output.text })
    } else {
      return res.status(500).json({ error: '无效的API响应', details: JSON.stringify(data) })
    }
  } catch (error) {
    console.error('API调用错误:', error)
    return res.status(500).json({ error: '服务器错误', message: error.message })
  }
}