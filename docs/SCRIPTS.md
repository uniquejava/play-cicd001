# 自动化脚本使用指南

## 概述

项目提供完整的自动化脚本，支持基础设施管理、应用部署、资源清理等操作。

## 主要脚本

### 一键部署脚本

#### 完整部署 (基础设施 + 应用)
```bash
./scripts/deploy.sh
```

#### 仅部署应用到现有集群
```bash
./scripts/deploy.sh --skip-infra
```

#### 仅部署基础设施
```bash
./scripts/deploy.sh --skip-apps
```

### 一键删除脚本
```bash
./scripts/destroy.sh                   # 删除所有AWS资源和K8s资源
```

## 功能脚本

### ECR凭据管理
```bash
./scripts/setup-ecr-credentials.sh    # 生成ECR credentials (ArgoCD Image Updater需要)
```

### Docker构建
```bash
./scripts/docker/build-frontend.sh production   # 生产环境构建
./scripts/docker/build-frontend.sh development  # 开发环境构建
```

### 资源清理
```bash
./scripts/k8s/cleanup-k8s.sh           # 清理K8s资源
./scripts/terraform/cleanup-terraform.sh # 清理Terraform资源
```

## 脚本特性

- ✅ 统一管理和错误处理
- ✅ 彩色日志输出
- ✅ 依赖检查和安全确认
- ✅ 支持网络代理（emea/emea2命令）
- ✅ 交互式确认和进度显示

## 前置要求

### 必需工具
- **AWS CLI**: 已配置凭证
- **kubectl**: Kubernetes命令行工具
- **Terraform**: 基础设施即代码工具
- **Docker**: 容器化工具

### 验证环境
```bash
# 检查AWS CLI
aws sts get-caller-identity

# 检查kubectl
kubectl version --client

# 检查Terraform
terraform version

# 检查Docker
docker --version
```

## 脚本详细说明

### deploy.sh (主部署脚本)

**功能**: 一键部署整个项目或指定组件

**参数选项**:
- 无参数: 完整部署（基础设施 + 应用）
- `--skip-infra`: 仅部署应用到现有集群
- `--skip-apps`: 仅部署基础设施

**执行流程**:
1. 环境依赖检查
2. 基础设施部署（Terraform）
3. kubectl配置更新
4. Kubernetes命名空间创建
5. 应用部署（Kustomize）
6. ECR凭据配置
7. 部署状态验证

**使用示例**:
```bash
# 首次部署完整环境
./scripts/deploy.sh

# 更新应用代码（不重建基础设施）
./scripts/deploy.sh --skip-infra

# 仅重建基础设施
./scripts/deploy.sh --skip-apps
```

### destroy.sh (清理脚本)

**功能**: 一键删除所有AWS资源和Kubernetes资源

**安全特性**:
- 交互式确认：需要用户输入确认才能执行删除
- 分步删除：先删除K8s资源，再删除AWS基础设施
- 错误处理：即使部分删除失败也会继续其他步骤

**使用示例**:
```bash
./scripts/destroy.sh
# 按提示输入 'yes' 确认删除
```

### setup-ecr-credentials.sh (ECR凭据管理)

**功能**: 为ArgoCD Image Updater生成ECR访问凭证

**工作原理**:
1. 获取AWS ECR登录token
2. 创建Kubernetes Docker pull secret
3. 配置正确的secret格式供Image Updater使用

**自动化部署**:
```bash
# 生成并部署ECR credentials
./scripts/setup-ecr-credentials.sh && kubectl apply -k cicd/k8s/argocd/
```

**手动维护**:
- ECR token有效期12小时，建议每天运行一次
- 可通过cron job实现定期自动更新
- Image Updater日志会显示认证状态

### build-frontend.sh (前端构建脚本)

**功能**: 构建前端Docker镜像

**参数**:
- `production`: 生产环境构建（默认）
- `development`: 开发环境构建

**使用示例**:
```bash
# 生产构建
./scripts/docker/build-frontend.sh production

# 开发构建
./scripts/docker/build-frontend.sh development
```

## 最佳实践

### 部署顺序
1. **首次部署**: `./scripts/deploy.sh` (完整部署)
2. **代码更新**: `./scripts/deploy.sh --skip-infra` (仅应用)
3. **基础设施变更**: `./scripts/deploy.sh --skip-apps` (仅infra)

### 资源管理
1. **开发完成后**: 运行 `./scripts/destroy.sh` 清理资源
2. **定期维护**: 每天运行ECR凭据更新脚本
3. **成本控制**: 监控AWS控制台，避免资源浪费

### 故障排除
1. **权限错误**: 检查AWS凭证和IAM权限
2. **网络超时**: 使用代理命令 `emea` 或 `emea2`
3. **依赖缺失**: 按前置要求安装必需工具

### 脚本调试
```bash
# 启用详细日志
set -x  # 在脚本中添加
# 或
bash -x ./scripts/deploy.sh  # 执行时启用
```

## 目录结构

```
scripts/
├── deploy.sh                           # 主部署脚本
├── destroy.sh                          # 清理脚本
├── setup-ecr-credentials.sh            # ECR凭据管理
├── docker/
│   └── build-frontend.sh               # 前端构建脚本
├── k8s/
│   └── cleanup-k8s.sh                  # K8s资源清理
└── terraform/
    └── cleanup-terraform.sh            # Terraform资源清理
```

## 安全注意事项

1. **权限最小化**: 使用最小必要的IAM权限
2. **凭证安全**: 定期轮换AWS访问密钥
3. **资源清理**: 及时清理不需要的AWS资源
4. **网络安全**: 在安全网络环境中执行脚本

这些脚本大大简化了项目的部署和管理，实现了基础设施即代码和自动化运维的最佳实践。