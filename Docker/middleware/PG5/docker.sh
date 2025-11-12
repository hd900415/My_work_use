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