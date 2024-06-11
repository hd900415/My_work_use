
### 三主三从集群-docker部署

nameserver 节点
docker run -d --name rmqnameserv \
-v /data/docker/rocketmq/namesrv/logs:/home/rocketmq/logs 
-p 9876:9876 \
--restart always \
apache/rocketmq:5.1.0 sh mqnamesrv 


## 架构说明：
# 1 三主三从 。三个master 三个slave
# 2 采用docker部署配置
# 3 配置文件如下。根据实际节点更改配置文件中的，broker-name borkerid borkerip 目录等

## 主配置文件
cat /data/docker/rocketmq/conf/broker-a.properties 
brokerClusterName=rocketmq-cluster
brokerName=broker-a
brokerId=0
brokerRole=ASYNC_MASTER
flushDiskType=ASYNC_FLUSH
brokerIP1=172.28.93.234
namesrvAddr=172.28.93.234:9876;172.28.116.31:9876;172.28.104.220:9876
defaultTopicQueueNums=4
autoCreateTopicEnable=true
autoCreateSubscriptionGroup=true
listenPort=10911
deleteWhen=04
fileReservedTime=48
mapedFileSizeCommitLog=1073741824
mapedFileSizeConsumeQueue=300000
diskMaxUsedSpaceRatio=88
maxMessageSize=65536
sendMessageThreadPoolNums=128
useReentrantLockWhenPutMessage=true
waitTimeMillsInSendQueue=300 

## 从节点配置文件
cat /data/docker/rocketmq/conf/broker-b.properties 
brokerClusterName=rocketmq-cluster
brokerName=broker-b
brokerId=1
brokerRole=SLAVE
flushDiskType=ASYNC_FLUSH
brokerIP1=172.28.93.234
namesrvAddr=172.28.93.234:9876;172.28.116.31:9876;172.28.104.220:9876
defaultTopicQueueNums=4
autoCreateTopicEnable=false
autoCreateSubscriptionGroup=false
listenPort=10900
deleteWhen=04
fileReservedTime=48
mapedFileSizeCommitLog=1073741824
mapedFileSizeConsumeQueue=300000
diskMaxUsedSpaceRatio=88
maxMessageSize=65536
sendMessageThreadPoolNums=128
useReentrantLockWhenPutMessage=true
waitTimeMillsInSendQueue=300

## nameserver 服务的节点数量不涉及broker集群的部署。一般按照节点数量进行部署
## broker 和dashborad 部署
# broker
docker run -d -u 0 --name rmqbroker-a --restart always --network host \
 -v /data/docker/rocketmq/broker-a/data:/home/rocketmq/store \
 -v /data/docker/rocketmq/broker-a/logs:/home/rocketmq/logs  \
 -v /data/docker/rocketmq/conf/broker-a.properties:/home/rocketmq/rocketmq-5.1.0/conf/broker.conf \
 apache/rocketmq:5.1.0 sh mqbroker -c /home/rocketmq/rocketmq-5.1.0/conf/broker.conf
docker run -d -u 0 --name rmqbroker-b --restart always --network host  \
-v /data/docker/rocketmq/broker-b/data:/home/rocketmq/store \
-v /data/docker/rocketmq/broker-b/logs:/home/rocketmq/logs \
-v /data/docker/rocketmq/conf/broker-b.properties:/home/rocketmq/rocketmq-5.1.0/conf/broker.conf \
 apache/rocketmq:5.1.0 sh mqbroker -c /home/rocketmq/rocketmq-5.1.0/conf/broker.conf


docker run -d -u 0 --name rmqbroker-b --restart always --network host  \
-v /data/docker/rocketmq/broker-b/data:/home/rocketmq/store \
-v /data/docker/rocketmq/broker-b/logs:/home/rocketmq/logs  \
-v /data/docker/rocketmq/conf/broker-b.properties:/home/rocketmq/rocketmq-5.1.0/conf/broker.conf \
apache/rocketmq:5.1.0 sh mqbroker -c /home/rocketmq/rocketmq-5.1.0/conf/broker.conf
docker run -d -u 0 --name rmqbroker-c --restart always --network host  \
-v /data/docker/rocketmq/broker-c/data:/home/rocketmq/store \
-v /data/docker/rocketmq/broker-c/logs:/home/rocketmq/logs \
-v /data/docker/rocketmq/conf/broker-c.properties:/home/rocketmq/rocketmq-5.1.0/conf/broker.conf \
apache/rocketmq:5.1.0 sh mqbroker -c /home/rocketmq/rocketmq-5.1.0/conf/broker.conf

docker run -d -u 0 --name rmqbroker-c --restart always --network host  \
-v /data/docker/rocketmq/broker-c/data:/home/rocketmq/store \
-v /data/docker/rocketmq/broker-c/logs:/home/rocketmq/logs \
-v /data/docker/rocketmq/conf/broker-c.properties:/home/rocketmq/rocketmq-5.1.0/conf/broker.conf \
 apache/rocketmq:5.1.0 sh mqbroker -c /home/rocketmq/rocketmq-5.1.0/conf/broker.conf
docker run -d -u 0 --name rmqbroker-a --restart always --network host \
 -v /data/docker/rocketmq/broker-a/data:/home/rocketmq/store \
 -v /data/docker/rocketmq/broker-a/logs:/home/rocketmq/logs \
 -v /data/docker/rocketmq/conf/broker-a.properties:/home/rocketmq/rocketmq-5.1.0/conf/broker.conf \
 apache/rocketmq:5.1.0 sh mqbroker -c /home/rocketmq/rocketmq-5.1.0/conf/broker.conf

docker stop rmqbroker-a rmqbroker-c && docker rm rmqbroker-c rmqbroker-a 


# 和dashborad
docker run -d --name  rocketmq-dashboard -u 0 --restart always   -p 18080:8080 \
 -v /data/docker/rocketmq/tmp:/tmp  \
 -e "JAVA_OPTS=-Drocketmq.namesrv.addr=172.28.93.234:9876;172.28.116.31:9876;172.28.104.220:9876 -Dcom.rocketmq.sendMessageWithVIPChannel=false" \ 
 --ulimit nofile=65535:65535 --ulimit nproc=65535:65535 \ 
 apacherocketmq/rocketmq-dashboard:latest


### 问题处理 broker 启动报错。java.lang.nullpointerexception 。使用启动容器的时候，使用root 启动服务。加-u 0 参数。0 代码UID为0 的用户；
### dashborad 报错 library initialization failed - unable to allocate file descriptor table - out of memoryAborted (core dumped) rocketmq 
# 此错误，启动时，请添加 