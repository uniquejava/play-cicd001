# ArgoCD 实战指南

本文档包含 ArgoCD 和 ArgoCD Image Updater 的实战命令和注意事项。

## 核心概念

### ArgoCD Image Updater 工作原理
- **检查间隔**: 每2分钟检查一次容器注册表
- **更新策略**: `newest-build` 基于镜像构建时间选择最新镜像
- **标签匹配**: 使用正则表达式过滤允许的镜像标签
- **GitOps流程**: 自动更新集群中的应用并同步到Git仓库

### 支持的更新策略
- `semver`: 语义版本控制 (适用于 1.2.3 格式)
- `newest-build`: 最新构建 (适用于 Git commit SHA)
- `digest`: 摘要更新 (适用于 mutable 标签如 latest)
- `alphabetical`: 字母序排序 (适用于日期格式如 2024-01-01)

## 关键配置

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

### ECR 认证配置
```yaml
# registries.conf
registries:
- name: ECR
  api_url: https://ACCOUNT.dkr.ecr.REGION.amazonaws.com
  prefix: ACCOUNT.dkr.ecr.REGION.amazonaws.com
  ping: yes
  credentials: pullsecret:argocd/ecr-credentials
```

## 实用命令

### 1. 集群管理
```bash
# 查看所有 ArgoCD 资源
kubectl get all -n argocd

# 查看 ArgoCD 应用状态
kubectl get applications -n argocd
kubectl get application ticket-system-dev -n argocd -o yaml

# 查看 Image Updater Pod 状态
kubectl get pods -n argocd -l app.kubernetes.io/name=argocd-image-updater

# 部署/更新 ECR Credentials (Image Updater 需要)
./scripts/setup-ecr-credentials.sh && kubectl apply -k cicd/k8s/argocd/
```

### 2. 日志调试
```bash
# Image Updater 日志 (最重要的调试工具)
kubectl logs -n argocd -l app.kubernetes.io/name=argocd-image-updater -f

# ArgoCD 应用控制器日志
kubectl logs -n argocd -l app.kubernetes.io/name=argocd-application-controller -f

# 查看最近的错误
kubectl logs -n argocd -l app.kubernetes.io/name=argocd-image-updater --tail=50
```

### 3. ECR 认证管理
```bash
# 创建 Docker pull secret (推荐方式)
kubectl create secret docker-registry ecr-credentials \
  --docker-server=ACCOUNT.dkr.ecr.REGION.amazonaws.com \
  --docker-username=AWS \
  --docker-password=$(aws ecr get-login-password -- REGION) \
  -n argocd

# 验证 secret 格式
kubectl get secret ecr-credentials -n argocd -o yaml | grep .dockerconfigjson

# 删除并重新创建 secret
kubectl delete secret ecr-credentials -n argocd
```

### 4. 配置管理
```bash
# 应用 ArgoCD 配置
kubectl apply -f cicd/argocd/applications/dev-app.yaml

# 更新 registries.conf 配置
kubectl patch configmap argocd-image-updater-config -n argocd --patch '{"data":{"registries.conf":"..."}}'

# 重启 Image Updater 使配置生效
kubectl delete pod -n argocd -l app.kubernetes.io/name=argocd-image-updater
```

### 5. 镜像更新调试
```bash
# 手动触发 Image Updater 检查 (重启Pod)
kubectl delete pod -n argocd -l app.kubernetes.io/name=argocd-image-updater

# 查看当前镜像版本
kubectl get deployments -n ticket-dev -o yaml | grep image:

# 查看应用同步状态
kubectl get application ticket-system-dev -n argocd -o yaml | grep -A 10 -B 10 images
```

## 故障排除

### 常见错误和解决方案

#### 1. "Invalid match option syntax"
**症状**: 日志显示 `Invalid match option syntax '^[a-fA-F0-9]+$', ignoring`
**原因**: 正则表达式缺少 `regexp:` 前缀
**解决**: 确保注解中使用 `regexp:^[a-fA-F0-9]{40}$` 格式

#### 2. "no basic auth credentials"
**症状**: 日志显示 `Could not get tags from registry: no basic auth credentials`
**原因**: ECR 认证配置错误或 token 过期
**解决**:
```bash
# 方法1: 使用自动化脚本 (推荐)
./scripts/setup-ecr-credentials.sh && kubectl apply -k cicd/k8s/argocd/

# 方法2: 手动创建
kubectl delete secret ecr-credentials -n argocd
kubectl create secret docker-registry ecr-credentials \
  --docker-server=488363440930.dkr.ecr.ap-northeast-1.amazonaws.com \
  --docker-username=AWS \
  --docker-password=$(aws ecr get-login-password --region ap-northeast-1) \
  -n argocd

# 重启 Image Updater
kubectl delete pod -n argocd -l app.kubernetes.io/name=argocd-image-updater
```

#### 3. "Could not set registry endpoint credentials: invalid secret definition"
**症状**: Image Updater 无法读取 secret
**原因**: Secret 格式错误或引用路径不正确
**解决**:
- 确保 secret 类型为 `kubernetes.io/dockerconfigjson`
- 确保配置中使用 `pullsecret:argocd/ecr-credentials` 格式

#### 4. "Unknown sort option version"
**症状**: 日志显示警告但能正常工作
**原因**: 使用了旧的策略名称
**解决**: 将 `version` 改为 `semver` 或 `newest-build`

#### 5. 镜像没有自动更新
**诊断步骤**:
```bash
# 1. 检查 Image Updater 日志
kubectl logs -n argocd -l app.kubernetes.io/name=argocd-image-updater -f

# 2. 验证 ECR 中是否有新镜像
aws ecr list-images --repository-name REPO_NAME --region REGION

# 3. 检查正则表达式是否匹配新标签
aws ecr list-images --repository-name REPO_NAME --region REGION | jq -r '.imageIds[] | select((.imageTag // "") | startswith("SHA_PREFIX"))'

# 4. 验证应用注解是否正确
kubectl get application APP_NAME -n argocd -o yaml | grep argocd-image-updater
```

## 性能优化

### 1. 减少检查频率
```yaml
# 环境变量设置检查间隔 (默认2分钟)
env:
- name: ARGOCD_IMAGE_UPDATER_INTERVAL
  value: "5m"
```

### 2. 优化镜像标签策略
- 使用具体的正则表达式而不是 `.*`
- 避免使用 `latest` 标签
- 对于 Git SHA，使用精确长度匹配如 `^[a-f0-9]{40}$`

## 最佳实践

### 1. 标签命名规范
- **开发环境**: 使用完整 Git commit SHA (40位)
- **生产环境**: 使用语义版本 + Git SHA 短格式 (如 `v1.2.3-abc1234`)

### 2. 安全考虑
- 使用最小权限原则配置 AWS 凭证
- 定期轮换 ECR 凭证
- 监控 Image Updater 日志中的异常访问

### 3. 监控和告警
```bash
# 监控 Image Updater 健康状态
kubectl get pods -n argocd -l app.kubernetes.io/name=argocd-image-updater

# 检查应用同步状态
kubectl argocd app list --status Synced
kubectl argocd app get ticket-system-dev
```

### 4. 备份和恢复
```bash
# 备份 ArgoCD 配置
kubectl get application -n argocd -o yaml > argocd-apps-backup.yaml
kubectl get configmap -n argocd argocd-image-updater-config -o yaml > image-updater-config-backup.yaml

# 恢复配置
kubectl apply -f argocd-apps-backup.yaml
kubectl apply -f image-updater-config-backup.yaml

# 恢复 ECR credentials (如果需要)
./scripts/setup-ecr-credentials.sh && kubectl apply -k cicd/k8s/argocd/
```

## 工作流程总结

1. **代码推送** → GitHub Actions 构建 Docker 镜像
2. **镜像推送** → 镜像推送到 ECR 并打上 Git SHA 标签
3. **自动检测** → ArgoCD Image Updater 每2分钟检查 ECR
4. **标签匹配** → 使用正则表达式匹配新镜像标签
5. **自动更新** → 更新 Kubernetes deployment 中的镜像版本
6. **GitOps同步** → ArgoCD 确保集群状态与期望状态一致

## 🔧 ECR Credentials 自动化

ArgoCD Image Updater 需要有效的 ECR 访问凭证来自动拉取镜像信息。项目已提供完整的自动化解决方案：

### 自动化脚本
```bash
# 生成并部署 ECR credentials
./scripts/setup-ecr-credentials.sh && kubectl apply -k cicd/k8s/argocd/
```

### 定期维护
- **Token 时效**: ECR token 12小时过期，建议每天运行一次脚本
- **自动化**: 可通过 cron job 定期更新 token
- **监控**: Image Updater 日志会显示认证状态

这个自动化流程实现了从代码提交到生产部署的完全自动化，大大提高了开发效率和部署可靠性。