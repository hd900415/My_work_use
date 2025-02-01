172.28.93.234
172.28.116.31
172.28.104.220
#  做好主机的hosts文件

docker run -d --name activemq1 -p 61616:61616 -p 8161:8161 \
-e ACTIVEMQ_NAME=demo-gaming-middleware-activemq-001 \
-e ACTIVEMQ_CLUSTERED=True  \
-e ACTIVEMQ_REPLICATED_LEVELDB=true \
-e ACTIVEMQ_REPLICATED_LEVELDB_HOST=demo-gaming-middleware-activemq-002 \
-e ACTIVEMQ_REPLICATED_LEVELDB_PORT=61616 \
-e ACTIVEMQ_REPLICATED_LEVELDB_REPLICAS=3 \
-v /etc/localtime:/etc/localtime \
-v /etc/hosts:/etc/hosts \
--ulimit nofile=65535:65535 --ulimit nproc=65535:65535 \
rmohr/activemq:5.15.9-alpine

docker run -d --name activemq2 -p 61616:61616 -p 8161:8161 \
-e ACTIVEMQ_NAME=demo-gaming-middleware-activemq-002 \
-e ACTIVEMQ_CLUSTERED=True  \
-e ACTIVEMQ_REPLICATED_LEVELDB=true \
-e ACTIVEMQ_REPLICATED_LEVELDB_HOST=demo-gaming-middleware-activemq-003 \
-e ACTIVEMQ_REPLICATED_LEVELDB_PORT=61616 \
-e ACTIVEMQ_REPLICATED_LEVELDB_REPLICAS=3 \
-v /etc/localtime:/etc/localtime \
-v /etc/hosts:/etc/hosts \
--ulimit nofile=65535:65535 --ulimit nproc=65535:65535 \
rmohr/activemq:5.15.9-alpine

docker run -d --name activemq3 -p 61616:61616 -p 8161:8161 \
-e ACTIVEMQ_NAME=demo-gaming-middleware-activemq-003 \
-e ACTIVEMQ_CLUSTERED=True  \
-e ACTIVEMQ_REPLICATED_LEVELDB=true \
-e ACTIVEMQ_REPLICATED_LEVELDB_HOST=demo-gaming-middleware-activemq-001 \
-e ACTIVEMQ_REPLICATED_LEVELDB_PORT=61616 \
-e ACTIVEMQ_REPLICATED_LEVELDB_REPLICAS=3 \
-v /etc/localtime:/etc/localtime \
-v /etc/hosts:/etc/hosts \
--ulimit nofile=65535:65535 --ulimit nproc=65535:65535 \
rmohr/activemq:5.15.9-alpine