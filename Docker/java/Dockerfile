# 基础景象
FROM openjdk:17-jdk

# 作者信息
LABEL maintainer="PT"
LABEL version="1.0"
LABEL description="Docker image for PT with Java 17"
# 设置环境变量
ENV TZ=Asia/Shanghai
ENV LANG=C.UTF-8 \
    LANGUAGE=C.UTF-8 \
    LC_ALL=C.UTF-8
ENV JAVA_HOME=/usr/local/openjdk-17 \
    PATH=$JAVA_HOME/bin:$PATH

# 安装必要的工具
RUN apt-get update && \
    apt-get install -y wget curl git unzip tzdata && \
    rm -rf /var/lib/apt/lists/*
# 创建目录
RUN mkdir -p /data/pt

# 可选：设置默认工作目录
WORKDIR /data/pt
# 可选：复制本地文件到容器中
COPY GeoLite2-City.mmdb /data/pt
# 可选：暴露端口
EXPOSE 8080
# 可选：设置容器启动命令
ENTRYPOINT ["java",  "-jar", "front.jar"]