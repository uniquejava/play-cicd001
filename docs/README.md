# 文档中心

## 🏗️ 核心文档
- [**基础设施部署**](INFRASTRUCTURE.md) - Terraform + EKS 完整部署指南
- [**CI/CD流程**](CICD.md) - GitHub Actions + ArgoCD + Image Updater 完整流程
- [**自动化脚本**](SCRIPTS.md) - 部署和管理脚本使用指南

## 📋 其他文档
- [项目说明](INSTRUCTION.md) - 项目背景和架构
- [前端开发](frontend-README.md) - Vue 3应用开发
- [项目计划](plan.md) - 开发里程碑
- [Kind本地集群](infrastructure/kind.md) - 本地开发环境
- [NGINX配置](deployment/nginx-setup.md) - Ingress Controller设置
- [Helm迁移](deployment/HELM_MIGRATION.md) - Helm配置迁移记录

## 📖 CI/CD完整流程
```
代码推送 → GitHub Actions CI → Docker构建 → ECR推送 → ArgoCD Image Updater → 自动部署
```

## 🚀 快速开始
```bash
# 完整部署
./scripts/deploy.sh

# 仅部署应用
./scripts/deploy.sh --skip-infra

# 验证部署
kubectl get pods -n ticket-dev
```