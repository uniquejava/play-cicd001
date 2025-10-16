# 项目实施计划

## 项目概述
简单Ticket管理系统，演示完整CI/CD流程

## 技术栈
- **后端**: Spring Boot + Java
- **前端**: Vue 3 + TypeScript + Vite
- **CI/CD**: GitHub Actions + ArgoCD
- **容器化**: Docker + Kubernetes
- **GitOps**: ArgoCD Image Updater

## 实施阶段

### 阶段1: 基础开发 ✅
- 后端CRUD API (Spring Boot)
- 前端管理界面 (Vue 3)
- 前后端API集成
- 内存数据存储

### 阶段2: 容器化 ✅
- Docker镜像配置
- 多阶段构建优化
- 健康检查配置

### 阶段3: CI/CD流水线 ✅
- GitHub Actions CI/CD
- Kubernetes manifests
- ECR镜像仓库
- ArgoCD GitOps

## 当前状态
- ✅ 核心功能开发完成
- ✅ Docker容器化完成
- ✅ CI/CD流水线配置完成
- ✅ EKS基础设施部署完成
- ✅ ArgoCD Image Updater配置完成

## 关键配置
- **GitHub Secrets**: AWS凭证配置
- **ECR Registry**: `488363440930.dkr.ecr.ap-northeast-1.amazonaws.com`
- **K8s Namespace**: `ticket-dev`
- **ArgoCD**: 自动Git同步 + Image Updater

## 部署流程
1. 代码推送 → GitHub Actions CI
2. 构建Docker镜像 → 推送到ECR
3. ArgoCD Image Updater检测 → 自动更新K8s
4. 应用自动部署到EKS集群

## 一键部署
```bash
./scripts/deploy.sh  # 完整部署（基础设施+应用）
```