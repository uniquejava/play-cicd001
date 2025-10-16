# 自动化脚本

## 主要脚本

### 一键部署
```bash
./scripts/deploy.sh                    # 完整部署（基础设施+应用）
./scripts/deploy.sh --skip-infra       # 仅部署应用到现有集群
./scripts/deploy.sh --skip-apps        # 仅部署基础设施
```

### 一键删除
```bash
./scripts/destroy.sh                   # 删除所有资源
```

### ECR凭据管理
```bash
./scripts/setup-ecr-credentials.sh    # 生成ECR credentials
```

## 功能脚本

### Docker构建
```bash
./scripts/docker/build-frontend.sh production   # 生产构建
./scripts/docker/build-frontend.sh development  # 开发构建
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

## 前置要求
- AWS CLI已配置
- kubectl已配置
- Terraform已安装
- Docker已安装