# 部署指南

## 一键部署
```bash
./scripts/deploy.sh
```

## 本地开发
```bash
# 后端
cd backend && mvn spring-boot:run
# 访问: http://localhost:8080

# 前端
cd frontend && pnpm install && pnpm dev
# 访问: http://localhost:5173
```

## Kubernetes部署
```bash
# 部署到现有集群
./scripts/deploy.sh --skip-infra

# 手动部署
kubectl apply -k cicd/k8s/ -n ticket-dev

# 检查状态
kubectl get pods -n ticket-dev
kubectl get ingress -n ticket-dev
```

## ArgoCD GitOps
```bash
# ECR credentials (Image Updater需要)
./scripts/setup-ecr-credentials.sh && kubectl apply -k cicd/k8s/argocd/

# 检查Image Updater状态
kubectl logs -n argocd -l app.kubernetes.io/name=argocd-image-updater
```

## CI/CD流程
```
Git Push → GitHub Actions CI → Docker Build → ECR Push → ArgoCD自动部署
```

## 关键配置
- **GitHub Secrets**: `AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY`
- **IAM权限**: `AmazonEC2ContainerRegistryPowerUser`
- **镜像标签**: 使用Git commit SHA (40位)