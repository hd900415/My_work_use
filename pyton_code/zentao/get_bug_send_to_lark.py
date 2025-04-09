#!/usr/bin/env python3
# -*- coding: utf-8 -*-

import requests
import json
import time
import datetime
import logging
import os
import schedule
from typing import Dict, List, Any, Optional

# 配置日志
# 确保使用UTF-8编码保存日志文件
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s',
    handlers=[
        logging.FileHandler("zentao_bug_monitor.log", encoding='utf-8'),
        logging.StreamHandler()
    ]
)
logger = logging.getLogger("zentao_bug_monitor")

# 解决Windows控制台输出中文问题
import sys
if sys.platform == 'win32':
    import codecs
    sys.stdout = codecs.getwriter('utf-8')(sys.stdout.buffer)
    sys.stderr = codecs.getwriter('utf-8')(sys.stderr.buffer)

# 禅道API配置
ZENTAO_API_URL = "https://zentao.pttech.cc/api.php/v1"
ZENTAO_USERNAME = "admin"  # 替换为实际用户名
ZENTAO_PASSWORD = "Admin123!@#"  # 替换为实际密码

# 项目与产品ID配置
PROJECT_ID = 5  # 项目ID (可选)，例如: 5 表示只监控ID为5的"综合"项目
PRODUCT_ID = None  # 产品ID (必需)，例如: 1 表示只监控ID为1的产品的BUG，必须设置才能获取BUG数据

# 飞书机器人配置
LARK_WEBHOOK_URL = "https://open.larksuite.com/open-apis/bot/v2/hook/fe9ec7a5-f507-4c2c-abde-b53db8a430bc"

# 状态映射表
BUG_STATUS_MAP = {
    "active": "激活",
    "resolved": "已解决",
    "closed": "已关闭",
    "wait_for_confirming": "待确认"
}

# BUG状态变更通知颜色
BUG_STATUS_COLOR = {
    "active": "red",
    "resolved": "green",
    "closed": "blue",
    "wait_for_confirming": "yellow"
}

# 数据存储文件，用于记录已处理过的BUG状态
DATA_FILE = "zentao_bug_data.json"

class ZentaoBugMonitor:
    def __init__(self):
        self.session_token = None
        self.bugs_data = self._load_bugs_data()
        self.last_summary_time = time.time()

    def _load_bugs_data(self) -> Dict[str, Dict]:
        """
        加载已保存的BUG数据
        """
        if os.path.exists(DATA_FILE):
            try:
                with open(DATA_FILE, 'r', encoding='utf-8') as f:
                    return json.load(f)
            except Exception as e:
                logger.error(f"加载BUG数据文件失败: {e}")
                return {}
        return {}

    def _save_bugs_data(self):
        """
        保存BUG数据到文件
        """
        try:
            with open(DATA_FILE, 'w', encoding='utf-8') as f:
                json.dump(self.bugs_data, f, ensure_ascii=False, indent=2)
        except Exception as e:
            logger.error(f"保存BUG数据文件失败: {e}")

    def login(self) -> bool:
        """
        登录禅道API获取会话令牌
        """
        try:
            login_url = f"{ZENTAO_API_URL}/tokens"
            headers = {"Content-Type": "application/json"}
            data = {
                "account": ZENTAO_USERNAME,
                "password": ZENTAO_PASSWORD
            }
            
            response = requests.post(login_url, headers=headers, json=data)
            if response.status_code == 201:
                result = response.json()
                self.session_token = result.get("token")
                logger.info("禅道API登录成功")
                return True
            else:
                logger.error(f"禅道API登录失败，状态码: {response.status_code}，响应: {response.text}")
                return False
        except Exception as e:
            logger.error(f"禅道API登录异常: {e}")
            return False

    def get_projects(self) -> List[Dict]:
        """
        获取禅道系统中的项目列表
        """
        if not self.session_token:
            if not self.login():
                return []
        
        try:
            projects_url = f"{ZENTAO_API_URL}/projects"
            headers = {
                "Content-Type": "application/json",
                "Token": self.session_token
            }
            
            response = requests.get(projects_url, headers=headers)
            if response.status_code == 200:
                result = response.json()
                logger.info(f"成功获取到 {len(result.get('projects', []))} 个项目")
                return result.get("projects", [])
            else:
                logger.error(f"获取项目列表失败，状态码: {response.status_code}，响应: {response.text}")
                # 如果是认证问题，尝试重新登录
                if response.status_code == 401:
                    logger.info("尝试重新登录...")
                    if self.login():
                        return self.get_projects()
                return []
        except Exception as e:
            logger.error(f"获取项目列表异常: {e}")
            return []
    
    def get_products(self, project_id=None) -> List[Dict]:
        """
        获取禅道系统中的产品列表
        如果提供了project_id，则获取与该项目关联的产品
        """
        if not self.session_token:
            if not self.login():
                return []
        
        try:
            # 如果指定了项目ID，则获取该项目关联的产品
            if project_id is not None:
                project_products_url = f"{ZENTAO_API_URL}/projects/{project_id}/products"
                headers = {
                    "Content-Type": "application/json",
                    "Token": self.session_token
                }
                
                response = requests.get(project_products_url, headers=headers)
                if response.status_code == 200:
                    result = response.json()
                    logger.info(f"成功获取到项目ID={project_id}关联的 {len(result.get('products', []))} 个产品")
                    return result.get("products", [])
                else:
                    logger.error(f"获取项目关联产品列表失败，状态码: {response.status_code}，响应: {response.text}")
                    if response.status_code == 401:
                        logger.info("尝试重新登录...")
                        if self.login():
                            return self.get_products(project_id)
                    return []
            else:
                # 获取所有产品
                products_url = f"{ZENTAO_API_URL}/products"
                headers = {
                    "Content-Type": "application/json",
                    "Token": self.session_token
                }
                
                response = requests.get(products_url, headers=headers)
                if response.status_code == 200:
                    result = response.json()
                    logger.info(f"成功获取到 {len(result.get('products', []))} 个产品")
                    return result.get("products", [])
                else:
                    logger.error(f"获取产品列表失败，状态码: {response.status_code}，响应: {response.text}")
                    # 如果是认证问题，尝试重新登录
                    if response.status_code == 401:
                        logger.info("尝试重新登录...")
                        if self.login():
                            return self.get_products()
                    return []
        except Exception as e:
            logger.error(f"获取产品列表异常: {e}")
            return []
            
    def find_products_by_project_id(self, project_id: int) -> List[int]:
        """
        根据项目ID查找关联的产品ID列表
        """
        products = self.get_products(project_id)
        product_ids = [product.get('id') for product in products if product.get('id')]
        return product_ids

    def get_bugs(self) -> List[Dict]:
        """
        获取禅道系统中的BUG列表
        """
        if not self.session_token:
            if not self.login():
                return []
        
        try:
            # 构建请求URL
            bugs_url = f"{ZENTAO_API_URL}/bugs"
            
            # 参数设置
            params = {}
            
            # 产品ID是必需的
            global PRODUCT_ID
            if PRODUCT_ID is None:
                logger.error("未设置产品ID，禅道API要求必须提供产品ID")
                return []
            
            # 设置产品ID
            if isinstance(PRODUCT_ID, list):
                params['product'] = ','.join(map(str, PRODUCT_ID))
                logger.info(f"正在获取产品ID为 {params['product']} 的BUG列表")
            else:
                params['product'] = str(PRODUCT_ID)
                logger.info(f"正在获取产品ID为 {params['product']} 的BUG列表")
            
            # 可选：设置项目ID
            if PROJECT_ID is not None:
                if isinstance(PROJECT_ID, list):
                    params['project'] = ','.join(map(str, PROJECT_ID))
                    logger.info(f"过滤项目ID为 {params['project']}")
                else:
                    params['project'] = str(PROJECT_ID)
                    logger.info(f"过滤项目ID为 {params['project']}")
            
            headers = {
                "Content-Type": "application/json",
                "Token": self.session_token
            }
            
            response = requests.get(bugs_url, headers=headers, params=params)
            if response.status_code == 200:
                result = response.json()
                bugs = result.get("bugs", [])
                logger.info(f"成功获取到 {len(bugs)} 个BUG")
                return bugs
            else:
                logger.error(f"获取BUG列表失败，状态码: {response.status_code}，响应: {response.text}")
                # 如果是认证问题，尝试重新登录
                if response.status_code == 401:
                    logger.info("尝试重新登录...")
                    if self.login():
                        return self.get_bugs()
                return []
        except Exception as e:
            logger.error(f"获取BUG列表异常: {e}")
            return []

    def get_bug_details(self, bug_id: int) -> Optional[Dict]:
        """
        获取单个BUG的详细信息
        """
        if not self.session_token:
            if not self.login():
                return None
        
        try:
            bug_url = f"{ZENTAO_API_URL}/bugs/{bug_id}"
            headers = {
                "Content-Type": "application/json",
                "Token": self.session_token
            }
            
            response = requests.get(bug_url, headers=headers)
            if response.status_code == 200:
                result = response.json()
                return result.get("bug")
            else:
                logger.error(f"获取BUG详情失败，ID: {bug_id}，状态码: {response.status_code}，响应: {response.text}")
                # 如果是认证问题，尝试重新登录
                if response.status_code == 401:
                    logger.info("尝试重新登录...")
                    if self.login():
                        return self.get_bug_details(bug_id)
                return None
        except Exception as e:
            logger.error(f"获取BUG详情异常: {e}")
            return None

    def send_lark_message(self, title: str, content: List[Dict], color: str = "") -> bool:
        """
        发送消息到飞书群
        """
        try:
            message = {
                "msg_type": "interactive",
                "card": {
                    "config": {
                        "wide_screen_mode": True
                    },
                    "header": {
                        "title": {
                            "tag": "plain_text",
                            "content": title
                        },
                        "template": color or "blue"
                    },
                    "elements": content
                }
            }
            
            headers = {"Content-Type": "application/json"}
            response = requests.post(LARK_WEBHOOK_URL, headers=headers, data=json.dumps(message))
            
            if response.status_code == 200:
                result = response.json()
                if result.get("code") == 0:
                    logger.info(f"飞书消息发送成功: {title}")
                    return True
                else:
                    logger.error(f"飞书消息发送失败: {result}")
            else:
                logger.error(f"飞书消息发送失败，状态码: {response.status_code}，响应: {response.text}")
            
            return False
        except Exception as e:
            logger.error(f"飞书消息发送异常: {e}")
            return False

    def format_bug_card_content(self, bug: Dict) -> List[Dict]:
        """
        格式化BUG卡片内容
        """
        bug_id = bug.get("id", "未知")
        bug_title = bug.get("title", "未知标题")
        bug_status = bug.get("status", "未知")
        bug_severity = bug.get("severity", "3")
        bug_priority = bug.get("pri", "3")
        bug_assignedTo = bug.get("assignedTo", "未分配")
        bug_openedBy = bug.get("openedBy", "未知")
        bug_openedDate = bug.get("openedDate", "未知")
        bug_steps = bug.get("steps", "未提供")
        
        # 移除HTML标签
        import re
        if bug_steps:
            bug_steps = re.sub(r'<[^>]+>', '', bug_steps)
        
        # 严重程度和优先级的映射
        severity_map = {
            "1": "1 - 致命",
            "2": "2 - 严重",
            "3": "3 - 一般",
            "4": "4 - 轻微"
        }
        
        priority_map = {
            "1": "1 - 紧急",
            "2": "2 - 高",
            "3": "3 - 中",
            "4": "4 - 低"
        }
        
        # 创建卡片内容
        content = [
            {
                "tag": "div",
                "text": {
                    "tag": "lark_md",
                    "content": f"**BUG ID:** {bug_id}\n**标题:** {bug_title}\n**状态:** {BUG_STATUS_MAP.get(bug_status, bug_status)}\n**严重程度:** {severity_map.get(bug_severity, bug_severity)}\n**优先级:** {priority_map.get(bug_priority, bug_priority)}\n**指派给:** {bug_assignedTo}\n**创建人:** {bug_openedBy}\n**创建时间:** {bug_openedDate}"
                }
            },
            {
                "tag": "hr"
            },
            {
                "tag": "div",
                "text": {
                    "tag": "lark_md",
                    "content": f"**重现步骤:**\n{bug_steps[:1000] + '...' if len(bug_steps) > 1000 else bug_steps}"
                }
            },
            {
                "tag": "hr"
            },
            {
                "tag": "div",
                "text": {
                    "tag": "lark_md",
                    "content": f"[在禅道中查看](https://zentao.pttech.cc/bug-view-{bug_id}.html)"
                }
            }
        ]
        
        return content

    def check_bug_updates(self):
        """
        检查BUG更新状态并发送通知
        """
        logger.info("开始检查BUG更新...")
        bugs = self.get_bugs()
        
        if not bugs:
            logger.warning("获取BUG列表为空或失败")
            return
        
        for bug_summary in bugs:
            bug_id = bug_summary.get("id")
            if not bug_id:
                continue
            
            bug_detail = self.get_bug_details(bug_id)
            if not bug_detail:
                continue
            
            # 获取BUG状态
            current_status = bug_detail.get("status")
            if not current_status:
                continue
            
            bug_key = str(bug_id)
            
            # 检查是否为新BUG
            if bug_key not in self.bugs_data:
                # 新BUG
                logger.info(f"发现新BUG: ID-{bug_id}, 标题-{bug_detail.get('title')}")
                
                # 发送飞书通知
                title = f"🐞 发现新BUG #{bug_id}: {bug_detail.get('title', '未知标题')}"
                content = self.format_bug_card_content(bug_detail)
                self.send_lark_message(title, content, "red")
                
                # 保存BUG数据
                self.bugs_data[bug_key] = {
                    "id": bug_id,
                    "title": bug_detail.get("title", ""),
                    "status": current_status,
                    "last_update": time.time()
                }
            else:
                # 检查状态变更
                old_status = self.bugs_data[bug_key].get("status")
                if old_status != current_status:
                    logger.info(f"BUG状态变更: ID-{bug_id}, 标题-{bug_detail.get('title')}, 旧状态-{old_status}, 新状态-{current_status}")
                    
                    # 发送飞书通知
                    status_text = BUG_STATUS_MAP.get(current_status, current_status)
                    title = f"🔄 BUG #{bug_id} 状态更新: {status_text}"
                    content = self.format_bug_card_content(bug_detail)
                    
                    # 根据不同状态使用不同颜色
                    color = BUG_STATUS_COLOR.get(current_status, "blue")
                    self.send_lark_message(title, content, color)
                    
                    # 更新数据
                    self.bugs_data[bug_key]["status"] = current_status
                    self.bugs_data[bug_key]["last_update"] = time.time()
        
        # 保存数据
        self._save_bugs_data()
        logger.info("BUG检查完成")

    def summary_unconfirmed_bugs(self):
        """
        统计未确认的BUG并发送通知
        """
        logger.info("开始统计未确认BUG...")
        bugs = self.get_bugs()
        
        if not bugs:
            logger.warning("获取BUG列表为空或失败")
            return
        
        unconfirmed_bugs = []
        
        for bug_summary in bugs:
            bug_id = bug_summary.get("id")
            if not bug_id:
                continue
            
            bug_detail = self.get_bug_details(bug_id)
            if not bug_detail:
                continue
            
            # 筛选未确认的BUG
            if bug_detail.get("status") == "wait_for_confirming":
                unconfirmed_bugs.append(bug_detail)
        
        # 如果有未确认的BUG，发送通知
        if unconfirmed_bugs:
            now = datetime.datetime.now().strftime("%Y-%m-%d %H:%M:%S")
            title = f"⚠️ 未确认BUG统计 ({now})"
            
            # 创建消息内容
            content = [
                {
                    "tag": "div",
                    "text": {
                        "tag": "lark_md",
                        "content": f"**当前有 {len(unconfirmed_bugs)} 个BUG等待确认:**"
                    }
                },
                {
                    "tag": "hr"
                }
            ]
            
            # 添加BUG列表
            for bug in unconfirmed_bugs:
                content.append({
                    "tag": "div",
                    "text": {
                        "tag": "lark_md",
                        "content": f"• **BUG #{bug.get('id')}:** {bug.get('title')} (指派给: {bug.get('assignedTo')})"
                    }
                })
            
            # 发送通知
            self.send_lark_message(title, content, "yellow")
            
            logger.info(f"已发送未确认BUG统计通知，共{len(unconfirmed_bugs)}个")
        else:
            logger.info("没有未确认的BUG，无需发送统计通知")

    def run_forever(self):
        """
        持续运行监控程序
        """
        logger.info("禅道BUG监控服务启动...")
        
        # 登录并初始化
        if not self.login():
            logger.error("初始化登录失败，请检查配置")
            return
        
        # 首次立即检查一次
        self.check_bug_updates()
        
        # 设置定时任务，每5分钟检查一次BUG状态
        schedule.every(5).minutes.do(self.check_bug_updates)
        
        # 设置定时任务，每4小时统计一次未确认的BUG
        schedule.every(4).hours.do(self.summary_unconfirmed_bugs)
        
        # 运行循环
        try:
            while True:
                schedule.run_pending()
                time.sleep(1)
        except KeyboardInterrupt:
            logger.info("服务已停止")
        except Exception as e:
            logger.error(f"服务异常: {e}")

def main():
    # 设置中文环境
    import locale
    locale.setlocale(locale.LC_ALL, 'zh_CN.UTF-8')
    
    # 命令行参数处理
    import argparse
    parser = argparse.ArgumentParser(description='禅道BUG监控和飞书通知脚本')
    parser.add_argument('--list-projects', action='store_true', help='列出所有可用的项目')
    parser.add_argument('--list-products', action='store_true', help='列出所有可用的产品')
    parser.add_argument('--list-project-products', type=int, help='列出指定项目关联的产品')
    parser.add_argument('--project-id', type=int, help='指定要监控的项目ID')
    parser.add_argument('--product-id', type=int, help='指定要监控的单个产品ID')
    parser.add_argument('--product-ids', type=str, help='指定要监控的多个产品ID，以逗号分隔，例如：3,4,5,6')
    parser.add_argument('--auto-find-products', action='store_true', help='自动查找项目关联的产品，当指定了--project-id但未指定--product-id时生效')
    parser.add_argument('--all-products', action='store_true', help='监控所有产品的BUG，忽略项目ID过滤')
    parser.add_argument('--fallback-all-products', action='store_true', help='当项目未关联产品时，自动监控所有产品')
    parser.add_argument('--send-test-notification', action='store_true', help='发送测试通知消息，验证飞书机器人配置')
    args = parser.parse_args()
    
    monitor = ZentaoBugMonitor()
    
    # 如果指定了列出项目参数
    if args.list_projects:
        print("正在获取禅道项目列表...")
        if monitor.login():
            projects = monitor.get_projects()
            if projects:
                print("\n可用的项目列表:")
                print("ID\t项目名称\t\t状态")
                print("-" * 50)
                for project in projects:
                    print(f"{project.get('id')}\t{project.get('name')}\t\t{project.get('status')}")
                print("\n使用方式: python get_bug_send_to_lark.py --project-id <项目ID> --auto-find-products")
                print("或者: python get_bug_send_to_lark.py --list-project-products <项目ID>")
            else:
                print("未找到任何项目或获取项目列表失败")
        else:
            print("登录失败，请检查用户名和密码")
        return
    
    # 如果指定了列出产品参数
    if args.list_products:
        print("正在获取禅道产品列表...")
        if monitor.login():
            products = monitor.get_products()
            if products:
                print("\n可用的产品列表:")
                print("ID\t产品名称\t\t状态")
                print("-" * 50)
                for product in products:
                    print(f"{product.get('id')}\t{product.get('name')}\t\t{product.get('status')}")
                print("\n使用方式: python get_bug_send_to_lark.py --product-id <产品ID> [--project-id <项目ID>]")
            else:
                print("未找到任何产品或获取产品列表失败")
        else:
            print("登录失败，请检查用户名和密码")
        return
    
    # 如果指定了列出项目关联产品参数
    if args.list_project_products:
        print(f"正在获取项目ID={args.list_project_products}关联的产品列表...")
        if monitor.login():
            products = monitor.get_products(args.list_project_products)
            if products:
                print(f"\n项目ID={args.list_project_products}关联的产品列表:")
                print("ID\t产品名称\t\t状态")
                print("-" * 50)
                for product in products:
                    print(f"{product.get('id')}\t{product.get('name')}\t\t{product.get('status')}")
                print("\n使用方式: python get_bug_send_to_lark.py --product-id <产品ID> --project-id <项目ID>")
            else:
                print(f"未找到项目ID={args.list_project_products}关联的任何产品")
        else:
            print("登录失败，请检查用户名和密码")
        return
    
    # 处理项目ID和产品ID参数
    global PROJECT_ID, PRODUCT_ID
    
    # 处理多个产品ID
    if args.product_ids:
        try:
            # 将逗号分隔的ID字符串转换为整数列表
            product_ids_list = [int(pid.strip()) for pid in args.product_ids.split(',')]
            PRODUCT_ID = product_ids_list
            print(f"将监控指定的多个产品: {PRODUCT_ID}")
        except ValueError:
            print("错误: 产品ID列表格式不正确，应为逗号分隔的数字，例如: 3,4,5,6")
            return
    # 监控所有产品
    elif args.all_products:
        if monitor.login():
            products = monitor.get_products()
            if products:
                PRODUCT_ID = [product.get('id') for product in products if product.get('id')]
                print(f"将监控所有产品的BUG，共 {len(PRODUCT_ID)} 个产品: {PRODUCT_ID}")
            else:
                print("警告: 未找到任何产品，请检查禅道系统配置")
                return
        else:
            print("登录失败，请检查用户名和密码")
            return
    elif args.project_id:
        PROJECT_ID = args.project_id
        print(f"设置项目ID为: {PROJECT_ID}")
        
        # 如果指定了自动查找产品且没有明确指定产品ID
        if args.auto_find_products and not args.product_id:
            if monitor.login():
                product_ids = monitor.find_products_by_project_id(PROJECT_ID)
                if product_ids:
                    PRODUCT_ID = product_ids  # 可以是一个列表，包含多个产品ID
                    print(f"自动找到项目关联的产品ID: {PRODUCT_ID}")
                else:
                    print(f"警告: 未能找到项目ID={PROJECT_ID}关联的产品")
                    # 如果设置了回退选项，则获取所有产品
                    if args.fallback_all_products:
                        print("启用回退模式: 将监控所有产品")
                        all_products = monitor.get_products()
                        if all_products:
                            PRODUCT_ID = [product.get('id') for product in all_products if product.get('id')]
                            print(f"已回退到监控所有产品: {PRODUCT_ID}")
                        else:
                            print("无法获取产品列表，请检查禅道配置")
                            return
            else:
                print("登录失败，请检查用户名和密码")
                return
    
    if args.product_id and not args.product_ids:  # 避免与product_ids冲突
        PRODUCT_ID = args.product_id
        print(f"设置产品ID为: {PRODUCT_ID}")
    
    # 检查产品ID是否设置
    if PRODUCT_ID is None:
        print("错误: 必须指定产品ID或使用 --auto-find-products 参数。")
        print("禅道API要求提供产品ID才能获取BUG列表。")
        print("使用 --product-id 参数指定产品ID，或使用 --list-products 查看可用的产品列表。")
        print("也可以使用 --project-id <项目ID> --auto-find-products 自动查找项目关联的产品。")
        return
    
    # 如果需要发送测试通知
    if args.send_test_notification:
        print("正在发送测试通知...")
        if monitor.login():
            # 发送一条测试通知
            test_content = [
                {
                    "tag": "div",
                    "text": {
                        "tag": "lark_md",
                        "content": f"**测试通知**\n\n这是一条测试消息，用于验证禅道BUG监控系统的飞书通知功能是否正常工作。\n\n当前监控的产品ID: {PRODUCT_ID}\n当前项目ID: {PROJECT_ID}\n\n时间: {datetime.datetime.now().strftime('%Y-%m-%d %H:%M:%S')}"
                    }
                }
            ]
            result = monitor.send_lark_message("🔔 禅道BUG监控系统测试通知", test_content, "green")
            if result:
                print("测试通知发送成功！请检查飞书群组是否收到消息。")
            else:
                print("测试通知发送失败，请检查飞书机器人配置。")
        else:
            print("登录失败，无法发送测试通知")
        return

    # 运行监控服务
    monitor.run_forever()

if __name__ == "__main__":
    main()
