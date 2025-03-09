# My Work Use

## 项目简介

My Work Use 仓库包含了多个 DevOps 相关的配置文件和脚本，旨在简化和自动化开发和运维流程。该仓库主要用于管理 Kubernetes 配置、数据库连接、日志配置、推送服务等。

## 目录结构

```
.
├── k8s
│   └── tsdd
│       ├── mszs-dingdong
│       │   └── tsdd
│       │       └── tsdd-cm.yaml
│       └── ...
└── ...
```

## 主要功能

### Kubernetes 配置

仓库包含多个 Kubernetes 配置文件，用于管理不同服务的部署和配置。例如：

- `tsdd-cm.yaml`: 包含了 tsdd 服务的配置，包括数据库连接、Redis 配置、文件服务配置等。

### 数据库配置

支持 MySQL 和 Redis 的连接配置，确保服务能够正确连接和操作数据库。

### 日志配置

提供了详细的日志配置选项，包括日志级别、日志目录和是否打印行号等。

### 推送服务

支持多种推送服务配置，如 JPush、APNs、华为推送、小米推送等，确保消息能够及时推送到用户设备。

### 文件服务

支持 MinIO 和阿里云 OSS 的文件服务配置，方便文件的存储和管理。

## 使用方法

1. 克隆仓库到本地：

    ```bash
    git clone https://github.com/hd900415/My_work_use.git
    ```

2. 根据需要修改配置文件中的占位符（如 `************`）为实际的值。

3. 部署 Kubernetes 配置：

    ```bash
    kubectl apply -f k8s/tsdd/mszs-dingdong/tsdd/tsdd-cm.yaml
    ```

## 注意事项

- 请确保在提交代码前，已经将所有敏感信息（如密码、密钥等）替换为占位符或移除。
- 强制推送到远程仓库时，请确保已经备份了重要数据。

## 贡献

欢迎提交 Issue 和 Pull Request 来改进本项目。如果有任何问题或建议，请随时与我们联系。

## 许可证

本项目采用 MIT 许可证，详情请参阅 LICENSE 文件。
