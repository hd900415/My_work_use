# 数据库设计

## 概述

聊天软件的数据库设计分为多个部分，主要使用MySQL存储结构化数据，Redis用于缓存和实时数据，Elasticsearch用于消息搜索，MinIO/S3用于文件存储。

## MySQL数据库表设计

### 用户系统

#### 1. users - 用户表

```sql
CREATE TABLE users (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    username VARCHAR(50) NOT NULL UNIQUE,
    password VARCHAR(255) NOT NULL, -- 加密存储
    nickname VARCHAR(50),
    avatar_url VARCHAR(255),
    email VARCHAR(100) UNIQUE,
    phone VARCHAR(20) UNIQUE,
    status TINYINT DEFAULT 0, -- 0: 离线, 1: 在线, 2: 忙碌, 3: 离开
    last_active_time DATETIME,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    deleted_at DATETIME,
    INDEX idx_username (username),
    INDEX idx_email (email),
    INDEX idx_phone (phone)
);
```

#### 2. user_profiles - 用户详细资料

```sql
CREATE TABLE user_profiles (
    user_id BIGINT PRIMARY KEY,
    real_name VARCHAR(100),
    gender TINYINT, -- 0: 未知, 1: 男, 2: 女
    birthday DATE,
    bio TEXT,
    location VARCHAR(100),
    company VARCHAR(100),
    position VARCHAR(100),
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);
```

#### 3. organizations - 组织/企业表

```sql
CREATE TABLE organizations (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100) NOT NULL,
    description TEXT,
    logo_url VARCHAR(255),
    owner_id BIGINT NOT NULL,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    deleted_at DATETIME,
    FOREIGN KEY (owner_id) REFERENCES users(id)
);
```

#### 4. departments - 部门表

```sql
CREATE TABLE departments (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    org_id BIGINT NOT NULL,
    name VARCHAR(100) NOT NULL,
    parent_id BIGINT,
    leader_id BIGINT,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    deleted_at DATETIME,
    FOREIGN KEY (org_id) REFERENCES organizations(id) ON DELETE CASCADE,
    FOREIGN KEY (parent_id) REFERENCES departments(id),
    FOREIGN KEY (leader_id) REFERENCES users(id),
    INDEX idx_org_id (org_id)
);
```

#### 5. org_members - 组织成员关联表

```sql
CREATE TABLE org_members (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    org_id BIGINT NOT NULL,
    user_id BIGINT NOT NULL,
    dept_id BIGINT,
    role VARCHAR(50) NOT NULL, -- 'admin', 'member'
    employee_id VARCHAR(50),
    job_title VARCHAR(100),
    joined_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (org_id) REFERENCES organizations(id) ON DELETE CASCADE,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (dept_id) REFERENCES departments(id),
    UNIQUE KEY unique_org_user (org_id, user_id),
    INDEX idx_user_id (user_id)
);
```

### 联系人与好友系统

#### 6. contacts - 联系人/好友关系表

```sql
CREATE TABLE contacts (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    user_id BIGINT NOT NULL,
    contact_id BIGINT NOT NULL,
    remark VARCHAR(50),
    relation_type TINYINT NOT NULL DEFAULT 0, -- 0: 单向关注, 1: 好友, 2: 黑名单
    group_id BIGINT, -- 好友分组
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (contact_id) REFERENCES users(id) ON DELETE CASCADE,
    UNIQUE KEY unique_user_contact (user_id, contact_id),
    INDEX idx_user_id (user_id),
    INDEX idx_contact_id (contact_id)
);
```

#### 7. contact_groups - 联系人分组表

```sql
CREATE TABLE contact_groups (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    user_id BIGINT NOT NULL,
    name VARCHAR(50) NOT NULL,
    sort_order INT NOT NULL DEFAULT 0,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    INDEX idx_user_id (user_id)
);
```

#### 8. friend_requests - 好友请求表

```sql
CREATE TABLE friend_requests (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    from_user_id BIGINT NOT NULL,
    to_user_id BIGINT NOT NULL,
    message VARCHAR(255),
    status TINYINT NOT NULL DEFAULT 0, -- 0: 待处理, 1: 已接受, 2: 已拒绝
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (from_user_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (to_user_id) REFERENCES users(id) ON DELETE CASCADE,
    INDEX idx_from_user (from_user_id),
    INDEX idx_to_user (to_user_id)
);
```

### 聊天与消息系统

#### 9. conversations - 会话表

```sql
CREATE TABLE conversations (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    type TINYINT NOT NULL, -- 0: 单聊, 1: 群聊
    created_by BIGINT NOT NULL,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    last_message_id BIGINT,
    last_message_time DATETIME,
    deleted_at DATETIME,
    FOREIGN KEY (created_by) REFERENCES users(id)
);
```

#### 10. conversation_users - 会话成员表

```sql
CREATE TABLE conversation_users (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    conversation_id BIGINT NOT NULL,
    user_id BIGINT NOT NULL,
    role VARCHAR(20) NOT NULL DEFAULT 'member', -- 'owner', 'admin', 'member'
    nickname VARCHAR(50),
    mute BOOLEAN NOT NULL DEFAULT FALSE,
    last_read_message_id BIGINT,
    join_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (conversation_id) REFERENCES conversations(id) ON DELETE CASCADE,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    UNIQUE KEY unique_conv_user (conversation_id, user_id),
    INDEX idx_user_id (user_id)
);
```

#### 11. groups - 群组表

```sql
CREATE TABLE groups (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    conversation_id BIGINT NOT NULL UNIQUE,
    name VARCHAR(100) NOT NULL,
    description TEXT,
    avatar_url VARCHAR(255),
    owner_id BIGINT NOT NULL,
    max_members INT NOT NULL DEFAULT 200,
    join_mode TINYINT NOT NULL DEFAULT 0, -- 0: 需要审批, 1: 自由加入, 2: 仅邀请
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    deleted_at DATETIME,
    FOREIGN KEY (conversation_id) REFERENCES conversations(id) ON DELETE CASCADE,
    FOREIGN KEY (owner_id) REFERENCES users(id),
    INDEX idx_name (name)
);
```

#### 12. messages - 消息表

```sql
CREATE TABLE messages (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    conversation_id BIGINT NOT NULL,
    sender_id BIGINT NOT NULL,
    reply_to_id BIGINT,
    type TINYINT NOT NULL, -- 0: 文本, 1: 图片, 2: 语音, 3: 视频, 4: 文件, 5: 位置, 6: 系统消息
    content TEXT, -- 文本内容或媒体文件的URL
    extra JSON, -- 扩展字段，存储媒体文件的元信息等
    send_time DATETIME NOT NULL,
    status TINYINT NOT NULL DEFAULT 0, -- 0: 发送中, 1: 已发送, 2: 已送达, 3: 已读, -1: 发送失败
    is_recalled BOOLEAN NOT NULL DEFAULT FALSE,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (conversation_id) REFERENCES conversations(id) ON DELETE CASCADE,
    FOREIGN KEY (sender_id) REFERENCES users(id),
    FOREIGN KEY (reply_to_id) REFERENCES messages(id),
    INDEX idx_conversation_time (conversation_id, send_time),
    INDEX idx_sender_id (sender_id)
);
```

#### 13. message_reads - 消息已读表

```sql
CREATE TABLE message_reads (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    message_id BIGINT NOT NULL,
    user_id BIGINT NOT NULL,
    read_time DATETIME NOT NULL,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (message_id) REFERENCES messages(id) ON DELETE CASCADE,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    UNIQUE KEY unique_message_user (message_id, user_id),
    INDEX idx_user_id (user_id)
);
```

### 授权与权限系统

#### 14. roles - 角色表

```sql
CREATE TABLE roles (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(50) NOT NULL UNIQUE,
    description VARCHAR(255),
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);
```

#### 15. permissions - 权限表

```sql
CREATE TABLE permissions (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(50) NOT NULL UNIQUE,
    description VARCHAR(255),
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);
```

#### 16. role_permissions - 角色权限关联表

```sql
CREATE TABLE role_permissions (
    role_id BIGINT NOT NULL,
    permission_id BIGINT NOT NULL,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (role_id, permission_id),
    FOREIGN KEY (role_id) REFERENCES roles(id) ON DELETE CASCADE,
    FOREIGN KEY (permission_id) REFERENCES permissions(id) ON DELETE CASCADE
);
```

#### 17. user_roles - 用户角色关联表

```sql
CREATE TABLE user_roles (
    user_id BIGINT NOT NULL,
    role_id BIGINT NOT NULL,
    org_id BIGINT, -- 可选，用于组织内的角色
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (user_id, role_id, org_id),
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (role_id) REFERENCES roles(id) ON DELETE CASCADE,
    FOREIGN KEY (org_id) REFERENCES organizations(id) ON DELETE CASCADE
);
```

## Redis 数据结构设计

1. **用户在线状态**
   ```
   user:status:{user_id} -> 状态值 (0: 离线, 1: 在线, 2: 忙碌, 3: 离开)
   ```

2. **用户token存储**
   ```
   user:token:{token} -> user_id
   user:tokens:{user_id} -> Set of tokens
   ```

3. **消息ID生成器**
   ```
   msg:id:counter -> 自增ID
   ```

4. **最近会话列表**
   ```
   user:recent_conversations:{user_id} -> Sorted Set(conversation_id, timestamp)
   ```

5. **未读消息计数**
   ```
   user:unread:{user_id}:{conversation_id} -> 未读消息数
   ```

6. **消息推送队列**
   ```
   msg:push:queue -> List of message IDs to push
   ```

7. **用户在线设备**
   ```
   user:devices:{user_id} -> Set of device_tokens
   ```

8. **限流计数器**
   ```
   ratelimit:{resource}:{user_id} -> 计数器
   ```

## Elasticsearch 索引设计

### messages 索引 - 用于消息搜索

```json
{
  "settings": {
    "number_of_shards": 5,
    "number_of_replicas": 1
  },
  "mappings": {
    "properties": {
      "id": { "type": "long" },
      "conversation_id": { "type": "long" },
      "sender_id": { "type": "long" },
      "sender_name": { "type": "keyword" },
      "content": { "type": "text", "analyzer": "standard" },
      "type": { "type": "byte" },
      "send_time": { "type": "date" },
      "is_recalled": { "type": "boolean" },
      "file_name": { "type": "text" },
      "file_type": { "type": "keyword" }
    }
  }
}
```

## MinIO/S3 存储桶设计

1. **avatars** - 用户头像和群组头像
2. **images** - 图片消息
3. **voices** - 语音消息
4. **videos** - 视频消息
5. **files** - 文件消息
6. **thumbnails** - 图片和视频缩略图

## 数据备份策略

1. **MySQL数据库**
   - 每日全量备份
   - 实时主从复制
   - 定期备份校验

2. **Redis数据**
   - AOF持久化
   - RDB定时快照
   - 主从复制

3. **MinIO/S3文件**
   - 跨区域复制
   - 多版本控制

4. **Elasticsearch**
   - 索引快照备份
