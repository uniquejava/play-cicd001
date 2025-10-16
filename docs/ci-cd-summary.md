# CI/CD 流程总结

## 完整流程
```
Git Push → GitHub Actions CI → Build & Test → Docker Build → ECR Push → K8s Deploy
```

## 核心配置

### GitHub Actions
- `.github/workflows/ci.yml` - CI流程
- 触发: main/develop分支推送、PR到main
- 包含: 测试、构建、ECR推送

### Kubernetes部署
- `cicd/k8s/` - K8s manifests
- `cicd/argocd/` - ArgoCD配置

### 关键命令
```bash
# 完整部署
./scripts/deploy.sh

# 仅应用部署
./scripts/deploy.sh --skip-infra

# 验证部署
kubectl get pods -n ticket-dev
kubectl get ingress -n ticket-dev

# 测试API
curl http://<LB_URL>/api/tickets
```

## 配置要求

### GitHub Secrets
```bash
AWS_ACCESS_KEY_ID=<your-key>
AWS_SECRET_ACCESS_KEY=<your-secret>
```

### IAM权限
- AmazonEC2ContainerRegistryFullAccess
- AmazonEKSFullAccess