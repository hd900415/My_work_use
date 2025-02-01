
### 三主三从集群-docker部署


## 架构
生产环境（高可用性架构）：

多个 Name Server（无状态，可以水平扩展）
多个 Broker 集群（每个集群包含 1 个 Master 和多个 Slave）
多个 Producer 和 Consumer，按照业务需求水平扩展

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
# 此错误，启动时，请添加  --ulimit nofile=65535:65535 --ulimit nproc=65535:65535 

# broker-a
#所属集群名字
brokerClusterName=rocketmq-cluster
#broker名字
brokerName=broker-a
#集群中 0 表示 Master，>0 表示 Slave
brokerId=0
#Broker 的角色
#- ASYNC_MASTER 异步复制Master
#- SYNC_MASTER 同步双写Master
#- SLAVE 从节点
brokerRole=ASYNC_MASTER
#刷盘方式
#- ASYNC_FLUSH 异步刷盘
#- SYNC_FLUSH 同步刷盘
flushDiskType=ASYNC_FLUSH
#指定broker的IP（根据实际情况填写）
brokerIP1=10.25.27.116
#nameServer地址，集群用分号分割，域名1:9876; 域名2:9876; 域名3:9876（根据实际情况填写）
namesrvAddr=172.28.93.234:9876;172.28.116.31:9876;172.28.104.220:9876
#在发送消息时，自动创建服务器不存在的topic，默认创建的队列数
defaultTopicQueueNums=4
#是否允许 Broker 自动创建Topic，建议线下开启，线上关闭
autoCreateTopicEnable=true
#是否允许 Broker 自动创建订阅组，建议线下开启，线上关闭
autoCreateSubscriptionGroup=true
#Broker 对外服务的监听端口
listenPort=10911
#删除文件时间点，默认凌晨 4点
deleteWhen=04
#文件保留时间，默认 48 小时
fileReservedTime=48
#commitLog每个文件的大小默认1G
mapedFileSizeCommitLog=1073741824
#ConsumeQueue每个文件默认存30W条，根据业务情况调整
mapedFileSizeConsumeQueue=300000
#destroyMapedFileIntervalForcibly=120000
#redeleteHangedFileInterval=120000
#检测物理文件磁盘空间
diskMaxUsedSpaceRatio=88
#存储路径
#storePathRootDir=/home/rocketmq/rocketmq-5.1.0/store/broker-a-m
#commitLog 存储路径
#storePathCommitLog=/home/rocketmq/rocketmq-5.1.0/data/broker-a-m/commitlog
#消费队列存储路径存储路径
#storePathConsumeQueue=/home/rocketmq/rocketmq-5.1.0/data/broker-a-m/consumequeue
#消息索引存储路径
#storePathIndex=/home/rocketmq/rocketmq-5.1.0/data/broker-a-m/index
#checkpoint 文件存储路径
#storeCheckpoint=/home/rocketmq/rocketmq-5.1.0/data/checkpoint
#abort 文件存储路径
#abortFile=/home/rocketmq/rocketmq-5.1.0/data/abort
#限制的消息大小
maxMessageSize=65536
#flushCommitLogLeastPages=4
#flushConsumeQueueLeastPages=2
#flushCommitLogThoroughInterval=10000
#flushConsumeQueueThoroughInterval=60000
#checkTransactionMessageEnable=false
#发消息线程池数量
sendMessageThreadPoolNums=128
#拉消息线程池数量
#pullMessaeThreadPoolNums=128

#发送消息是否使用可重入锁
useReentrantLockWhenPutMessage=true
waitTimeMillsInSendQueue=300  #或者更大