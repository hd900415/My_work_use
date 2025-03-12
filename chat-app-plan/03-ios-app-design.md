# iOS应用设计

## 应用架构概述

iOS聊天应用采用Clean Architecture + MVVM架构模式，确保代码的可测试性、可维护性和可扩展性。

## 技术选型

### 主要开发语言和框架
- **语言**: Swift
- **最低支持版本**: iOS 14.0
- **UI框架**: UIKit + SwiftUI (混合使用)
- **响应式编程**: Combine

### 核心依赖库
- **网络请求**: Alamofire
- **WebSocket**: Starscream
- **JSON解析**: Swift Codable + SwiftyJSON
- **图片加载和缓存**: Kingfisher
- **本地数据库**: Realm
- **依赖注入**: Swinject
- **日志**: SwiftyBeaver
- **加密**: CryptoSwift
- **音视频处理**: AVFoundation
- **推送通知**: Firebase Cloud Messaging

## 应用架构设计

采用分层架构设计，各层职责清晰：

```
+-------------------+
|  Presentation     |
|  (MVVM + SwiftUI) |
+--------+----------+
         |
+--------v----------+
|  Domain           |
|  (Use Cases)      |
+--------+----------+
         |
+--------v----------+
|  Data             |
|  (Repositories)   |
+--------+----------+
         |
+--------v----------+
|  Network / Local  |
|  (API/DB/Cache)   |
+-------------------+
```

### 层级详解

1. **表现层 (Presentation Layer)**
   - 采用MVVM架构
   - 视图(View): UIKit/SwiftUI实现
   - 视图模型(ViewModel): 绑定视图和业务逻辑
   - 状态管理: Combine实现响应式数据流

2. **领域层 (Domain Layer)**
   - 用例(Use Cases): 实现业务逻辑
   - 实体(Entities): 核心业务模型
   - 与数据层和表现层完全解耦

3. **数据层 (Data Layer)**
   - 仓库(Repositories): 协调数据源
   - 数据源(Data Sources): 网络和本地数据获取
   - 数据映射(Mappers): 在不同层之间转换数据

4. **基础设施层 (Infrastructure Layer)**
   - 网络通信: API客户端、WebSocket
   - 本地存储: Realm数据库、UserDefaults
   - 系统服务: 推送通知、位置服务等

## 模块划分

应用按功能模块化设计，每个模块相对独立：

### 核心模块
1. **认证模块 (Authentication)**
   - 登录/注册
   - 令牌管理
   - 多设备管理

2. **会话模块 (Conversation)**
   - 会话列表
   - 最近联系人
   - 未读消息管理

3. **消息模块 (Messaging)**
   - 消息发送/接收
   - 消息渲染
   - 消息状态管理
   - 富媒体消息支持

4. **联系人模块 (Contacts)**
   - 联系人列表
   - 好友管理
   - 联系人搜索
   - 组织架构

5. **群组模块 (Groups)**
   - 群组管理
   - 群成员管理
   - 群设置

6. **个人设置模块 (Profile)**
   - 用户信息管理
   - 隐私设置
   - 消息通知设置

7. **文件管理模块 (Files)**
   - 文件上传/下载
   - 媒体文件处理
   - 缓存管理

### 辅助模块
1. **网络模块 (Networking)**
   - RESTful API客户端
   - WebSocket管理
   - 网络状态监控
   - 请求重试策略

2. **存储模块 (Storage)**
   - 本地数据库操作
   - 缓存管理
   - 文件系统管理

3. **实用工具模块 (Utilities)**
   - 日期/时间处理
   - 字符串/格式化
   - 安全工具
   - 日志

## 关键功能实现

### 1. 实时消息通信

使用WebSocket实现实时通信：

```swift
class ChatSocketManager {
    private var socket: WebSocket?
    private let serverURL = URL(string: "wss://api.example.com/ws")!
    
    func connect(token: String) {
        var request = URLRequest(url: serverURL)
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        socket = WebSocket(request: request)
        socket?.delegate = self
        socket?.connect()
    }
    
    func sendMessage(_ message: Message) {
        let encoder = JSONEncoder()
        if let data = try? encoder.encode(message) {
            socket?.write(data: data)
        }
    }
    
    // WebSocketDelegate 实现...
}
```

### 2. 消息本地存储

使用Realm进行消息持久化：

```swift
class MessageDatabase {
    private let realm = try! Realm()
    
    func saveMessage(_ message: Message) {
        let realmMessage = RealmMessage(from: message)
        try! realm.write {
            realm.add(realmMessage, update: .modified)
        }
    }
    
    func getMessages(for conversationId: String, limit: Int, before: Date?) -> [Message] {
        var query = realm.objects(RealmMessage.self)
            .filter("conversationId == %@", conversationId)
        
        if let before = before {
            query = query.filter("timestamp < %@", before)
        }
        
        return query.sorted(byKeyPath: "timestamp", ascending: false)
            .prefix(limit)
            .map { $0.toMessage() }
    }
}
```

### 3. 离线消息同步

```swift
class MessageSyncService {
    private let api: ChatAPIClient
    private let database: MessageDatabase
    
    func syncMessages() async {
        guard let lastSyncTime = UserDefaults.standard.object(forKey: "lastSyncTime") as? Date else {
            return
        }
        
        do {
            let messages = try await api.getMessages(since: lastSyncTime)
            for message in messages {
                database.saveMessage(message)
            }
            UserDefaults.standard.set(Date(), forKey: "lastSyncTime")
        } catch {
            print("Sync failed: \(error)")
        }
    }
}
```

### 4. 推送通知处理

```swift
class PushNotificationManager: NSObject, UNUserNotificationCenterDelegate {
    func registerForPushNotifications() {
        UNUserNotificationCenter.current().delegate = self
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, _ in
            guard granted else { return }
            DispatchQueue.main.async {
                UIApplication.shared.registerForRemoteNotifications()
            }
        }
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse) {
        let userInfo = response.notification.request.content.userInfo
        if let conversationId = userInfo["conversationId"] as? String {
            // 跳转到特定对话
            NavigationService.shared.navigateToConversation(id: conversationId)
        }
    }
}
```

### 5. 端到端加密实现

```swift
class E2EEncryption {
    private let keychain = KeychainSwift()
    
    func generateKeyPair() -> (publicKey: String, privateKey: String)? {
        // 使用RSA或ECC生成密钥对
        // ...
        return (publicKey, privateKey)
    }
    
    func encryptMessage(_ message: String, with publicKey: String) -> String? {
        // 使用收件人公钥加密消息
        // ...
        return encryptedMessage
    }
    
    func decryptMessage(_ encryptedMessage: String) -> String? {
        guard let privateKey = keychain.get("privateKey") else { return nil }
        // 使用自己的私钥解密消息
        // ...
        return decryptedMessage
    }
}
```

## UI设计与用户体验

### 关键界面设计

1. **聊天列表界面**
   - 最近会话列表
   - 未读消息标记
   - 会话分组(个人/群组)
   - 侧滑操作(删除/标记已读/置顶)

2. **聊天详情界面**
   - 气泡式消息布局
   - 消息类型自适应显示
   - 已读/送达状态指示
   - 长按消息操作菜单
   - 输入区域动态调整

3. **联系人界面**
   - 字母索引列表
   - 组织架构树形视图
   - 搜索功能
   - 联系人信息卡片

4. **个人设置界面**
   - 用户资料编辑
   - 通知设置
   - 安全与隐私设置
   - 通用设置

### UI主题与品牌设计

1. **设计系统**
   - 颜色系统: 主题色、辅助色、中性色等
   - 排版: 字体系列、大小、行高等
   - 间距: 标准间距规则
   - 阴影: 海拔层次系统

2. **组件库**
   - 按钮系列
   - 输入控件
   - 卡片组件
   - 列表项
   - 对话框
   - 消息气泡

3. **深色模式**
   - 自适应系统设置
   - 颜色动态调整
   - 图标与插图适配

### 交互设计亮点

1. **消息互动**
   - 消息滑动回复
   - 消息反应表情
   - 双击查看大图

2. **流畅动效**
   - 页面转场动画
   - 列表平滑滚动
   - 状态变更动效
   - 键盘平滑过渡

3. **手势操作**
   - 下拉刷新
   - 侧滑返回
   - 捏合缩放
   - 长按预览

4. **辅助功能**
   - VoiceOver支持
   - 动态字体
   - 高对比度模式
   - 减弱动效

## 性能优化

### 1. 列表性能优化

```swift
class ConversationListViewController: UIViewController {
    private lazy var tableView: UITableView = {
        let tv = UITableView()
        // 预加载单元格提高滚动性能
        tv.register(ConversationCell.self, forCellReuseIdentifier: "ConversationCell")
        // 预计算高度避免自动计算
        tv.estimatedRowHeight = 80
        // 减少离屏渲染
        tv.layer.drawsAsynchronously = true
        return tv
    }()
    
    // 实现预取数据
    func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        for indexPath in indexPaths {
            // 预取图像等资源
            let conversation = viewModel.conversations[indexPath.row]
            ImagePrefetcher.shared.prefetchImage(url: conversation.avatarUrl)
        }
    }
}
```

### 2. 图片缓存与处理

```swift
class MessageImageView: UIImageView {
    func setMessageImage(url: URL?) {
        guard let url = url else { return }
        
        // 使用Kingfisher加载并缓存图片
        kf.setImage(
            with: url,
            placeholder: UIImage(named: "image_placeholder"),
            options: [
                .processor(DownsamplingImageProcessor(size: frame.size)),
                .scaleFactor(UIScreen.main.scale),
                .transition(.fade(0.2)),
                .cacheOriginalImage
            ],
            completionHandler: nil
        )
    }
}
```

### 3. 后台任务优化

```swift
class BackgroundTaskManager {
    func scheduleMessageSync() {
        let request = BGAppRefreshTaskRequest(identifier: "com.chatapp.messagesync")
        request.earliestBeginDate = Date(timeIntervalSinceNow: 15 * 60) // 15分钟后
        
        do {
            try BGTaskScheduler.shared.submit(request)
        } catch {
            print("Could not schedule message sync: \(error)")
        }
    }
    
    func handleAppRefresh(task: BGAppRefreshTask) {
        // 创建进度追踪任务
        let syncOperation = MessageSyncOperation()
        
        // 设置任务过期处理
        task.expirationHandler = {
            syncOperation.cancel()
        }
        
        // 当同步完成时标记任务完成
        syncOperation.completionBlock = {
            task.setTaskCompleted(success: !syncOperation.isCancelled)
            self.scheduleMessageSync() // 安排下一次同步
        }
        
        // 启动同步
        OperationQueue.main.addOperation(syncOperation)
    }
}
```

### 4. 电池优化

```swift
class BatteryOptimizationManager {
    private var isLowPowerMode: Bool {
        return ProcessInfo.processInfo.isLowPowerModeEnabled
    }
    
    func applyOptimizations() {
        // 低电量模式检测
        if isLowPowerMode {
            // 减少后台刷新频率
            UserDefaults.standard.set(30, forKey: "syncIntervalMinutes")
            // 降低图片质量
            ImageCache.default.maxDiskSize = 50 * 1024 * 1024 // 50MB
            // 禁用动画
            UIView.setAnimationsEnabled(false)
        } else {
            UserDefaults.standard.set(5, forKey: "syncIntervalMinutes")
            ImageCache.default.maxDiskSize = 200 * 1024 * 1024 // 200MB
            UIView.setAnimationsEnabled(true)
        }
    }
}
```

## 安全性设计

### 1. 应用内数据安全

```swift
class SecurityManager {
    private let keychain = KeychainSwift()
    
    func secureStore(key: String, data: Data) {
        keychain.set(data, forKey: key, withAccess: .accessibleAfterFirstUnlockThisDeviceOnly)
    }
    
    func secureRetrieve(key: String) -> Data? {
        return keychain.getData(key)
    }
    
    func secureClearAll() {
        keychain.clear()
    }
    
    func setupAppProtection() {
        // 启用App Transport Security
        // 文件保护
        // 剪贴板保护
        // 屏幕保护
    }
}
```

### 2. 生物认证

```swift
class BiometricAuthenticator {
    enum BiometricType {
        case none
        case touchID
        case faceID
    }
    
    func biometricType() -> BiometricType {
        let context = LAContext()
        var error: NSError?
        
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            if #available(iOS 11.0, *) {
                switch context.biometryType {
                case .touchID:
                    return .touchID
                case .faceID:
                    return .faceID
                default:
                    return .none
                }
            } else {
                return .touchID
            }
        }
        
        return .none
    }
    
    func authenticate(completion: @escaping (Bool, Error?) -> Void) {
        let context = LAContext()
        let reason = "需要验证您的身份"
        
        context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) { success, error in
            DispatchQueue.main.async {
                completion(success, error)
            }
        }
    }
}
```

## 测试策略

### 单元测试

使用XCTest框架进行单元测试：

```swift
class MessageViewModelTests: XCTestCase {
    var viewModel: MessageViewModel!
    var mockRepository: MockMessageRepository!
    
    override func setUp() {
        super.setUp()
        mockRepository = MockMessageRepository()
        viewModel = MessageViewModel(repository: mockRepository)
    }
    
    func testSendMessage() {
        // 准备测试数据
        let message = Message(id: "test", content: "Hello", senderId: "1")
        
        // 执行被测试的功能
        viewModel.sendMessage(message)
        
        // 验证结果
        XCTAssertTrue(mockRepository.didCallSendMessage)
        XCTAssertEqual(mockRepository.lastSentMessage?.content, "Hello")
    }
}
```

### UI测试

使用XCUITest进行UI自动化测试：

```swift
class ChatUITests: XCTestCase {
    let app = XCUIApplication()
    
    override func setUp() {
        super.setUp()
        continueAfterFailure = false
        app.launch()
        
        // 登录测试账号
        let usernameField = app.textFields["usernameField"]
        usernameField.tap()
        usernameField.typeText("testuser")
        
        let passwordField = app.secureTextFields["passwordField"]
        passwordField.tap()
        passwordField.typeText("password")
        
        app.buttons["loginButton"].tap()
    }
    
    func testSendMessage() {
        // 打开第一个会话
        app.tables["conversationList"].cells.element(boundBy: 0).tap()
        
        // 发送消息
        let messageField = app.textFields["messageField"]
        messageField.tap()
        messageField.typeText("Hello, UI Test!")
        
        app.buttons["sendButton"].tap()
        
        // 验证消息发送成功
        XCTAssertTrue(app.staticTexts["Hello, UI Test!"].exists)
    }
}
```

## 发布与部署

### 1. 持续集成流程

使用Fastlane自动化构建和测试：

```ruby
# Fastfile
lane :test do
  run_tests(
    scheme: "ChatApp",
    devices: ["iPhone 14"],
    clean: true
  )
end

lane :beta do
  # 增加构建号
  increment_build_number

  # 执行测试
  test

  # 打包应用
  build_app(
    scheme: "ChatApp",
    configuration: "Release",
    export_method: "app-store"
  )

  # 上传到TestFlight
  upload_to_testflight
  
  # 通知团队
  slack(message: "新的Beta版本已上传到TestFlight!")
end
```

### 2. App Store发布准备

- App Store截图准备
- App审核指南符合性检查
- 隐私政策和用户协议
- 应用元数据准备
- 应用内购买配置(如有)

### 3. 灰度发布策略

- TestFlight内部测试
- 小范围外部测试
- 按地区分批发布
- 新版本功能开关控制

## 后续迭代规划

### 1. 功能拓展规划

- 语音和视频通话
- 自定义表情包
- 多设备同步
- 更丰富的消息类型
- 群直播功能

### 2. 技术升级规划

- Swift Concurrency完全迁移
- SwiftUI界面逐步迁移
- AI辅助功能整合
- AR互动消息支持
- 性能度量系统建设
