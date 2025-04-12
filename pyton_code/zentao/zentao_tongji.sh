#!/bin/sh

# 定义 MySQL 用户名、密码和数据库
HOST="zentao-db"     #可以为远程数据库地址
USER="root"
PASSWORD="pass4Zentao"
DATABASE="zentao"    #禅道数据库就叫这名

# 查询bug激活总数
SQL_COMMAND1="SELECT CONCAT(p.name, '：', u.realname, '-', COUNT(b.id), ',') AS '现未解决bug总数：\\\\n'
    FROM zt_user u
             INNER JOIN zt_bug b ON b.assignedto = u.account
             INNER JOIN zt_product p ON p.id = b.product
    WHERE u.type = 'inside'   #内部员工
      #and u.role = 'dev'       #研发
      AND b.status = 'active' #bug状态：激活
      AND b.deleted = '0'     #未删除
      AND p.status = 'normal' #项目状态：正常
    GROUP BY u.realname,
             p.name
    ORDER BY p.name, COUNT(b.id) DESC;"

# 查询P1的bug数
SQL_COMMAND2="SELECT CONCAT(p.name, '：', u.realname, '-', COUNT(b.id), ',') AS '【p1】bug数：\\\\n'
    FROM zt_user u
             INNER JOIN zt_bug b ON b.assignedto = u.account
             INNER JOIN zt_product p ON p.id = b.product
    WHERE u.type = 'inside'   #内部员工
      #and u.role = 'dev'       #研发
      AND b.status = 'active' #bug状态：激活
      AND b.severity = 1      #严重等级：P1
      AND b.deleted = '0'     #未删除
      AND p.status = 'normal' #项目状态：正常
    GROUP BY u.realname,
             p.name
    ORDER BY p.name, COUNT(b.id) DESC;"

# 查询昨日已解决BUG总数
SQL_COMMAND3="SELECT CONCAT(p.name, '：', u.realname, '-已解决：', COUNT(b.id), ',') AS '---昨日已解决---\\\\n'
    FROM zt_user u
             INNER JOIN zt_bug b ON b.resolvedby = u.account
             INNER JOIN zt_product p ON p.id = b.product
    WHERE u.type = 'inside'                  #内部员工
      #AND u.role = 'dev' #研发
      AND b.status IN ('resolved', 'closed') #bug 状态为已解决或已关闭
      AND b.deleted = '0'                    #未删除
      AND p.status = 'normal'                #项目状态：正常
      AND b.resolveddate >= CURDATE() - INTERVAL 1 DAY
      AND b.resolveddate < CURDATE()         #限定为昨日已解决数据
    GROUP BY u.realname,
             p.name
    ORDER BY p.name,
             COUNT(b.id) DESC;"

# 使用 mysql 命令执行 SQL 并获取结果
RESULT1=$(/opt/zbox/bin/mysql -h $HOST -u $USER -p$PASSWORD $DATABASE -e "$SQL_COMMAND1")
RESULT2=$(/opt/zbox/bin/mysql -h $HOST -u $USER -p$PASSWORD $DATABASE -e "$SQL_COMMAND2")
RESULT3=$(/opt/zbox/bin/mysql -h $HOST -u $USER -p$PASSWORD $DATABASE -e "$SQL_COMMAND3")

echo $RESULT1 > /tmp/totalBugs
echo $RESULT2 > /tmp/p1Bugs
echo $RESULT3 > /tmp/resolvedBugs

# 打印结果
cat /tmp/totalBugs
echo
cat /tmp/p1Bugs
echo
cat /tmp/resolvedBugs

#部门群
CURL_URL='https://qyapi.weixin.qq.com/cgi-bin/webhook/send?key=yyy'
#测试一下
#CURL_URL='https://qyapi.weixin.qq.com/cgi-bin/webhook/send?key=xxx'

#推送群机器人消息
push_webhook_msg() {
	currentDate=`date +%Y-%m-%d`
	totalBugs=`perl -pe 's/,/\\\\n/g' /tmp/totalBugs`
	echo totalBugs=$totalBugs
	p1Bugs=`perl -pe 's/,/\\\\n/g' /tmp/p1Bugs`
	echo p1Bugs=$p1Bugs
	resolvedBugs=`perl -pe 's/,/\\\\n/g' /tmp/resolvedBugs`
	echo resolvedBugs=$resolvedBugs

	if [[ -z "$totalBugs" && -z "$p1Bugs" ]]; then
	    CURL_DATA="{\"msgtype\": \"text\", \"text\": {\"content\": \"截止$currentDate >> bug统计：\\n  今日无遗留BUG。\\n\\n $resolvedBugs \", \"mentioned_list\":[\"@all\"]}}"
	else
	    CURL_DATA="{\"msgtype\": \"text\", \"text\": {\"content\": \"截止$currentDate >> bug统计：\\n  $totalBugs \\n $p1Bugs \\n\\n $resolvedBugs \", \"mentioned_list\":[\"@all\"]}}"
	fi
	echo "$CURL_DATA"

	CURL_CMD="curl \"$CURL_URL\" -H \"Content-Type: application/json\" -d '$CURL_DATA'"
    #echo $CURL_CMD

    CURL_RES=$(eval $CURL_CMD) # 使用eval执行curl命令
    echo $CURL_RES
}

push_webhook_msg

exit 0