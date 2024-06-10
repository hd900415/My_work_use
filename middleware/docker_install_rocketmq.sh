## 架构
生产环境（高可用性架构）：

多个 Name Server（无状态，可以水平扩展）
多个 Broker 集群（每个集群包含 1 个 Master 和多个 Slave）
多个 Producer 和 Consumer，按照业务需求水平扩展


###  RocketMQ:5.1.0

docker run -d --name rmqserver


##   dashborad

docker run -d --name rmqconsole --restart always -e JAVA_OPTS='-Drocketmq.namesrv.addr=172.28.93.234:9876;172.28.116.31:9876;172.28.104.220:9876 -Dcom.rocketmq.sendMessageWithVIPChannel=false -Drocketmq.config.accessKey=rocketmq2 -Drocketmq.config.secretKey=12345678' -v /data/rocketmq:/tmp/rocketmq-console/data 



### 配置文件
docker 容器路径

/home/rocketmq/rocketmq-5.1.0


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
storePathRootDir=/home/rocketmq/rocketmq-5.1.0/data/broker-a-m
#commitLog 存储路径
storePathCommitLog=/home/rocketmq/rocketmq-5.1.0/data/broker-a-m/commitlog
#消费队列存储路径存储路径
storePathConsumeQueue=/home/rocketmq/rocketmq-5.1.0/data/broker-a-m/consumequeue
#消息索引存储路径
storePathIndex=/home/rocketmq/rocketmq-5.1.0/data/broker-a-m/index
#checkpoint 文件存储路径
storeCheckpoint=/home/rocketmq/rocketmq-5.1.0/data/checkpoint
#abort 文件存储路径
abortFile=/home/rocketmq/rocketmq-5.1.0/data/abort
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



### 配置文件 broker-b
# 所属集群名称
brokerClusterName=rocketmq-cluster
# broker名称
brokerName=broker-b
#broker的角色
# 集群中0表示Master,>0表示Slave
brokerId=1

# broker的数据规则
#- ASYNC_MASTER 异步复制Master
#- SYNC_MASTER同步双写Master
#- SLAVE
brokerRole=SLAVE

# 刷盘方式
#- ASYNC_FLUSH 异步刷盘
#- SYNC_FLUSH 同步刷盘
flushDiskType=ASYNC_FLUSH

# 指定broker的IP
brokerIP1=10.25.27.116
#nameServer地址，集群用分号分割
namesrvAddr=172.28.93.234:9876;172.28.116.31:9876;172.28.104.220:9876

# 在发送消息时，自动创建服务器不存在的topic，默认创建的队列数
defaultTopicQueueNums=4

# 是否允许Broker自动创建Topic，建议线下开启，线上关闭
autoCreateTopicEnable=false

# 是否允许Broker自动创建订阅组，建议线下开启，线上关闭
autoCreateSubscriptionGroup=false

# broker对外服务的监听端口
listenPort=10900

# 删除文件时间点，默认凌晨四点
deleteWhen=04

# 文件保留时间，默认48小时
fileReservedTime=48

# commitLog每个文件的大小默认1G
mapedFileSizeCommitLog=1073741824

# ConsumeQueue每个文件默认存30W条，根据业务情况调整
mapedFileSizeConsumeQueue=300000
# destroyMapedFileIntervalForcibly=120000
#redeleteHangedFileInterval=120000

#检测物理文件磁盘空间
diskMaxUsedSpaceRatio=88
#存储路径
storePathRootDir=/home/rocketmq/rocketmq-5.1.0/data/broker-a-m
#commitLog 存储路径
storePathCommitLog=/home/rocketmq/rocketmq-5.1.0/data/broker-a-m/commitlog
#消费队列存储路径存储路径
storePathConsumeQueue=/home/rocketmq/rocketmq-5.1.0/data/broker-a-m/consumequeue
#消息索引存储路径
storePathIndex=/home/rocketmq/rocketmq-5.1.0/data/broker-a-m/index
#checkpoint 文件存储路径
storeCheckpoint=/home/rocketmq/rocketmq-5.1.0/data/checkpoint
#abort 文件存储路径
abortFile=/home/rocketmq/rocketmq-5.1.0/data/abort

#限制消息大小
maxMessageSize=65536
#flushCommitLogLeastPages=4
#flushConsumeQueueLeastPages=2
#flushCommitLogThoroughInterval=10000
#flushConsumeQueueThoroughInterval=60000
#checkTransactionMessageEnable=false

#发送消息线程池数量
sendMessageThreadPoolNums=128
#拉消息线程池数量
#pullMessageThreadPoolNums=128
#发送消息是否使用可重入锁
useReentrantLockWhenPutMessage=true
waitTimeMillsInSendQueue=300

