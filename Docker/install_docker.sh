sudo dnf remove docker \
                  docker-client \
                  docker-client-latest \
                  docker-common \
                  docker-latest \
                  docker-latest-logrotate \
                  docker-logrotate \
                  docker-engine
sudo dnf install -y yum-utils
sudo dnf config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
sudo dnf install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin -y
sudo docker compose

cat <EOF >/etc/docker/daemon.json
{
  "userns-remap": "default",      // 启用用户命名空间隔离
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "10m",
    "max-file": "3"
  },
  "default-ulimits": {
    "nofile": {
      "Name": "nofile",
      "Hard": 65535,
      "Soft": 20000
    }
  },
  "live-restore": true,          // 保持容器在Docker重启后存活
  "icc": false                   // 禁用容器间网络通信（默认）
}
EOF
sudo systemctl start docker
systemctl enable --now docker
systemctl daemon-reload
sudo systemctl restart docker