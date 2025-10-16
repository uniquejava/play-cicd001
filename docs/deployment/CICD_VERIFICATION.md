# CI/CD验证测试

## 验证步骤

### 1. 部署验证
```bash
# 一键部署
./scripts/deploy.sh

# 检查Pod状态
kubectl get pods -n ticket-dev

# 检查服务
kubectl get services -n ticket-dev

# 检查Ingress
kubectl get ingress -n ticket-dev
```

### 2. API测试
```bash
# 获取Load Balancer地址
LB_URL=$(kubectl get ingress ticket-management-ingress -n ticket-dev -o jsonpath='{.status.loadBalancer.ingress[0].hostname}')

# 测试后端API
curl http://$LB_URL/api/tickets

# 测试前端页面
curl -I http://$LB_URL/
```

### 3. ArgoCD验证
```bash
# 检查应用状态
argocd app get ticket-system-dev

# 检查Image Updater日志
kubectl logs -n argocd -l app.kubernetes.io/name=argocd-image-updater

# 手动同步测试
argocd app sync ticket-system-dev
```

### 4. CI/CD流程测试
```bash
# 修改代码触发CI
echo "// Test change" >> frontend/src/App.vue
git add frontend/src/App.vue
git commit -m "test: trigger CI pipeline"
git push origin main

# 监控GitHub Actions
gh run list --repo uniquejava/play-cicd001 --limit 3

# 验证新镜像部署
kubectl get pods -n ticket-dev -w
```

## 故障排除
```bash
# Pod日志
kubectl logs -f deployment/backend-deployment -n ticket-dev
kubectl logs -f deployment/frontend-deployment -n ticket-dev

# 事件查看
kubectl describe pod -n ticket-dev

# Image Updater调试
kubectl logs -n argocd deployment/argocd-image-updater | grep -E "(error|warn|update)"
```