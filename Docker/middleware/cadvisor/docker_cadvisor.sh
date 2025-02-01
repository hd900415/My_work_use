docker run -d -u root \
-v /:/rootfs:ro \
-v /var/run:/var/run:ro \
-v /sys:/sys:ro \
-v /var/lib/docker/:/var/lib/docker:ro \
-v /dev/disk/:/dev/disk:ro \
-v /etc/localtime:/etc/localtime \
--publish=8180:8080 \
--detach=true \
--name=cadvisor gcr.io/cadvisor/cadvisor:v0.47.2