docker run -d --name node-exporter \
-p 9100:9100 \
-v "/proc:/host/proc:ro" \
-v "/sys:/host/sys:ro" \
-v "/:/rootfs:ro" \
-v /etc/localtime:/etc/localtime \
--net="host" \
prom/node-exporter \
--path.procfs /host/proc \
--path.sysfs /host/sys \
--collector.filesystem.ignored-mount-points \
"^(sys|proc|dev|host|etc)($|/)"



