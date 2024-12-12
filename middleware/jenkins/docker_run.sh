
docker run -d --name jenkins -u root --restart=on-failure \
--dns 1.1.1.1 --dns 8.8.8.8  \
-p 8080:8080 -p 2376:2376 \
--privileged \
-v /data/docker/jenkins/data:/var/jenkins_home \
-v /var/run/docker.sock:/var/run/docker.sock \
jenkins/jenkins:2.488-alpine

docker run -d --name jenkins --network host  -u root --restart=always  \
--cpus="4.0" \
--memory="8g" \
--privileged \
-v /data/docker/jenkins/data:/var/jenkins_home \
-v /var/run/docker.sock:/var/run/docker.sock \
-v /opt/apache-maven-3.3.9:/usr/local/apache-maven-3.3.9 \
-v /opt/jdk1.8.0_431:/usr/local/jdk1.8.0_431 \
jenkins/jenkins:lts