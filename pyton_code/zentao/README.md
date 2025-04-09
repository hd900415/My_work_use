# 禅道BUG监控与飞书通知脚本

这个Python脚本用于监控禅道系统中的BUG状态变更，并通过飞书机器人发送通知到群组。

## 功能特点

1. 监控禅道系统中的BUG状态变更：
   - 新创建的BUG（红色卡片通知）
   - BUG状态变更为"已确认"（状态更新通知）
   - BUG状态变更为"已解决"（绿色卡片通知）
   - BUG状态变更为"已关闭"（蓝色卡片通知）
   - 以及其他任何状态变更

2. 按产品和项目进行过滤监控
   - 必须指定产品ID（禅道API要求）
   - 可选择性指定项目ID进行过滤
   - 支持监控单个或多个产品/项目
   - 提供命令行查询产品和项目列表功能

3. 定时统计未确认的BUG
   - 每4小时统计一次未确认的BUG
   - 发送汇总通知到飞书群

4. 详细的通知内容：
   - BUG ID和标题
   - 当前状态
   - 严重程度和优先级
   - 指派人和创建人信息
   - 重现步骤
   - 禅道查看链接

## 环境要求

- Python 3.6+
- 依赖库：requests, schedule

## 安装依赖

```bash
pip install requests schedule
```

## 配置说明

在脚本中需要配置以下信息：

1. 禅道API配置：
```python
ZENTAO_API_URL = "https://zentao.pttech.cc/api.php/v1"
ZENTAO_USERNAME = "admin"  # 替换为实际用户名
ZENTAO_PASSWORD = "Admin123!@#"  # 替换为实际密码
```

2. 产品与项目ID配置：
```python
# 项目与产品ID配置
PROJECT_ID = 5  # 项目ID (可选)，例如: 5 表示只监控ID为5的"综合"项目
PRODUCT_ID = 1  # 产品ID (必需)，例如: 1 表示只监控ID为1的产品的BUG，必须设置才能获取BUG数据
```

3. 飞书机器人Webhook地址：
```python
LARK_WEBHOOK_URL = "https://open.larksuite.com/open-apis/bot/v2/hook/fe9ec7a5-f507-4c2c-abde-b53db8a430bc"
```

## 使用方法

### 获取项目和产品信息（首次使用推荐）

#### 查看项目列表
```bash
python get_bug_send_to_lark.py --list-projects
```

这将显示禅道系统中所有可用的项目及其ID。

#### 查看指定项目关联的产品列表（推荐）
```bash
python get_bug_send_to_lark.py --list-project-products 5
```

这将显示ID为5的项目关联的所有产品，这是最简单的方式来确定要监控哪些产品的BUG。

#### 查看所有产品列表
```bash
python get_bug_send_to_lark.py --list-products
```

这将显示禅道系统中所有可用的产品及其ID。

### 运行监控服务

#### 监控多个指定产品的BUG（推荐使用）
```bash
python get_bug_send_to_lark.py --product-ids 3,4,5,6
```

这将监控ID为3、4、5、6的指定多个产品的BUG状态变更，例如上述命令将监控"综合盘-B端-管理后台功能模块"、"综合盘-C端-用户端功能模块"、"综合盘-用户端-web"和"综合盘-管理后台-web模块"产品的BUG。**适合选择性监控**。

#### 发送测试通知（新增功能）
```bash
python get_bug_send_to_lark.py --product-ids 3,4,5,6 --send-test-notification
```

这个命令会立即发送一条测试通知到飞书群组，用于验证飞书机器人配置是否正常工作。发送测试通知后脚本会立即退出，不会启动监控服务。**适合验证通知功能**。

#### 监控所有产品的BUG
```bash
python get_bug_send_to_lark.py --all-products
```

这将监控禅道系统中所有产品的BUG状态变更，适用于需要全面监控的场景。

#### 自动查找项目关联的产品并监控
```bash
python get_bug_send_to_lark.py --project-id 5 --auto-find-products
```

这将自动查找ID为5的项目关联的所有产品，并监控这些产品中的BUG状态变更。**适合项目监控**。

#### 自动查找项目关联产品，找不到时监控所有产品（解决404问题）
```bash
python get_bug_send_to_lark.py --project-id 4 --auto-find-products --fallback-all-products
```

这个命令增加了`--fallback-all-products`参数，当项目没有关联任何产品时（例如出现404错误），会自动回退到监控所有产品的模式。**推荐用于可能没有关联产品的项目**。

#### 指定单个产品ID运行
```bash
python get_bug_send_to_lark.py --product-id 1
```

这将监控ID为1的产品中的所有BUG状态变更。

#### 同时指定产品ID和项目ID运行
```bash
python get_bug_send_to_lark.py --product-id 1 --project-id 5
```

这将监控ID为1的产品中且属于ID为5的项目的BUG状态变更。

### 默认运行（使用配置文件中的产品ID）

```bash
python get_bug_send_to_lark.py
```

### 推荐运行方式（后台持续运行）

使用nohup或systemd等工具使脚本持续在后台运行：

```bash
nohup python get_bug_send_to_lark.py > zentao_monitor.log 2>&1 &
```

## 日志

脚本运行时会生成两个日志文件：
- `zentao_bug_monitor.log`: 记录脚本运行的详细日志
- `zentao_bug_data.json`: 保存BUG状态数据，用于追踪状态变更

## 使用示例

### 示例1：监控多个指定产品的BUG（适合选择性监控）

1. 首先查看可用产品列表：
```bash
python get_bug_send_to_lark.py --list-products
```

输出示例：
```
正在获取禅道产品列表...

可用的产品列表:
ID      产品名称                状态
--------------------------------------------------
1       SOV交易所               normal
3       综合盘-B端-管理后台功能模块             normal
4       综合盘-C端-用户端功能模块               normal
5       综合盘-用户端-web               normal
6       综合盘-管理后台-web模块         normal
```

2. 使用product-ids参数指定多个产品：
```bash
python get_bug_send_to_lark.py --product-ids 3,4,5,6
```

输出示例：
```
将监控指定的多个产品: [3, 4, 5, 6]
禅道BUG监控服务启动...
```

### 示例2：监控所有产品的BUG

1. 直接使用--all-products参数：
```bash
python get_bug_send_to_lark.py --all-products
```

输出示例：
```
将监控所有产品的BUG，共 5 个产品: [1, 3, 4, 5, 6]
禅道BUG监控服务启动...
```

### 示例3：自动监控特定项目的BUG

1. 首先确认项目ID：
```bash
python get_bug_send_to_lark.py --list-projects
```

2. 直接使用项目ID自动查找关联产品并监控：
```bash
python get_bug_send_to_lark.py --project-id 5 --auto-find-products
```

输出示例：
```
设置项目ID为: 5
自动找到项目关联的产品ID: [1, 2, 3]
禅道BUG监控服务启动...
```

## 注意事项

1. **禅道API要求提供产品ID**才能获取BUG列表，有五种方式提供：
   - 使用`--product-ids`参数指定多个产品ID（如：`--product-ids 3,4,5,6`）
   - 使用`--all-products`监控所有产品的BUG（适合全面监控）
   - 使用`--product-id`参数手动指定单个产品
   - 使用`--project-id`和`--auto-find-products`自动查找项目关联的产品（适合项目监控）
   - 使用`--project-id`、`--auto-find-products`和`--fallback-all-products`组合，在项目没有关联产品时自动监控所有产品（最健壮的方式）
2. 可以使用`--send-test-notification`参数发送测试通知，验证飞书机器人配置是否正常
2. 确保禅道API的用户名和密码正确，且有足够的权限访问产品、项目和BUG数据
3. 飞书机器人Webhook地址需要来自已创建的飞书自定义机器人
4. 脚本使用本地文件存储状态，确保运行目录有写入权限
5. 如果需要长期运行，建议使用supervisor或systemd等工具管理，以确保程序持续运行并在崩溃后自动重启

## 故障排除

### 问题1: "未设置产品ID"或"Need product id"错误

1. 使用`--list-project-products <项目ID>`查看项目关联的产品
2. 确认项目是否有关联的产品，如果返回404或空列表，说明项目没有关联产品
3. 使用`--project-id <项目ID> --auto-find-products --fallback-all-products`参数，这样即使项目没有关联产品，也会自动回退到监控所有产品
4. 或者直接使用`--all-products`参数监控所有产品的BUG
5. 或者使用`--product-ids 3,4,5,6`参数监控指定的多个产品

### 问题2: 脚本运行但没有发送通知

1. 使用`--send-test-notification`参数测试飞书通知功能：
   ```bash
   python get_bug_send_to_lark.py --product-ids 3,4,5,6 --send-test-notification
   ```
2. 检查飞书机器人Webhook URL是否正确
3. 确认BUG已存在于禅道系统中，且状态符合通知条件（新BUG或状态变更）
4. 检查`zentao_bug_data.json`文件，确认脚本是否已经记录了BUG状态
   - 如果需要重新监控所有BUG，可以删除此文件，脚本会将所有BUG视为新发现的BUG
