# Web应用设计

## 架构概述

聊天软件的Web应用采用现代前端技术栈，使用组件化架构设计，支持响应式布局，确保在桌面和移动设备上都能提供出色的用户体验。

## 技术选型

### 核心技术栈
- **框架**: React (使用Next.js框架)
- **类型系统**: TypeScript
- **状态管理**: Redux Toolkit + React Query
- **UI组件库**: Ant Design
- **样式解决方案**: Tailwind CSS + Styled Components
- **构建工具**: Webpack (通过Next.js集成)
- **包管理器**: pnpm

### 关键依赖库
- **网络请求**: axios
- **WebSocket**: socket.io-client
- **表单处理**: Formik + Yup
- **国际化**: i18next
- **日期处理**: Day.js
- **图表库**: ECharts (用于管理统计)
- **富文本编辑**: Draft.js
- **音视频处理**: simple-peer

## 项目结构

```
/
├── public/                  # 静态资源
│   ├── fonts/               # 字体文件
│   ├── images/              # 图片资源
│   └── locales/             # 国际化文件
│
├── src/
│   ├── api/                 # API请求模块
│   │   ├── auth.ts          # 认证相关API
│   │   ├── chat.ts          # 聊天相关API
│   │   ├── user.ts          # 用户相关API
│   │   └── index.ts         # API入口
│   │
│   ├── components/          # 公共组件
│   │   ├── common/          # 通用组件
│   │   ├── layout/          # 布局组件
│   │   ├── chat/            # 聊天相关组件
│   │   └── user/            # 用户相关组件
│   │
│   ├── hooks/               # 自定义React Hooks
│   │
│   ├── pages/               # 页面组件(Next.js)
│   │   ├── _app.tsx         # 应用入口
│   │   ├── index.tsx        # 首页
│   │   ├── login.tsx        # 登录页
│   │   ├── register.tsx     # 注册页
│   │   ├── chat/            # 聊天相关页面
│   │   └── settings/        # 设置相关页面
│   │
│   ├── store/               # Redux状态管理
│   │   ├── slices/          # Redux切片
│   │   └── index.ts         # Store配置
│   │
│   ├── services/            # 业务服务
│   │   ├── auth.service.ts  # 认证服务
│   │   ├── chat.service.ts  # 聊天服务
│   │   └── socket.service.ts # WebSocket服务
│   │
│   ├── styles/              # 全局样式
│   │
│   ├── types/               # TypeScript类型定义
│   │
│   └── utils/               # 工具函数
│
├── next.config.js           # Next.js配置
├── tailwind.config.js       # Tailwind配置
├── tsconfig.json            # TypeScript配置
└── package.json             # 项目依赖
```

## 状态管理设计

### Redux Store结构

使用Redux Toolkit组织状态管理，主要分为以下几个Slice:

```typescript
// auth slice
interface AuthState {
  isAuthenticated: boolean;
  user: User | null;
  token: string | null;
  loading: boolean;
  error: string | null;
}

// conversations slice
interface ConversationsState {
  activeConversationId: string | null;
  conversations: Conversation[];
  loading: boolean;
  error: string | null;
}

// messages slice
interface MessagesState {
  byConversationId: Record<string, Message[]>;
  loadingMessages: Record<string, boolean>;
  sendingMessages: Record<string, boolean>;
  error: string | null;
}

// contacts slice
interface ContactsState {
  contacts: Contact[];
  onlineStatuses: Record<string, 'online' | 'offline' | 'away' | 'busy'>;
  loading: boolean;
  error: string | null;
}

// ui slice
interface UIState {
  sidebarOpen: boolean;
  currentTheme: 'light' | 'dark' | 'system';
  notificationPermission: 'granted' | 'denied' | 'default';
  activeModal: string | null;
  mobileView: boolean;
}
```

### React Query 使用

使用React Query处理数据获取、缓存和更新:

```typescript
// 获取会话列表
const useConversations = () => {
  return useQuery('conversations', () => 
    chatApi.getConversations(), {
      staleTime: 60000, // 1分钟内不重新获取
      onSuccess: (data) => {
        dispatch(conversationsActions.setConversations(data));
      }
    }
  );
};

// 获取特定会话的消息
const useMessages = (conversationId: string) => {
  return useQuery(
    ['messages', conversationId], 
    () => chatApi.getMessages(conversationId),
    {
      enabled: !!conversationId,
      keepPreviousData: true,
      onSuccess: (data) => {
        dispatch(messagesActions.setMessages({ 
          conversationId, 
          messages: data 
        }));
      }
    }
  );
};
```

## 组件设计

### 关键组件

#### 1. ConversationList - 会话列表

```tsx
const ConversationList: React.FC = () => {
  const conversations = useSelector(selectConversations);
  const activeId = useSelector(selectActiveConversationId);
  const dispatch = useDispatch();
  
  const handleConversationClick = (id: string) => {
    dispatch(conversationsActions.setActiveConversation(id));
  };
  
  return (
    <div className="conversation-list">
      <div className="header">
        <h2>会话</h2>
        <Button 
          icon={<PlusOutlined />} 
          onClick={() => dispatch(uiActions.openModal('newConversation'))} 
        />
      </div>
      
      <Input.Search placeholder="搜索会话" />
      
      <div className="list">
        {conversations.map(conv => (
          <ConversationItem 
            key={conv.id}
            conversation={conv}
            isActive={conv.id === activeId}
            onClick={() => handleConversationClick(conv.id)}
          />
        ))}
      </div>
    </div>
  );
};
```

#### 2. MessageList - 消息列表

```tsx
const MessageList: React.FC<{ conversationId: string }> = ({ conversationId }) => {
  const messages = useSelector(state => selectMessagesByConversationId(state, conversationId));
  const listRef = useRef<HTMLDivElement>(null);
  
  // 新消息到来时滚动到底部
  useEffect(() => {
    if (listRef.current) {
      listRef.current.scrollTop = listRef.current.scrollHeight;
    }
  }, [messages.length]);
  
  return (
    <div className="message-list" ref={listRef}>
      {messages.map(message => (
        <MessageItem 
          key={message.id}
          message={message}
          isMine={message.senderId === currentUserId}
        />
      ))}
    </div>
  );
};
```

#### 3. ChatInput - 聊天输入框

```tsx
const ChatInput: React.FC<{ conversationId: string }> = ({ conversationId }) => {
  const [message, setMessage] = useState('');
  const [isRecording, setIsRecording] = useState(false);
  const dispatch = useDispatch();
  
  const handleSendMessage = () => {
    if (!message.trim()) return;
    
    dispatch(messagesActions.sendMessage({
      conversationId,
      content: message,
      type: 'text'
    }));
    
    setMessage('');
  };
  
  return (
    <div className="chat-input">
      <div className="toolbar">
        <Button icon={<SmileOutlined />} />
        <Button icon={<PaperClipOutlined />} />
        <Button 
          icon={<AudioOutlined />}
          type={isRecording ? 'primary' : 'default'}
          onClick={() => setIsRecording(!isRecording)}
        />
      </div>
      
      <Input.TextArea
        value={message}
        onChange={e => setMessage(e.target.value)}
        placeholder="输入消息..."
        autoSize={{ minRows: 1, maxRows: 6 }}
        onPressEnter={(e) => {
          if (!e.shiftKey) {
            e.preventDefault();
            handleSendMessage();
          }
        }}
      />
      
      <Button 
        type="primary" 
        icon={<SendOutlined />} 
        onClick={handleSendMessage}
      />
    </div>
  );
};
```

## WebSocket通信设计

### WebSocket服务封装

```typescript
class SocketService {
  private socket: Socket | null = null;
  private reconnectAttempts = 0;
  private maxReconnectAttempts = 5;
  
  connect(token: string) {
    this.socket = io(process.env.NEXT_PUBLIC_WS_URL!, {
      auth: { token },
      transports: ['websocket'],
      reconnection: true,
      reconnectionDelay: 1000,
      reconnectionAttempts: this.maxReconnectAttempts
    });
    
    this.setupEventListeners();
  }
  
  private setupEventListeners() {
    if (!this.socket) return;
    
    this.socket.on('connect', this.handleConnect);
    this.socket.on('disconnect', this.handleDisconnect);
    this.socket.on('error', this.handleError);
    this.socket.on('message', this.handleMessage);
    this.socket.on('status', this.handleStatusUpdate);
  }
  
  private handleConnect = () => {
    console.log('WebSocket connected');
    this.reconnectAttempts = 0;
    store.dispatch(authActions.setConnectionStatus('connected'));
  };
  
  private handleDisconnect = (reason: string) => {
    console.log(`WebSocket disconnected: ${reason}`);
    store.dispatch(authActions.setConnectionStatus('disconnected'));
  };
  
  private handleError = (error: any) => {
    console.error('WebSocket error:', error);
  };
  
  private handleMessage = (data: any) => {
    const { type, payload } = data;
    
    switch (type) {
      case 'NEW_MESSAGE':
        store.dispatch(messagesActions.addMessage(payload));
        this.sendAcknowledgment(payload.id);
        break;
      case 'MESSAGE_STATUS_CHANGED':
        store.dispatch(messagesActions.updateMessageStatus(payload));
        break;
      // 处理其他消息类型...
    }
  };
  
  private handleStatusUpdate = (data: any) => {
    const { userId, status } = data;
    store.dispatch(contactsActions.updateContactStatus({ userId, status }));
  };
  
  sendMessage(message: any) {
    if (this.socket?.connected) {
      this.socket.emit('message', message);
    } else {
      console.error('Cannot send message: Socket not connected');
      // 可以将消息保存到待发送队列
    }
  }
  
  sendAcknowledgment(messageId: string) {
    if (this.socket?.connected) {
      this.socket.emit('ack', { messageId });
    }
  }
  
  disconnect() {
    if (this.socket) {
      this.socket.disconnect();
      this.socket = null;
    }
  }
}

export const socketService = new SocketService();
```

### 消息发送流程

```typescript
// 在Redux中处理消息发送
const sendMessageThunk = createAsyncThunk(
  'messages/send',
  async (messageData: { conversationId: string; content: string; type: string }, { getState }) => {
    const state = getState() as RootState;
    const { user } = state.auth;
    
    if (!user) throw new Error('User not authenticated');
    
    const tempId = `temp-${Date.now()}`;
    const message: Message = {
      id: tempId,
      conversationId: messageData.conversationId,
      senderId: user.id,
      content: messageData.content,
      type: messageData.type,
      status: 'sending',
      timestamp: new Date().toISOString()
    };
    
    // 先乐观更新UI
    dispatch(messagesActions.addMessage(message));
    
    try {
      // 通过WebSocket发送
      socketService.sendMessage({
        type: 'SEND_MESSAGE',
        payload: message
      });
      
      // 等待确认或超时
      return new Promise((resolve, reject) => {
        const timeout = setTimeout(() => {
          reject(new Error('Message sending timeout'));
        }, 5000);
        
        const unsubscribe = store.subscribe(() => {
          const newState = store.getState() as RootState;
          const updatedMessage = newState.messages.byConversationId[message.conversationId]?.find(
            m => m.id === tempId || m.tempId === tempId
          );
          
          if (updatedMessage && updatedMessage.status !== 'sending') {
            clearTimeout(timeout);
            unsubscribe();
            resolve(updatedMessage);
          }
        });
      });
    } catch (error) {
      // 更新消息状态为发送失败
      dispatch(messagesActions.updateMessageStatus({
        conversationId: message.conversationId,
        messageId: tempId,
        status: 'failed'
      }));
      throw error;
    }
  }
);
```

## 离线支持与数据同步

### IndexedDB 存储设计

使用Dexie.js作为IndexedDB的封装:

```typescript
import Dexie from 'dexie';

export class ChatDatabase extends Dexie {
  conversations: Dexie.Table<Conversation, string>;
  messages: Dexie.Table<Message, string>;
  contacts: Dexie.Table<Contact, string>;
  
  constructor() {
    super('ChatAppDB');
    
    this.version(1).stores({
      conversations: 'id, lastMessageTime',
      messages: 'id, conversationId, timestamp, status, [conversationId+timestamp]',
      contacts: 'id, name'
    });
    
    this.conversations = this.table('conversations');
    this.messages = this.table('messages');
    this.contacts = this.table('contacts');
  }
  
  async getConversations() {
    return this.conversations.orderBy('lastMessageTime').reverse().toArray();
  }
  
  async getMessages(conversationId: string, limit: number = 50) {
    return this.messages
      .where('conversationId')
      .equals(conversationId)
      .reverse()
      .sortBy('timestamp');
  }
  
  async saveMessage(message: Message) {
    return this.messages.put(message);
  }
  
  async getUnsentMessages() {
    return this.messages.where('status').equals('failed').toArray();
  }
}

export const db = new ChatDatabase();
```

### 离线消息队列

```typescript
class OfflineManager {
  private isOnline = navigator.onLine;
  private pendingMessages: Message[] = [];
  
  constructor() {
    window.addEventListener('online', this.handleOnline);
    window.addEventListener('offline', this.handleOffline);
    this.loadUnsentMessages();
  }
  
  private handleOnline = () => {
    this.isOnline = true;
    store.dispatch(uiActions.setNetworkStatus('online'));
    this.processPendingMessages();
  };
  
  private handleOffline = () => {
    this.isOnline = false;
    store.dispatch(uiActions.setNetworkStatus('offline'));
  };
  
  private async loadUnsentMessages() {
    this.pendingMessages = await db.getUnsentMessages();
  }
  
  queueMessage(message: Message) {
    this.pendingMessages.push(message);
    db.saveMessage({ ...message, status: 'failed' });
    
    if (this.isOnline) {
      this.processPendingMessages();
    }
  }
  
  private async processPendingMessages() {
    if (!this.isOnline || this.pendingMessages.length === 0) {
      return;
    }
    
    // 复制并清空队列，防止重复处理
    const messagesToSend = [...this.pendingMessages];
    this.pendingMessages = [];
    
    for (const message of messagesToSend) {
      try {
        socketService.sendMessage({
          type: 'SEND_MESSAGE',
          payload: message
        });
        
        // 更新本地数据库中的消息状态
        await db.saveMessage({ ...message, status: 'sending' });
      } catch (error) {
        console.error('Failed to send message:', error);
        this.pendingMessages.push(message);
      }
    }
  }
}

export const offlineManager = new OfflineManager();
```

## 响应式设计

### 使用布局组件实现响应式

```tsx
const ChatLayout: React.FC<{ children: React.ReactNode }> = ({ children }) => {
  const isMobile = useMediaQuery({ maxWidth: 768 });
  const sidebarOpen = useSelector(selectSidebarOpen);
  const dispatch = useDispatch();
  
  useEffect(() => {
    dispatch(uiActions.setMobileView(isMobile));
    
    // 在移动设备上，默认关闭侧边栏
    if (isMobile && sidebarOpen) {
      dispatch(uiActions.closeSidebar());
    }
  }, [isMobile, dispatch]);
  
  return (
    <div className="chat-layout">
      <aside className={`sidebar ${sidebarOpen ? 'open' : 'closed'}`}>
        <ConversationList />
      </aside>
      
      <main className="main-content">
        {isMobile && (
          <Button 
            className="sidebar-toggle"
            icon={<MenuOutlined />}
            onClick={() => dispatch(uiActions.toggleSidebar())}
          />
        )}
        
        {children}
      </main>
    </div>
  );
};
```

### 响应式样式

使用Tailwind和CSS变量实现:

```css
:root {
  --sidebar-width: 320px;
  --header-height: 60px;
  --footer-height: 80px;
}

@media (max-width: 768px) {
  :root {
    --sidebar-width: 100%;
  }
}

.chat-layout {
  display: flex;
  height: 100vh;
}

.sidebar {
  width: var(--sidebar-width);
  transition: transform 0.3s ease;
}

@media (max-width: 768px) {
  .sidebar {
    position: fixed;
    z-index: 10;
    transform: translateX(-100%);
  }
  
  .sidebar.open {
    transform: translateX(0);
  }
}

.main-content {
  flex: 1;
  display: flex;
  flex-direction: column;
}

.message-list {
  flex: 1;
  overflow-y: auto;
  padding: 1rem;
}

.chat-input {
  height: var(--footer-height);
  border-top: 1px solid var(--border-color);
  padding: 0.5rem 1rem;
}
```

## 主题与定制化

### 主题设计系统

```typescript
// themes.ts
export const lightTheme = {
  colors: {
    primary: '#1890ff',
    secondary: '#722ed1',
    background: '#ffffff',
    surface: '#f0f2f5',
    text: '#000000',
    textSecondary: '#595959',
    border: '#d9d9d9',
    divider: '#f0f0f0',
    error: '#ff4d4f',
    success: '#52c41a',
    warning: '#faad14'
  },
  shadows: {
    sm: '0 1px 2px 0 rgba(0, 0, 0, 0.05)',
    md: '0 4px 6px -1px rgba(0, 0, 0, 0.1)',
    lg: '0 10px 15px -3px rgba(0, 0, 0, 0.1)'
  },
  radii: {
    sm: '2px',
    md: '4px',
    lg: '8px',
    xl: '12px',
    full: '9999px'
  }
};

export const darkTheme = {
  colors: {
    primary: '#177ddc',
    secondary: '#722ed1',
    background: '#1f1f1f',
    surface: '#2d2d2d',
    text: '#ffffff',
    textSecondary: '#a6a6a6',
    border: '#434343',
    divider: '#303030',
    error: '#ff4d4f',
    success: '#52c41a',
    warning: '#faad14'
  },
  shadows: {
    sm: '0 1px 2px 0 rgba(0, 0, 0, 0.5)',
    md: '0 4px 6px -1px rgba(0, 0, 0, 0.6)',
    lg: '0 10px 15px -3px rgba(0, 0, 0, 0.7)'
  },
  radii: {
    sm: '2px',
    md: '4px',
    lg: '8px',
    xl: '12px',
    full: '9999px'
  }
};
```

### 主题切换组件

```tsx
const ThemeProvider: React.FC<{ children: React.ReactNode }> = ({ children }) => {
  const { theme } = useSelector(selectUiState);
  const dispatch = useDispatch();
  
  // 检测系统主题
  useEffect(() => {
    const mediaQuery = window.matchMedia('(prefers-color-scheme: dark)');
    
    const handleChange = (e: MediaQueryListEvent) => {
      if (theme === 'system') {
        document.documentElement.setAttribute(
          'data-theme', 
          e.matches ? 'dark' : 'light'
        );
      }
    };
    
    mediaQuery.addEventListener('change', handleChange);
    return () => mediaQuery.removeEventListener('change', handleChange);
  }, [theme]);
  
  // 设置当前主题
  useEffect(() => {
    const themeValue = theme === 'system'
      ? window.matchMedia('(prefers-color-scheme: dark)').matches
        ? 'dark'
        : 'light'
      : theme;
      
    document.documentElement.setAttribute('data-theme', themeValue);
  }, [theme]);
  
  const changeTheme = (newTheme: 'light' | 'dark' | 'system') => {
    dispatch(uiActions.setTheme(newTheme));
    localStorage.setItem('theme', newTheme);
  };
  
  return (
    <ThemeContext.Provider value={{ 
      theme, 
      changeTheme,
      currentTheme: theme === 'system'
        ? window.matchMedia('(prefers-color-scheme: dark)').matches
          ? darkTheme
          : lightTheme
        : theme === 'dark'
          ? darkTheme
          : lightTheme
    }}>
      {children}
    </ThemeContext.Provider>
  );
};
```

## 性能优化策略

### 虚拟滚动列表

使用react-window实现长列表的高效渲染:

```tsx
import { FixedSizeList } from 'react-window';
import AutoSizer from 'react-virtualized-auto-sizer';

const VirtualizedMessageList: React.FC<{ 
  messages: Message[];
  loadMoreMessages: () => void;
}> = ({ messages, loadMoreMessages }) => {
  const listRef = useRef<FixedSizeList>(null);
  
  // 监听滚动位置，滚动到顶部时加载更多消息
  const handleScroll = ({ scrollOffset }: { scrollOffset: number }) => {
    if (scrollOffset < 100) {
      loadMoreMessages();
    }
  };
  
  // 新消息到来时滚动到底部
  useEffect(() => {
    if (listRef.current) {
      listRef.current.scrollToItem(messages.length - 1);
    }
  }, [messages.length]);
  
  return (
    <div className="message-list-container">
      <AutoSizer>
        {({ height, width }) => (
          <FixedSizeList
            ref={listRef}
            height={height}
            width={width}
            itemCount={messages.length}
            itemSize={80} // 估计的单条消息高度
            onScroll={handleScroll}
          >
            {({ index, style }) => (
              <div style={style}>
                <MessageItem 
                  message={messages[index]}
                  isMine={messages[index].senderId === currentUserId}
                />
              </div>
            )}
          </FixedSizeList>
        )}
      </AutoSizer>
    </div>
  );
};
```

### 组件懒加载

使用Next.js的dynamic import和React.lazy:

```tsx
// 页面级懒加载
const ChatPage = dynamic(() => import('../components/pages/ChatPage'), {
  loading: () => <LoadingSpinner />,
  ssr: false // 禁用服务端渲染，因为聊天页需要客户端功能
});

// 组件级懒加载
const EmojiPicker = React.lazy(() => import('../components/common/EmojiPicker'));

// 使用Suspense包裹懒加载组件
const ChatInput: React.FC = () => {
  const [showEmojiPicker, setShowEmojiPicker] = useState(false);
  
  return (
    <div className="chat-input">
      {/* 其他输入元素 */}
      
      {showEmojiPicker && (
        <Suspense fallback={<div>Loading...</div>}>
          <EmojiPicker onEmojiSelect={handleEmojiSelect} />
        </Suspense>
      )}
    </div>
  );
};
```

### 缓存优化

使用SWR/React Query的缓存策略:

```typescript
// 缓存配置
const queryClient = new QueryClient({
  defaultOptions: {
    queries: {
      staleTime: 5 * 60 * 1000, // 5分钟
      cacheTime: 30 * 60 * 1000, // 30分钟
      refetchOnWindowFocus: false,
      retry: 1
    }
  }
});

// 针对不同数据类型的缓存策略
const useConversations = (options = {}) => {
  return useQuery('conversations', chatApi.getConversations, {
    staleTime: 60 * 1000, // 1分钟
    ...options
  });
};

const useMessages = (conversationId: string, options = {}) => {
  return useQuery(
    ['messages', conversationId], 
    () => chatApi.getMessages(conversationId),
    {
      staleTime: 30 * 1000, // 30秒
      enabled: !!conversationId,
      ...options
    }
  );
};

const useUserProfile = (userId: string, options = {}) => {
  return useQuery(
    ['user', userId], 
    () => userApi.getUserProfile(userId),
    {
      staleTime: 30 * 60 * 1000, // 30分钟
      ...options
    }
  );
};
```

## 测试策略

### 单元测试

使用Jest和Testing Library:

```tsx
// components/MessageItem.test.tsx
import { render, screen } from '@testing-library/react';
import MessageItem from './MessageItem';

describe('MessageItem', () => {
  const mockMessage = {
    id: '1',
    conversationId: 'conv1',
    senderId: 'sender1',
    content: 'Hello, world!',
    type: 'text',
    status: 'sent',
    timestamp: '2023-01-01T12:00:00Z'
  };
  
  it('renders the message content', () => {
    render(<MessageItem message={mockMessage} isMine={false} />);
    expect(screen.getByText('Hello, world!')).toBeInTheDocument();
  });
  
  it('applies correct style for own messages', () => {
    const { container } = render(<MessageItem message={mockMessage} isMine={true} />);
    expect(container.firstChild).toHaveClass('message-mine');
  });
  
  it('displays sent status icon', () => {
    render(<MessageItem message={mockMessage} isMine={true} />);
    expect(screen.getByTestId('status-icon-sent')).toBeInTheDocument();
  });
});
```

### 集成测试

使用
