#!/bin/bash

# Docker 多架构构建脚本
# 支持构建 AMD64 和 ARM64 镜像

set -e

echo "检查 Docker Buildx 是否可用..."
if ! [ -x "$(command -v docker)" ]; then
  echo '错误: Docker 未安装或不可用' >&2
  exit 1
fi

if ! docker buildx version > /dev/null 2>&1; then
  echo '错误: Docker Buildx 未安装或不可用' >&2
  exit 1
fi

# 检查是否有自定义标签参数
IMAGE_TAG=${1:-"ghcr.io/anduin2017/how-to-cook:latest"}

echo "开始构建多架构 Docker 镜像: $IMAGE_TAG"
echo "目标平台: linux/amd64, linux/arm64"

# 创建一个支持多架构的构建器（如果不存在）
docker buildx create --name multiarch-builder --use --bootstrap || true

# 构建并推送多架构镜像
docker buildx build \
  --platform linux/amd64,linux/arm64 \
  --tag "$IMAGE_TAG" \
  --push \
  --progress=plain \
  .

echo "多架构 Docker 镜像构建完成: $IMAGE_TAG"
echo "支持的平台: linux/amd64, linux/arm64"