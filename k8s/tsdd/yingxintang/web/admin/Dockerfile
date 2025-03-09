# 使用官方 Nginx 镜像作为基础镜像
FROM nginx:alpine

# 删除默认配置
RUN rm -rf /usr/share/nginx/html/*

# 将构建的静态文件复制到 Nginx 的 html 目录
COPY admin/ /usr/share/nginx/html/

# 替换 Nginx 默认配置，支持前端路由
COPY nginx.conf /etc/nginx/conf.d/default.conf

# 暴露 Nginx 的默认端口
EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]
