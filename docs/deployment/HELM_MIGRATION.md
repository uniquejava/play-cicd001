# 从 K8s YAML 迁移到 Helm 的说明

## 迁移概述

为了简化配置管理和避免重复维护，本项目已从使用原生 K8s YAML 文件迁移到使用 Helm Charts。

## 变更内容

### 1. 删除的文件
- `cicd/k8s/backend/` - 后端 K8s 配置
- `cicd/k8s/frontend/` - 前端 K8s 配置
- `cicd/k8s/ingress.yaml` - Ingress 配置
- `cicd/k8s/namespace.yaml` - 命名空间配置

### 2. 保留并增强的文件
- `cicd/helm/ticket-system/` - Helm Chart 配置
  - 完整的模板文件
  - 参数化的 values.yaml
  - 支持多环境部署

### 3. 更新的脚本
- `scripts/deploy.sh` - 现在使用 Helm 部署
- 移除对 `cicd/k8s/` 目录的依赖
- 添加 `HELM_DIR` 变量指向 Helm Chart

## Helm Chart 结构

```
cicd/helm/ticket-system/
├── Chart.yaml                 # Chart 元信息
├── values.yaml               # 默认配置值
├── templates/
│   ├── _helpers.tpl          # 模板助手函数
│   ├── deployment.yaml      # 部署配置
│   ├── service.yaml         # 服务配置
│   ├── ingress.yaml         # Ingress 配置
│   └── serviceaccount.yaml  # 服务账户
└── .helmignore              # Helm 忽略文件
```

## 使用方法

### 1. 开发环境部署
```bash
# 使用 deploy.sh 脚本
./scripts/deploy.sh

# 或者直接使用 Helm
cd cicd/helm/ticket-system
helm upgrade --install ticket-system . \
  --namespace ticket-dev \
  --create-namespace \
  --values values.yaml
```

### 2. 生产环境部署
```bash
cd cicd/helm/ticket-system
helm upgrade --install ticket-system . \
  --namespace ticket-prod \
  --create-namespace \
  --values values-prod.yaml
```

### 3. 自定义配置
```bash
# 使用自定义 values 文件
helm upgrade --install ticket-system . \
  --namespace ticket-dev \
  --values values.yaml \
  --values custom-values.yaml
```

## 配置参数

主要配置项在 `values.yaml` 中：

```yaml
# 副本数
replicaCount:
  backend: 1
  frontend: 1

# 镜像配置
image:
  backend:
    repository: 488363440930.dkr.ecr.ap-northeast-1.amazonaws.com/ticket-management-backend-dev
    tag: "latest"
  frontend:
    repository: 488363440930.dkr.ecr.ap-northeast-1.amazonaws.com/ticket-management-frontend-dev
    tag: "latest"

# Ingress 配置
ingress:
  enabled: true
  className: nginx
  annotations:
    nginx.ingress.kubernetes.io/backend-protocol: "HTTPS"
    nginx.ingress.kubernetes.io/ssl-redirect: "false"
  hosts:
    - host: your-domain.com
      paths:
        - path: /
          pathType: Prefix
```

## 优势

### 1. 单一数据源
- 所有配置在一个地方维护
- 避免配置不一致

### 2. 参数化部署
- 通过 values.yaml 管理环境差异
- 支持多套配置

### 3. 版本控制
- Helm 提供部署历史
- 支持回滚到之前版本

### 4. 模板化
- 减少重复配置
- 提高可维护性

## ArgoCD 集成

Helm Chart 与 ArgoCD 完美集成：

```yaml
# ArgoCD 应用配置
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: ticket-system-dev
spec:
  source:
    repoURL: https://github.com/uniquejava/play-cicd001.git
    targetRevision: main
    path: cicd/helm/ticket-system
  destination:
    server: https://kubernetes.default.svc
    namespace: ticket-dev
```

## 故障排除

### 1. Helm Chart 语法错误
```bash
# 验证 Chart 语法
helm lint cicd/helm/ticket-system

# 测试渲染模板
helm template test cicd/helm/ticket-system
```

### 2. 部署失败
```bash
# 查看详细错误信息
helm status ticket-system -n ticket-dev

# 查看历史版本
helm history ticket-system -n ticket-dev

# 回滚到上一个版本
helm rollback ticket-system -n ticket-dev
```

### 3. 配置问题
```bash
# 查看当前配置值
helm get values ticket-system -n ticket-dev

# 查看所有配置
helm get all ticket-system -n ticket-dev
```

## 迁移后的工作流程

1. **开发**: 修改 `values.yaml` 或模板文件
2. **测试**: 使用 `helm template` 验证配置
3. **部署**: 使用 `helm upgrade` 或 `deploy.sh`
4. **监控**: 检查 Pod 状态和应用健康
5. **维护**: 使用 `helm history` 和 `rollback` 管理

---

**迁移完成日期**: 2025-10-16
**迁移负责人**: Claude
**状态**: 已完成