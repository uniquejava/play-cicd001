# 文档中心

## 🚀 CI/CD部署
- [部署指南](deployment/DEPLOYMENT.md) - 一键部署和验证
- [EKS部署指南](deployment/EKS_DEPLOYMENT_GUIDE.md) - AWS EKS集群部署
- [CI/CD流程](deployment/CICD.md) - GitHub Actions配置
- [ArgoCD指南](deployment/ARGO.md) - GitOps和Image Updater
- [CI/CD验证](deployment/CICD_VERIFICATION.md) - 完整流程测试
- [GitHub Actions配置](deployment/github-actions-setup.md) - CI/CD详细配置
- [NGINX配置](deployment/nginx-setup.md) - Ingress Controller设置

## 🏗️ 基础设施
- [基础设施概览](infrastructure/infra-README.md) - Terraform配置
- [Kind本地集群](infrastructure/kind.md) - 本地开发环境

## 📜 自动化脚本
- [脚本指南](scripts/README.md) - 部署和管理脚本

## 📋 项目信息
- [项目说明](INSTRUCTION.md) - 开发注意事项
- [项目计划](plan.md) - 实施状态和流程

## 🎯 开发指南
- [前端开发](frontend-README.md) - Vue 3应用开发

## 📖 CI/CD完整流程
```
代码推送 → GitHub Actions CI → Docker构建 → ECR推送 → ArgoCD自动部署
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