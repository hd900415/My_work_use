docker run -d --name prometheus -p 9090:9090 \
-v /etc/localtime:/etc/localtime:ro \
-v /data/docker/prometheus/data:/prometheus/data \
-v /data/docker/prometheus/conf:/prometheus/config \
-v /data/docker/prometheus/rules:/prometheus/rules \
prom/prometheus --config.file=/prometheus/config/prometheus.yml --web.enable-lifecycle