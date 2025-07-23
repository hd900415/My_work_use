FROM docker.io/jenkins/jenkins:lts-jdk17

USER root

# 安装 tzdata，并支持通过环境变量设置时区
ENV TZ=Asia/Shanghai
RUN apt update && apt -y upgrade && \
    apt -y install curl unzip gnupg sudo lsb-release podman tzdata && \
    ln -fs /usr/share/zoneinfo/$TZ /etc/localtime && \
    dpkg-reconfigure -f noninteractive tzdata && \
    apt clean && rm -rf /var/lib/apt/lists/*
# 安装 AWS CLI v2
RUN curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "/tmp/awscliv2.zip" && \
    unzip /tmp/awscliv2.zip -d /tmp && \
    /tmp/aws/install && \
    rm -rf /tmp/aws*

# 安装 kubectl（与你的 Kubernetes 版本匹配）
ARG KUBECTL_VERSION=1.30.1
RUN curl -LO "https://dl.k8s.io/release/v${KUBECTL_VERSION}/bin/linux/amd64/kubectl" && \
    install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl && \
    rm kubectl

# 安装 Maven 和 Sonar Scanner
ADD ./apache-maven-3.9.9-bin.tar.gz /usr/local/
ADD ./sonar-scanner-cli-4.8.0.2856.tar.gz /usr/local/

ENV MAVEN_HOME=/usr/local/apache-maven-3.9.9
ENV SONAR_SCANNER_HOME=/usr/local/sonar-scanner-4.8.0.2856
ENV PATH=$JAVA_HOME/bin:$MAVEN_HOME/bin:$SONAR_SCANNER_HOME/bin:$PATH

# 允许 jenkins 用户使用 sudo（无密码）
RUN echo "jenkins ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

USER jenkins