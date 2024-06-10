
###  Zookeeper:3.5.5
cat >>/etc/hosts <<EOF
172.28.93.234	demo-gaming-middleware-activemq-001
172.28.116.31	demo-gaming-middleware-activemq-002
172.28.104.220	demo-gaming-middleware-activemq-003
EOF

docker run -d --restart always --name zookeeper --network host \
	-m 2g --ulimit nofile=65536:65536 \
	-e ZOO_MY_ID=1 \
	-e ZOO_SERVERS="server.1=demo-gaming-middleware-activemq-001:2888:3888;2181 server.2=demo-gaming-middleware-activemq-002:2888:3888;2181 server.3=demo-gaming-middleware-activemq-003:2888:3888;2181" \
	-v /etc/localtime:/etc/localtime \
    -v /data/zookeeper/zookeeper01/data:/data \
    -v /data/zookeeper/zookeeper01/datalog:/datalog \
    -v /etc/hosts:/etc/hosts \
    zookeeper:3.5.5

docker run -d --restart always --name zookeeper --network host \
	-m 2g --ulimit nofile=65536:65536 \
	-e ZOO_MY_ID=2 \
	-e ZOO_SERVERS="server.1=demo-gaming-middleware-activemq-001:2888:3888;2181 server.2=demo-gaming-middleware-activemq-002:2888:3888;2181 server.3=demo-gaming-middleware-activemq-003:2888:3888;2181" \
	-v /etc/localtime:/etc/localtime \
    -v /data/zookeeper/zookeeper02/data:/data \
    -v /data/zookeeper/zookeeper02/datalog:/datalog \
    -v /etc/hosts:/etc/hosts \
    zookeeper:3.5.5



docker run -d --restart always --name zookeeper --network host \
	-m 2g --ulimit nofile=65536:65536 \
	-e ZOO_MY_ID=3 \
	-e ZOO_SERVERS="server.1=demo-gaming-middleware-activemq-001:2888:3888;2181 server.2=demo-gaming-middleware-activemq-002:2888:3888;2181 server.3=demo-gaming-middleware-activemq-003:2888:3888;2181" \
	-v /etc/localtime:/etc/localtime \
    -v /data/zookeeper/zookeeper03/data:/data \
    -v /data/zookeeper/zookeeper03/datalog:/datalog \
    -v /etc/hosts:/etc/hosts \
    zookeeper:3.5.5






###  zookeeper web UI 
docker run \
  -d \
  -p 9000:9000 \
  -e HTTP_PORT=9000 \
  --name zoonavigator \
  --restart unless-stopped \
  elkozmon/zoonavigator:latest