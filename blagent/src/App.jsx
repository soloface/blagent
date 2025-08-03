import { useState } from 'react'
import './App.css'

function App() {
  const [userInput, setUserInput] = useState('')
  const [messages, setMessages] = useState([])
  const [loading, setLoading] = useState(false)

  const handleSubmit = async (e) => {
    e.preventDefault()
    if (!userInput.trim()) return

    // 添加用户消息到对话
    const userMessage = { role: 'user', content: userInput }
    setMessages([...messages, userMessage])
    setLoading(true)
    
    try {
      // 调用后端API，后端会使用环境变量中的API密钥和应用ID
      const response = await fetch('/api/chat', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
        },
        body: JSON.stringify({
          message: userInput
        }),
      })

      const data = await response.json()
      
      if (data.error) {
        throw new Error(data.error)
      }
      
      // 添加AI回复到对话
      setMessages(prev => [...prev, { role: 'assistant', content: data.response }])
    } catch (error) {
      console.error('Error:', error)
      setMessages(prev => [...prev, { 
        role: 'system', 
        content: `请求出错: ${error.message}` 
      }])
    } finally {
      setLoading(false)
      setUserInput('')
    }
  }

  return (
    <div className="chat-container">
      <h1 className="app-title">壹唯视 Agent 测试界面</h1>
      
      <div className="messages-container">
        {messages.length === 0 && (
          <div className="welcome-message">
            <p>欢迎使用壹唯视Agent测试界面！</p>
            <p>请在下方输入框中输入您的问题。</p>
          </div>
        )}
        {messages.map((msg, index) => (
          <div key={index} className={`message ${msg.role}`}>
            <div className="message-role">{msg.role === 'user' ? '您' : msg.role === 'assistant' ? 'AI' : '系统'}</div>
            <div className="message-content">{msg.content}</div>
          </div>
        ))}
        {loading && <div className="message system">正在思考...</div>}
      </div>

      <form onSubmit={handleSubmit} className="input-form">
        <input
          type="text"
          value={userInput}
          onChange={(e) => setUserInput(e.target.value)}
          placeholder="输入你的问题..."
          disabled={loading}
        />
        <button type="submit" disabled={loading}>
          发送
        </button>
      </form>
    </div>
  )
}

export default App
