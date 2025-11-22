docker network create xboard-net || true

docker run -d --name xboard-pg \
  --restart=always \
  --network xboard-net \
  -p 5432:5432 \
  -e POSTGRES_USER=postgres \
  -e POSTGRES_PASSWORD='RYCIc6SsyA6DsFoMUQv7' \
  -e POSTGRES_DB=xboard \
  -v /data/xboard/pgdata:/var/lib/postgresql/data \
  postgres:15

  docker exec -it xboard-pg psql -U postgres -d xboard -c "\l"

docker run -itd --restart=always  --network=host \
 -e apiHost=https://adminxboard.pttech.cc \
 -e apiKey=FY4DYhoHUfxB4qG2Sqo3 \
 -e domain=hy2.pttech.cc  \
 -e nodeID=1 \
ghcr.io/cedar2025/hysteria:latest



v2board:
  apiHost: https://adminxboard.pttech.cc
  apiKey: FY4DYhoHUfxB4qG2Sqo3
  nodeID: 1
tls:
  type: tls
  cert: /etc/hysteria/tls.crt
  key: /etc/hysteria/tls.key
auth:
  type: v2board
trafficStats:
  listen: 127.0.0.1:7653
acl: 
  inline: 
    - reject(10.0.0.0/8)
    - reject(172.16.0.0/12)
    - reject(192.168.0.0/16)
    - reject(127.0.0.0/8)
    - reject(fc00::/7)