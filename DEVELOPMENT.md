# 开发文档

## 多架构 Docker 镜像构建

### 使用 GitHub Actions (推荐)

项目配置了 GitHub Actions 自动构建多架构镜像，位于 `.github/workflows/docker.yml`。

工作流特性：
- 自动构建支持 linux/amd64 和 linux/arm64 平台的镜像
- 自动推送到 GitHub Container Registry (ghcr.io)
- 在. push 到 main 或 master 分支时触发构建

### 本地构建

#### 使用构建脚本

```bash
# 构建并推送默认镜像标签
./docker-build.sh

# 构建并推送自定义标签
./docker-build.sh my-image:tag
```

#### 手动构建

```bash
# 确保 Docker Buildx 可用
docker buildx create --name multiarch-builder --use --bootstrap

# 构建多架构镜像并推送
docker buildx build \
  --platform linux/amd64,linux/arm64 \
  -t ghcr.io/anduin2017/how-to-cook:latest \
  --push \
  .
```

### Dockerfile 优化

当前的 Dockerfile 已优化用于多架构构建：

1. 使用 Alpine 基础镜像以减小体积
2. 配置国内镜像源以加速构建
3. 采用多阶段构建以优化镜像大小

### 故障排除

#### 网络问题

如果在构建过程中遇到网络问题：

1. 确保 Docker 配置了适当的镜像加速器
2. 检查网络连接稳定性
3. 考虑在云环境中执行构建（如 GitHub Actions）

#### 构建缓存

清理构建缓存：

```bash
docker builder prune -a
```

### 镜像仓库

构建的镜像推送到 GitHub Container Registry:
- 地址: `ghcr.io/anduin2017/how-to-cook`
- 支持架构: `linux/amd64`, `linux/arm64`

### 部署

拉取并运行多架构镜像：

```bash
# Docker 会自动选择适合当前架构的镜像变体
docker run -d -p 5000:80 ghcr.io/anduin2017/how-to-cook:latest
```