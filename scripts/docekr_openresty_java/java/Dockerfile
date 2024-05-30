# 使用官方的 Oracle Linux 作为基础镜像
FROM bitnami/java:1.8.412-9

# 创建应用目录
RUN mkdir -p /usr/app

# 设置工作目录
WORKDIR /usr/app

# 将应用的 JAR 文件复制到容器中
COPY ./application.yml  /usr/app/application.yml
COPY ./cash-agent-front.jar /usr/app/cash-agent-front.jar

ENV TZ=Asia/Shanghai

# 创建一个非 root 用户

# 暴露应用运行的端口（假设应用在8095端口运行）
EXPOSE 8074

# 添加健康检查，确保应用在运行中
# HEALTHCHECK --interval=30s --timeout=10s --start-period=30s --retries=3 CMD curl -f http://localhost:8095/health || exit 1

# 运行 JAR 文件，并设置最小和最大内存
ENTRYPOINT ["java", "-Xms512m", "-Xmx1g", "-jar", "cash-agent-front.jar"]