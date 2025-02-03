# 拉取 rocketmq-dashboard 镜像
docker pull apacherocketmq/rocketmq-dashboard:latest

# 创建并运行容器 
docker run -d \
  --name rocketmq-dashboard \
  -e "JAVA_OPTS=-Drocketmq.namesrv.addr=YOUR_NAMESRV_IP:9876" \
  -m 8g \
  -p 8080:8080 \
  apacherocketmq/rocketmq-dashboard:latest

# 注意:
# 1. 将 YOUR_NAMESRV_IP 替换为你的 RocketMQ NameServer 地址
# 2. 默认端口为8080,可以根据需要修改映射端口
# 3. 访问地址: http://YOUR_HOST_IP:8080
