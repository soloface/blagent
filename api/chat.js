// 在开发环境中加载 .env.local 文件
import dotenv from 'dotenv'
if (process.env.NODE_ENV !== 'production') {
  dotenv.config({ path: '.env.local' })
}

// 带重试和超时的 fetch 函数
async function fetchWithRetry(url, options, maxRetries = 5, timeout = 180000) { // 增加到180秒超时和5次重试
  let lastError;
  
  // 添加超时控制
  const controller = new AbortController();
  const timeoutId = setTimeout(() => controller.abort(), timeout);
  
  try {
    options.signal = controller.signal;
    
    for (let attempt = 0; attempt < maxRetries; attempt++) {
      try {
        console.log(`尝试 API 请求，第 ${attempt + 1} 次...`);
        console.log(`请求URL: ${url}`);
        
        // 添加DNS解析日志
        try {
          const { hostname } = new URL(url);
          console.log(`正在解析主机名: ${hostname}`);
        } catch (e) {
          console.error("URL解析错误:", e.message);
        }
        
        const response = await fetch(url, options);
        
        // 检查 HTTP 状态码
        if (!response.ok) {
          throw new Error(`HTTP 错误: ${response.status} ${response.statusText}`);
        }
        
        // 尝试解析 JSON
        const data = await response.json();
        return { response, data };
      } catch (error) {
        console.error(`第 ${attempt + 1} 次请求失败:`, error.message);
        console.error(`错误类型: ${error.name}, 错误代码: ${error.code}`);
        lastError = error;
        
        // 如果是超时错误或网络错误，等待后重试
        if (error.name === 'AbortError' || 
            error.code === 'ETIMEDOUT' || 
            error.code === 'ECONNREFUSED' || 
            error.code === 'ECONNRESET' || 
            error.message.includes('network') ||
            error.message.includes('timeout')) {
          // 等待时间随重试次数增加
          const waitTime = 2000 * Math.pow(2, attempt); // 增加基础等待时间
          console.log(`等待 ${waitTime}ms 后重试...`);
          await new Promise(resolve => setTimeout(resolve, waitTime));
          continue;
        }
        
        // 如果是 JSON 解析错误或其他错误，直接抛出
        throw error;
      }
    }
    
    // 所有重试都失败
    throw lastError || new Error('所有重试尝试均失败');
  } finally {
    clearTimeout(timeoutId);
  }
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
    // 定义可能的API端点
    const apiEndpoints = [
      `https://dashscope.aliyuncs.com/api/v1/apps/${appId}/completion`,
      `https://dashscope-api.aliyuncs.com/api/v1/apps/${appId}/completion`,
      `https://dashscope-cn-beijing.aliyuncs.com/api/v1/apps/${appId}/completion`
    ];
    
    let lastError;
    // 尝试所有可能的API端点
    for (const endpoint of apiEndpoints) {
      try {
        console.log(`尝试API端点: ${endpoint}`);
        // 使用带重试的 fetch 函数调用阿里百炼API
        const { data } = await fetchWithRetry(
          endpoint, 
          {
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
          },
          5,  // 5次重试
          180000  // 180秒超时
        );
        
        if (data.output && data.output.text) {
          console.log('API调用成功，返回响应');
          return res.status(200).json({ response: data.output.text });
        } else {
          console.error('API响应无效:', JSON.stringify(data));
          lastError = new Error('无效的API响应');
          continue; // 尝试下一个端点
        }
      } catch (error) {
        console.error(`端点 ${endpoint} 调用失败:`, error.message);
        lastError = error;
        // 继续尝试下一个端点
      }
    }
    
    // 所有端点都失败
    throw lastError || new Error('所有API端点尝试均失败');
  } catch (error) {
    console.error('API调用最终失败:', error.message);
    return res.status(500).json({ 
      error: '服务器错误', 
      message: error.message,
      type: error.name || '未知错误类型'
    });
  }
}