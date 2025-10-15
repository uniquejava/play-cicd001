#!/bin/bash

# 构建脚本 - 支持不同环境的构建模式
set -e

FRONTEND_DIR="../../../frontend"
DOCKER_DIR=$(pwd)

# 默认构建模式
MODE=${1:-production}

echo "🔨 构建前端 Docker 镜像"
echo "构建模式: $MODE"

# 检查参数
if [[ "$MODE" != "production" && "$MODE" != "development" ]]; then
    echo "❌ 错误: 无效的构建模式 '$MODE'"
    echo "使用方法: $0 [production|development]"
    exit 1
fi

# 设置镜像标签
IMAGE_TAG="488363440930.dkr.ecr.ap-southeast-1.amazonaws.com/ticket-management-frontend-dev"
if [[ "$MODE" == "development" ]]; then
    IMAGE_TAG="$IMAGE_TAG:dev"
else
    IMAGE_TAG="$IMAGE_TAG:latest"
fi

echo "镜像标签: $IMAGE_TAG"

# 构建镜像
echo "📦 开始构建 Docker 镜像..."
docker build \
    --build-arg MODE=$MODE \
    -t $IMAGE_TAG \
    -f Dockerfile \
    $FRONTEND_DIR

echo "✅ 构建完成!"

# 显示镜像信息
echo ""
echo "📋 镜像信息:"
docker images $IMAGE_TAG

echo ""
echo "🚀 推送到 ECR:"
echo "docker push $IMAGE_TAG"