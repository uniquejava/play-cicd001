# CI/CD 完整流程 (GitHub Actions + ArgoCD)

## 概述

本项目实现了完整的 GitOps CI/CD 流水线：
```
代码推送 → GitHub Actions CI → Docker构建 → ECR推送 → ArgoCD自动部署
```

## 核心组件

### 1. GitHub Actions (CI)
- **文件位置**: `.github/workflows/ci.yml`
- **触发条件**: main/develop分支推送、PR到main
- **功能**: 测试、构建Docker镜像、推送到ECR

### 2. ArgoCD (CD)
- **功能**: GitOps自动部署
- **配置文件**: `cicd/argocd/`
- **Image Updater**: 自动检测ECR新镜像并更新部署

### 3. ECR 镜像仓库
- **后端**: `488363440930.dkr.ecr.ap-northeast-1.amazonaws.com/ticket-management-backend-dev`
- **前端**: `488363440930.dkr.ecr.ap-northeast-1.amazonaws.com/ticket-management-frontend-dev`
- **标签策略**: 使用完整Git commit SHA (40位)

## GitHub Actions 配置

### 触发条件
- `main` 分支推送：完整 CI/CD（测试+构建+推送）
- `develop` 分支推送：仅测试
- PR 到 `main`：测试验证

### 关键配置
```yaml
env:
  AWS_REGION: ap-northeast-1
  ECR_REGISTRY: 488363440930.dkr.ecr.ap-northeast-1.amazonaws.com
```

### AWS 凭证配置

#### GitHub Secrets 设置
1. Repository → Settings → Secrets and variables → Actions
2. 添加 secrets：
   - `AWS_ACCESS_KEY_ID`
   - `AWS_SECRET_ACCESS_KEY`

#### 快速创建 IAM 用户
```bash
aws iam create-user --user-name GitHubActions
aws iam attach-user-policy --user-name GitHubActions --policy-arn arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryPowerUser
aws iam create-access-key --user-name GitHubActions
```

### CI 监控命令
```bash
# GitHub Actions CLI (需要安装 gh)
gh run list --repo uniquejava/play-cicd001
gh run view --repo uniquejava/play-cicd001 RUN_ID
gh run list --repo uniquejava/play-cicd001 --limit 5

# 重新运行失败workflow
gh run rerun <run-id> --repo uniquejava/play-cicd001
```

## ArgoCD GitOps

### ArgoCD Application 配置
```yaml
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: ticket-system-dev
  namespace: argocd
  annotations:
    # Image Updater 必需注解
    argocd-image-updater.argoproj.io/image-list: backend=ecr-url/backend-dev,frontend=ecr-url/frontend-dev
    argocd-image-updater.argoproj.io/backend.update-strategy: newest-build
    argocd-image-updater.argoproj.io/backend.allow-tags: regexp:^[a-fA-F0-9]{40}$
    argocd-image-updater.argoproj.io/frontend.update-strategy: newest-build
    argocd-image-updater.argoproj.io/frontend.allow-tags: regexp:^[a-fA-F0-9]{40}$
```

### ArgoCD 常用命令
```bash
# 查看应用状态
argocd app list
argocd app get ticket-system-dev
argocd app sync ticket-system-dev
argocd app logs ticket-system-dev

# 查看集群中的应用
kubectl get applications -n argocd
kubectl get appprojects -n argocd
```

## ArgoCD Image Updater

### 工作原理
- **检查间隔**: 每2分钟检查一次ECR
- **更新策略**: `newest-build` 基于镜像构建时间选择最新镜像
- **标签匹配**: 使用正则表达式 `^[a-fA-F0-9]{40}$` 匹配Git commit SHA
- **GitOps流程**: 自动更新集群中的应用并同步到Git仓库

### ECR 认证配置
```bash
# 自动化部署 ECR credentials (推荐)
./scripts/setup-ecr-credentials.sh && kubectl apply -k cicd/k8s/argocd/

# 手动创建 ECR credentials
kubectl create secret docker-registry ecr-credentials \
  --docker-server=488363440930.dkr.ecr.ap-northeast-1.amazonaws.com \
  --docker-username=AWS \
  --docker-password=$(aws ecr get-login-password --region ap-northeast-1) \
  -n argocd
```

### Image Updater 调试
```bash
# 查看Image Updater日志 (最重要的调试工具)
kubectl logs -n argocd -l app.kubernetes.io/name=argocd-image-updater -f

# 查看最近的错误
kubectl logs -n argocd -l app.kubernetes.io/name=argocd-image-updater --tail=50

# 手动触发检查 (重启Pod)
kubectl delete pod -n argocd -l app.kubernetes.io/name=argocd-image-updater

# 查看当前镜像版本
kubectl get deployments -n ticket-dev -o yaml | grep image:
```

## Kustomize 配置

### 目录结构
```
cicd/k8s/
├── kustomization.yaml          # 主配置文件
├── namespace.yaml              # 命名空间
├── ingress.yaml               # Ingress配置
├── backend/                   # 后端配置
│   ├── deployment.yaml
│   ├── service.yaml
│   └── kustomization.yaml
├── frontend/                  # 前端配置
│   ├── deployment.yaml
│   ├── service.yaml
│   └── kustomization.yaml
└── argocd/                    # ArgoCD相关
    ├── kustomization.yaml
    └── ecr-credentials.yaml   # ECR认证凭证
```

### Kustomize 常用命令
```bash
# 部署到Kubernetes
kubectl apply -k cicd/k8s/ -n ticket-dev

# 预览部署配置
kubectl kustomize cicd/k8s/

# 删除部署
kubectl delete -k cicd/k8s/ -n ticket-dev
```

## 常用命令总结

### 本地开发
```bash
# 后端
cd backend && mvn spring-boot:run
# 访问: http://localhost:8080

# 前端
cd frontend && pnpm install && pnpm dev
# 访问: http://localhost:5173
```

### 测试
```bash
# 后端测试
cd backend && mvn test

# 前端测试
cd frontend && pnpm test
```

### ECR 镜像管理
```bash
# 查看镜像列表
aws ecr list-images --repository-name ticket-management-backend-dev --region ap-northeast-1
aws ecr list-images --repository-name ticket-management-frontend-dev --region ap-northeast-1

# 查看特定标签镜像
aws ecr list-images --repository-name REPO_NAME --region ap-northeast-1 | jq -r '.imageIds[] | select((.imageTag // "") | startswith("SHA_PREFIX"))'
```

### Kubernetes 运维
```bash
# 查看Pod状态
kubectl get pods -n ticket-dev

# 查看服务
kubectl get services -n ticket-dev

# 查看Ingress
kubectl get ingress -n ticket-dev

# 查看日志
kubectl logs -f deployment/backend-deployment -n ticket-dev
kubectl logs -f deployment/frontend-deployment -n ticket-dev

# 测试API
LB_URL=$(kubectl get ingress ticket-management-ingress -n ticket-dev -o jsonpath='{.status.loadBalancer.ingress[0].hostname}')
curl http://$LB_URL/api/tickets
```

## 故障排除

### GitHub Actions 常见错误

1. **AWS 凭证错误**
   ```bash
   # 检查凭证是否有效
   aws sts get-caller-identity
   ```

2. **前端依赖问题**
   ```bash
   # 重新安装依赖
   rm -rf node_modules pnpm-lock.yaml
   pnpm install --frozen-lockfile
   ```

3. **ECR 推送失败**
   - 检查 IAM 权限：`AmazonEC2ContainerRegistryPowerUser`
   - 验证区域配置：`ap-northeast-1`

### ArgoCD Image Updater 常见错误

1. **"no basic auth credentials"**
   ```bash
   # 重新创建ECR credentials
   ./scripts/setup-ecr-credentials.sh && kubectl apply -k cicd/k8s/argocd/
   ```

2. **"Invalid match option syntax"**
   - 确保注解中使用 `regexp:^[a-fA-F0-9]{40}$` 格式

3. **镜像没有自动更新**
   ```bash
   # 检查Image Updater日志
   kubectl logs -n argocd -l app.kubernetes.io/name=argocd-image-updater -f

   # 验证ECR中是否有新镜像
   aws ecr list-images --repository-name REPO_NAME --region ap-northeast-1
   ```

## 重要提醒

- **环境一致性**: 本地环境需与CI保持一致（Node.js 22, pnpm 10.18.2, Java 17）
- **标签格式**: 镜像使用完整Git commit SHA (40位)作为标签
- **权限最小化**: IAM用户仅授予必要的ECR权限
- **定期更新**: 依赖版本和AWS凭证需要定期轮换

## 完整流程监控

1. **代码推送** → GitHub Actions构建Docker镜像
2. **镜像推送** → 镜像推送到ECR并打上Git SHA标签
3. **自动检测** → ArgoCD Image Updater每2分钟检查ECR
4. **标签匹配** → 使用正则表达式匹配新镜像标签
5. **自动更新** → 更新Kubernetes deployment中的镜像版本
6. **GitOps同步** → ArgoCD确保集群状态与期望状态一致

这个自动化流程实现了从代码提交到生产部署的完全自动化，大大提高了开发效率和部署可靠性。