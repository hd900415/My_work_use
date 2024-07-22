  minio:
    image: minio/minio:latest
    container_name: minio
    restart: always
    network: admin
    environment:
      MINIO_ACCESS_KEY: ${MINIO_ACCESS_KEY}
      MINIO_SECRET_KEY: ${MINIO_SECRET_KEY}
    ports:
      - "9000:9000"
      - "9090:9090"
    volumes:
      - ${MINIO_DATA_PATH}:/data
    command: server /data --console-address ":9090"

docker run -d --name minio \
--restart always \
-p 9000:9000 -p 9090:9090 \
-v /data/docker/minio/data:/data \
-e MINIO_ACCESS_KEY=admin -e MINIO_SECRET_KEY=adminminio \
minio/minio:latest server /data --console-address ":9090"