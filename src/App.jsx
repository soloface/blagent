import { useState, useEffect, useRef } from 'react'
import './App.css'
import ReactMarkdown from 'react-markdown'
import remarkGfm from 'remark-gfm'
import { CustomTable, CustomThead, CustomTbody, CustomTr, CustomTh, CustomTd } from './components/CustomTable.jsx'

function App() {
  const [userInput, setUserInput] = useState('')
  const [messages, setMessages] = useState([])
  const [loading, setLoading] = useState(false)
  const [typingMessage, setTypingMessage] = useState('') // 用于逐字显示
  const [isTyping, setIsTyping] = useState(false) // 是否正在打字
  const [fullTypingMessage, setFullTypingMessage] = useState('') // 完整的待输出消息
  const messagesEndRef = useRef(null)
  const typingIntervalRef = useRef(null)

  // 自动滚动到底部
  const scrollToBottom = () => {
    messagesEndRef.current?.scrollIntoView({ behavior: 'smooth' })
  }

  useEffect(() => {
    scrollToBottom()
  }, [messages, typingMessage])

  // 逐字显示函数
  const typeMessage = (fullMessage) => {
    setIsTyping(true)
    setTypingMessage('')
    setFullTypingMessage(fullMessage)
    let currentIndex = 0
    
    const typeInterval = setInterval(() => {
      if (currentIndex < fullMessage.length) {
        setTypingMessage(fullMessage.substring(0, currentIndex + 1))
        currentIndex++
      } else {
        clearInterval(typeInterval)
        setIsTyping(false)
        // 打字完成后，将消息添加到正式消息列表
        setMessages(prev => [...prev, { role: 'assistant', content: fullMessage }])
        setTypingMessage('')
        setFullTypingMessage('')
      }
    }, 30) // 每30毫秒显示一个字符
    
    typingIntervalRef.current = typeInterval
  }

  // 清理定时器
  useEffect(() => {
    return () => {
      if (typingIntervalRef.current) {
        clearInterval(typingIntervalRef.current)
      }
    }
  }, [])

  const handleSubmit = async (e) => {
    e.preventDefault()
    if (!userInput.trim() || loading || isTyping) return

    // 添加用户消息到对话
    const userMessage = { role: 'user', content: userInput }
    setMessages([...messages, userMessage])
    setLoading(true)
    
    try {
      // 调用后端API
      const response = await fetch('/api/chat', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
        },
        body: JSON.stringify({
          message: userInput
        }),
      })

      if (!response.ok) {
        throw new Error(`HTTP错误: ${response.status}`)
      }

      const contentType = response.headers.get('content-type')
      if (!contentType || !contentType.includes('application/json')) {
        const text = await response.text()
        throw new Error(`服务器返回非JSON响应: ${text}`)
      }

      const data = await response.json()
      
      if (data.error) {
        throw new Error(data.error)
      }
      
      setLoading(false)
      // 开始逐字显示AI回复
      typeMessage(data.response)
      
    } catch (error) {
      console.error('详细错误信息:', error)
      setMessages(prev => [...prev, { 
        role: 'system', 
        content: `请求出错: ${error.message}` 
      }])
      setLoading(false)
    } finally {
      setUserInput('')
    }
  }

  return (
    <div className="chat-container">
      <h1 className="app-title">壹唯视智能助手</h1>
      
      <div className="messages-container">
        {messages.length === 0 && !isTyping && (
          <div className="welcome-message">
            <p>欢迎使用壹唯视Agent测试界面！</p>
            <p>请在下方输入框中输入您的问题。</p>
          </div>
        )}
        {messages.map((msg, index) => (
          <div key={index} className={`message ${msg.role}`}>
            <div className="message-role">{msg.role === 'user' ? '您' : msg.role === 'assistant' ? 'AI' : '系统'}</div>
            <div className="message-content">
              <ReactMarkdown
                remarkPlugins={[remarkGfm]}
                components={{
                  table: CustomTable,
                  thead: CustomThead,
                  tbody: CustomTbody,
                  tr: CustomTr,
                  th: CustomTh,
                  td: CustomTd,
                }}
              >
                {msg.content}
              </ReactMarkdown>
            </div>
          </div>
        ))}
        
        {/* 正在思考的动画 */}
        {loading && (
          <div className="message system">
            <div className="thinking-animation">
              <span className="thinking-text">正在思考</span>
              <div className="thinking-dots">
                <span className="dot">.</span>
                <span className="dot">.</span>
                <span className="dot">.</span>
              </div>
            </div>
          </div>
        )}
        
        {/* 逐字显示的消息 - 使用纯文本确保光标跟随 */}
        {isTyping && (
          <div className="message assistant typing">
            <div className="message-role">AI</div>
            <div className="message-content">
              <div className="typing-wrapper">
                <span className="typing-text">{typingMessage}</span>
                <span className="typing-cursor">|</span>
              </div>
            </div>
          </div>
        )}
        
        <div ref={messagesEndRef} />
      </div>

      <form onSubmit={handleSubmit} className="input-form">
        <input
          type="text"
          value={userInput}
          onChange={(e) => setUserInput(e.target.value)}
          placeholder="输入你的问题..."
          disabled={loading || isTyping}
        />
        <button type="submit" disabled={loading || isTyping}>
          发送
        </button>
      </form>
    </div>
  )
}

export default App
