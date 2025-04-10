docker run --detach   --hostname gitlab.1fx.me \
-p 9080:80 -p 9443:443 -p 2222:22 \
--name gitlab --restart always \
-v /data/docker/gitlab/config:/etc/gitlab \
-v /data/docker/gitlab/logs:/var/log/gitlab \
-v /data/docker/gitlab/data:/var/opt/gitlab \
-v /data/docker/gitlab/ssl:/etc/gitlab/ssl \
-e GITLAB_OMNIBUS_CONFIG="external_url 'https://gitlab.1fx.me'; nginx['ssl_certificate'] = '/etc/gitlab/ssl/gitlab.1fx.me.crt'; nginx['ssl_certificate_key'] = '/etc/gitlab/ssl/gitlab.1fx.me.key';"  \
gitlab/gitlab-ce:17.4.6-ce.0





sudo docker run --detach \
  --hostname gitlab.stbd06.com \
  --publish 443:443 --publish 80:80 --publish 222:22 \
  --name gitlab \
  --restart always \
  --volume $GITLAB_HOME/config:/etc/gitlab \
  --volume $GITLAB_HOME/logs:/var/log/gitlab \
  --volume $GITLAB_HOME/data:/var/opt/gitlab \
  --shm-size 256m \
  gitlab/gitlab-ee:latest