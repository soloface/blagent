#!/bin/bash

# 颜色定义
GREEN="\033[0;32m"
RED="\033[0;31m"
YELLOW="\033[0;33m"
BLUE="\033[0;34m"
CYAN="\033[0;36m"
NC="\033[0m" # No Color

# 当前目录
CURRENT_DIR="$(pwd)"

# 输出函数
echo_success() { echo -e "${GREEN}$1${NC}"; }
echo_error() { echo -e "${RED}$1${NC}"; }
echo_warning() { echo -e "${YELLOW}$1${NC}"; }
echo_info() { echo -e "${BLUE}$1${NC}"; }
echo_highlight() { echo -e "${CYAN}$1${NC}"; }

# 设置项目目录
function setup_project {
  if [ ! -d "$CURRENT_DIR/blagent" ]; then
    echo_info "创建项目目录..."
    mkdir -p "$CURRENT_DIR/blagent"
    mkdir -p "$CURRENT_DIR/blagent/api"
    mkdir -p "$CURRENT_DIR/blagent/dist"
  else
    echo_info "项目目录已存在，跳过创建步骤"
  fi
}

# 获取API凭证
function get_api_credentials {
  local retry=true
  local api_key=""
  local app_id=""
  
  # 检查是否已存在.env.local文件
  if [ -f "$CURRENT_DIR/blagent/.env.local" ]; then
    echo_info "发现已存在的.env.local文件"
    # 尝试读取已有的API密钥和应用ID
    if grep -q "BAILIAN_API_KEY" "$CURRENT_DIR/blagent/.env.local"; then
      api_key=$(grep "BAILIAN_API_KEY" "$CURRENT_DIR/blagent/.env.local" | cut -d'=' -f2)
      echo_info "已读取现有API密钥"
    fi
    
    if grep -q "BAILIAN_APP_ID" "$CURRENT_DIR/blagent/.env.local"; then
      app_id=$(grep "BAILIAN_APP_ID" "$CURRENT_DIR/blagent/.env.local" | cut -d'=' -f2)
      echo_info "已读取现有应用ID"
    fi
    
    # 如果两者都已存在，询问是否使用现有凭证
    if [ -n "$api_key" ] && [ -n "$app_id" ]; then
      echo_highlight "是否使用现有API凭证? (y/n): "
      read use_existing
      if [ "$use_existing" = "y" ]; then
        echo_success "使用现有API凭证"
        return 0
      fi
    fi
  fi
  
  while $retry; do
    echo_highlight "请输入您的阿里百炼API密钥(BAILIAN_API_KEY):"
    read api_key
    
    echo_highlight "请输入您的阿里百炼应用ID(BAILIAN_APP_ID):"
    read app_id
    
    if [ -n "$api_key" ] && [ -n "$app_id" ]; then
      echo_success "API凭证已提供"
      retry=false
    else
      echo_error "API凭证不能为空!"
      echo_warning "是否重新输入? (y/n): "
      read retry_input
      if [ "$retry_input" != "y" ] && [ "$retry_input" != "Y" ]; then
        echo_info "取消操作"
        return 1
      fi
    fi
  done
  
  # 创建或更新.env.local文件
  echo "BAILIAN_API_KEY=$api_key" > "$CURRENT_DIR/blagent/.env.local"
  echo "BAILIAN_APP_ID=$app_id" >> "$CURRENT_DIR/blagent/.env.local"
  echo_success "API凭证已保存"
  
  return 0
}

# 创建必要的文件
function create_files {
  # 创建package.json
  echo_info "创建package.json..."
  cat > "$CURRENT_DIR/blagent/package.json" << 'EOL'
{
  "name": "blagent",
  "private": true,
  "version": "0.0.0",
  "type": "module",
  "scripts": {
    "dev": "vite",
    "build": "vite build",
    "lint": "eslint .",
    "preview": "vite preview",
    "start": "node server.js"
  },
  "dependencies": {
    "express": "^4.18.2",
    "dotenv": "^16.3.1",
    "node-fetch": "^3.3.2"
  },
  "devDependencies": {
    "@types/react": "^18.2.15",
    "@types/react-dom": "^18.2.7",
    "@vitejs/plugin-react": "^4.0.3",
    "eslint": "^8.45.0",
    "eslint-plugin-react": "^7.32.2",
    "eslint-plugin-react-hooks": "^4.6.0",
    "eslint-plugin-react-refresh": "^0.4.3",
    "vite": "^4.4.5"
  }
}
EOL

  # 创建server.js
  echo_info "创建server.js..."
  cat > "$CURRENT_DIR/blagent/server.js" << 'EOL'
import express from 'express';
import { fileURLToPath } from 'url';
import { dirname, join } from 'path';
import dotenv from 'dotenv';
import fs from 'fs';

// 加载环境变量
dotenv.config({ path: '.env.local' });

const __filename = fileURLToPath(import.meta.url);
const __dirname = dirname(__filename);

const app = express();
app.use(express.json());

// 检查dist目录是否存在，如果不存在则创建
if (!fs.existsSync(join(__dirname, 'dist'))) {
  fs.mkdirSync(join(__dirname, 'dist'), { recursive: true });
}

// 检查index.html是否存在，如果不存在则创建一个基本的
const indexPath = join(__dirname, 'dist', 'index.html');
if (!fs.existsSync(indexPath)) {
  # 将第155-200行的HTML部分替换为以下内容
  const basicHtml = `<!DOCTYPE html>
<html lang="zh-CN">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>壹唯视顾问Agent（测试）</title>
  <style>
    body { font-family: Arial, sans-serif; max-width: 800px; margin: 0 auto; padding: 20px; background-color: #f9f9f9; }
    h1 { color: #333; text-align: center; margin-bottom: 20px; }
    .chat-container { display: flex; flex-direction: column; height: 80vh; border-radius: 8px; box-shadow: 0 4px 12px rgba(0, 0, 0, 0.1); background-color: white; overflow: hidden; }
    .messages-container { flex: 1; overflow-y: auto; padding: 20px; display: flex; flex-direction: column-reverse; gap: 15px; }
    .message { max-width: 80%; padding: 12px 16px; border-radius: 8px; word-break: break-word; line-height: 1.5; }
    .message.user { align-self: flex-end; background-color: #4361ee; color: white; }
    .message.assistant { align-self: flex-start; background-color: #f0f0f0; color: #333; border-left: 3px solid #646cff; }
    .message.system { align-self: center; background-color: #7b2cbf; color: white; font-style: italic; }
    .message-role { font-size: 12px; margin-bottom: 4px; opacity: 0.8; font-weight: bold; }
    .input-form { display: flex; padding: 15px; background-color: #f5f5f5; border-top: 1px solid #eee; }
    .input-form textarea { flex: 1; padding: 12px 15px; border-radius: 8px 0 0 8px; border: 1px solid #ddd; resize: none; height: 50px; }
    .input-form button { padding: 0 20px; border-radius: 0 8px 8px 0; border: 1px solid #4CAF50; background: #4CAF50; color: white; cursor: pointer; transition: background 0.3s; }
    .input-form button:hover:not(:disabled) { background: #3d9140; }
    .input-form button:disabled { background: #cccccc; border-color: #cccccc; cursor: not-allowed; }
    .typing-indicator::after { content: '|'; animation: blink 1s step-end infinite; }
    @keyframes blink { from, to { opacity: 1; } 50% { opacity: 0; } }
    .message-content { white-space: pre-wrap; }
    pre { background-color: #f5f5f5; padding: 10px; border-radius: 5px; overflow-x: auto; }
    code { font-family: monospace; background-color: #f0f0f0; padding: 2px 4px; border-radius: 3px; }
  </style>
</head>
<body>
  <h1>壹唯视顾问Agent（测试）</h1>
  <div class="chat-container">
    <div class="messages-container" id="messagesContainer">
      <div class="message system">
        <div class="message-content">欢迎使用壹唯视Agent测试界面！请在下方输入您的问题。</div>
      </div>
    </div>
    <form id="chatForm" class="input-form">
      <textarea id="message" placeholder="输入您的问题..." required></textarea>
      <button type="submit" id="sendButton">发送</button>
    </form>
  </div>

  <script>
    const messagesContainer = document.getElementById('messagesContainer');
    const chatForm = document.getElementById('chatForm');
    const messageInput = document.getElementById('message');
    const sendButton = document.getElementById('sendButton');
    
    // 自动滚动到顶部（因为我们使用了column-reverse布局）
    function scrollToTop() {
      messagesContainer.scrollTop = 0;
    }
    
    // 创建消息元素
    function createMessageElement(role, content) {
      const messageDiv = document.createElement('div');
      messageDiv.className = `message ${role}`;
      
      const roleDiv = document.createElement('div');
      roleDiv.className = 'message-role';
      roleDiv.textContent = role === 'user' ? '您' : role === 'assistant' ? 'AI' : '系统';
      
      const contentDiv = document.createElement('div');
      contentDiv.className = 'message-content';
      
      // 处理markdown格式
      const formattedContent = formatMarkdown(content);
      contentDiv.innerHTML = formattedContent;
      
      messageDiv.appendChild(roleDiv);
      messageDiv.appendChild(contentDiv);
      return messageDiv;
    }
    
    // 简单的Markdown格式化
    function formatMarkdown(text) {
      // 处理代码块
      text = text.replace(/```([\s\S]*?)```/g, '<pre><code>$1</code></pre>');
      
      // 处理行内代码
      text = text.replace(/`([^`]+)`/g, '<code>$1</code>');
      
      // 处理粗体
      text = text.replace(/\*\*([^*]+)\*\*/g, '<strong>$1</strong>');
      
      // 处理斜体
      text = text.replace(/\*([^*]+)\*/g, '<em>$1</em>');
      
      // 处理换行
      text = text.replace(/\n/g, '<br>');
      
      return text;
    }
    
    // 逐字显示文本
    async function typeText(element, text) {
      const typingSpeed = 20; // 打字速度，数值越小越快
      const formattedText = formatMarkdown(text);
      element.innerHTML = ''; // 清空内容
      element.classList.add('typing-indicator');
      
      // 创建临时元素来解析HTML
      const tempDiv = document.createElement('div');
      tempDiv.innerHTML = formattedText;
      const textContent = tempDiv.textContent;
      
      let displayedText = '';
      for (let i = 0; i < textContent.length; i++) {
        displayedText += textContent[i];
        // 更新显示的内容，但保持HTML格式
        element.innerHTML = formatMarkdown(displayedText);
        scrollToTop();
        await new Promise(resolve => setTimeout(resolve, typingSpeed));
      }
      
      // 最后设置完整的格式化文本
      element.innerHTML = formattedText;
      element.classList.remove('typing-indicator');
    }
    
    chatForm.addEventListener('submit', async (e) => {
      e.preventDefault();
      const message = messageInput.value.trim();
      if (!message) return;
      
      // 禁用输入和按钮
      messageInput.disabled = true;
      sendButton.disabled = true;
      
      // 添加用户消息（插入到容器顶部，因为我们使用了column-reverse布局）
      const userMessageElement = createMessageElement('user', message);
      messagesContainer.insertBefore(userMessageElement, messagesContainer.firstChild);
      scrollToTop();
      
      // 添加系统消息
      const thinkingElement = createMessageElement('system', '正在思考...');
      messagesContainer.insertBefore(thinkingElement, messagesContainer.firstChild);
      scrollToTop();
      
      try {
        // 发送请求
        const res = await fetch('/api/chat', {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({ message })
        });
        const data = await res.json();
        
        // 移除思考中消息
        messagesContainer.removeChild(thinkingElement);
        
        // 创建AI回复元素
        const aiMessageElement = createMessageElement('assistant', '');
        messagesContainer.insertBefore(aiMessageElement, messagesContainer.firstChild);
        scrollToTop();
        
        // 获取内容div并逐字显示
        const contentDiv = aiMessageElement.querySelector('.message-content');
        await typeText(contentDiv, data.response || data.error || '无响应');
      } catch (error) {
        console.error('Error:', error);
        // 移除思考中消息
        messagesContainer.removeChild(thinkingElement);
        
        // 添加错误消息
        const errorMessageElement = createMessageElement('system', `请求出错: ${error.message}`);
        messagesContainer.insertBefore(errorMessageElement, messagesContainer.firstChild);
        scrollToTop();
      } finally {
        // 重置输入框并启用
        messageInput.value = '';
        messageInput.disabled = false;
        sendButton.disabled = false;
        messageInput.focus();
      }
    });
  </script>
</body>
</html>`;
  fs.writeFileSync(indexPath, basicHtml);
}

// 添加静态文件服务
app.use(express.static(join(__dirname, 'dist')));

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
  await handler(req, res);
});

// 添加通配符路由，处理所有其他请求
app.get('*', (req, res) => {
  res.sendFile(join(__dirname, 'dist', 'index.html'));
});

const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
  console.log(`API服务器运行在 http://localhost:${PORT}`);
});
EOL

  # 创建api/chat.js
  echo_info "创建api/chat.js..."
  mkdir -p "$CURRENT_DIR/blagent/api"
  cat > "$CURRENT_DIR/blagent/api/chat.js" << 'EOL'
import dotenv from 'dotenv';

// 加载环境变量
dotenv.config({ path: '.env.local' });

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
    return res.status(405).json({ error: '只支持POST请求' });
  }

  const { message } = req.body;
  
  // 从环境变量获取API密钥和应用ID
  const apiKey = process.env.BAILIAN_API_KEY;
  const appId = process.env.BAILIAN_APP_ID;

  if (!apiKey || !appId) {
    console.error('环境变量未设置: BAILIAN_API_KEY 或 BAILIAN_APP_ID');
    return res.status(500).json({ error: '服务器未正确配置API密钥或应用ID' });
  }

  if (!message) {
    return res.status(400).json({ error: '缺少消息内容' });
  }

  try {
    console.log('开始调用阿里百炼API...');
    console.log(`使用的应用ID: ${appId}`);
    
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
EOL

  # 创建CommonJS启动脚本
  echo_info "创建CommonJS启动脚本..."
  cat > "$CURRENT_DIR/blagent/start.cjs" << 'EOL'
// CommonJS启动脚本
const { spawn } = require('child_process');

// 使用Node.js的ES模块支持启动server.js
const server = spawn('node', ['--experimental-modules', 'server.js'], {
  stdio: 'inherit',
  env: { ...process.env }
});

server.on('close', (code) => {
  console.log(`服务器进程退出，退出码 ${code}`);
});
EOL

  # 创建PM2配置文件
  echo_info "创建PM2配置文件..."
  cat > "$CURRENT_DIR/blagent/ecosystem.config.cjs" << 'EOL'
module.exports = {
  apps: [{
    name: "blagent",
    script: "server.js",
    interpreter: "node",
    node_args: "--experimental-modules",
    env: {
      NODE_ENV: "production"
    }
  }]
};
EOL
}

# 部署功能
function deploy {
  echo_info "开始部署应用..."
  
  # 设置项目
  setup_project
  
  # 获取API凭证
  if ! get_api_credentials; then
    echo_error "获取API凭证失败"
    echo_highlight "按Enter键返回主菜单"
    read
    return 1
  fi
  
  # 创建必要的文件
  create_files
  
  # 安装依赖和启动服务
  echo_info "正在安装依赖..."
  
  # 确保在blagent目录中安装依赖
  cd "$CURRENT_DIR/blagent" || {
    echo_error "无法进入blagent目录"
    echo_highlight "按Enter键返回主菜单"
    read
    return 1
  }
  
  # 安装服务器依赖
  echo_info "安装服务器依赖..."
  npm install express dotenv node-fetch@3 || {
    echo_warning "安装服务器依赖失败，但将继续执行"
  }
  
  # 安装所有依赖
  npm install || {
    echo_warning "安装所有依赖失败，但将继续执行"
  }
  
  # 使用PM2启动服务器
  if ! command -v pm2 &> /dev/null; then
    echo_info "正在安装PM2..."
    npm install -g pm2 || {
      echo_error "安装PM2失败"
      echo_highlight "按Enter键返回主菜单"
      read
      return 1
    }
  fi
  
  # 停止已有的服务（如果存在）
  pm2 stop blagent 2>/dev/null || true
  pm2 delete blagent 2>/dev/null || true
  
  # 尝试多种方式启动服务
  echo_info "正在启动服务..."
  
  # 方法1：使用ecosystem配置文件启动PM2
  pm2 start ecosystem.config.cjs || {
    echo_warning "使用配置文件启动失败，尝试直接启动..."
    
    # 方法2：直接使用PM2启动ES模块
    pm2 start "$CURRENT_DIR/blagent/server.js" --name "blagent" --node-args="--experimental-modules" || {
      echo_warning "直接启动也失败，尝试使用备用方法..."
      
      # 方法3：使用CommonJS启动脚本
      pm2 start "$CURRENT_DIR/blagent/start.cjs" --name "blagent" || {
        echo_error "所有启动方法都失败"
        echo_highlight "按Enter键返回主菜单"
        read
        return 1
      }
    }
  }
  
  # 显示PM2状态
  pm2 status
  
  # 检查服务是否正常运行
  echo_info "检查服务是否正常运行..."
  sleep 2
  if curl -s http://localhost:3000 > /dev/null; then
    echo_success "服务器运行正常!"
  else
    echo_warning "服务器可能未正常运行，请检查PM2日志"
    pm2 logs blagent --lines 20
  fi
  
  echo_success "部署完成! 服务器运行在 http://localhost:3000"
  echo_info "如果无法访问，请运行 'pm2 logs blagent' 查看详细错误信息"
  
  echo_highlight "按Enter键返回主菜单"
  read
}

# 卸载功能
function uninstall {
  echo_info "开始卸载 blAgent 应用..."
  
  # 停止并删除PM2服务
  if command -v pm2 &> /dev/null; then
    pm2 stop blagent 2>/dev/null || true
    pm2 delete blagent 2>/dev/null || true
    echo_success "PM2服务已停止并删除"
  fi
  
  echo_highlight "是否删除所有项目文件？(y/n): "
  read delete_files
  if [ "$delete_files" = "y" ]; then
    # 删除项目目录
    echo_info "正在删除项目文件..."
    rm -rf "$CURRENT_DIR/blagent" 2>/dev/null || true
    
    # 检查是否删除成功
    if [ -d "$CURRENT_DIR/blagent" ]; then
      echo_error "警告：blagent目录仍然存在，可能需要手动删除"
    else
      echo_success "blagent目录已完全删除"
    fi
  else
    echo_info "保留项目文件"
  fi
  
  echo_success "blAgent 应用已成功卸载!"
  
  echo_highlight "按Enter键返回主菜单"
  read
}

# 显示菜单
function show_menu {
  clear
  echo_highlight "===== blAgent 部署工具 ===== v1.0"
  echo_info "1. 部署应用"
  echo_info "2. 卸载应用"
  echo_info "0. 退出脚本"
  echo -ne "${CYAN}请输入选项(0-2): ${NC}"
}

# 主循环
while true; do
  # 显示菜单
  show_menu
  
  # 读取用户选择
  read choice
  
  case $choice in
    1)
      deploy
      ;;
    2)
      uninstall
      ;;
    0)
      echo_info "退出脚本"
      exit 0
      ;;
    *)
      echo_error "无效选项"
      echo_highlight "按Enter键继续"
      read
      ;;
  esac
done