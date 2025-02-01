docker  run -d  --name redis --restart always -p 6379:6379 \
-v /data/docker/redis/data:/data/ \
-v /etc/localtime:/etc/localtime \
-v /data/docker/redis/conf/redis.conf:/data/redis.conf \
redis:6.2 redis-server /data/redis.conf