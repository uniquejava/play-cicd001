# 基础设施部署指南 (Terraform + EKS)

## 概述

本项目使用 Terraform 管理 AWS EKS 基础设施，实现基础设施即代码(Infrastructure as Code)。

## 架构设计

### 部署架构

```
┌─────────────────┐    ┌──────────────────┐    ┌────────────────────┐
│   前端 (Vue 3)   │────│  NGINX Ingress   │────│ Network Load Balancer │
└─────────────────┘    └──────────────────┘    └────────────────────┘
                                                        │
┌─────────────────┐    ┌──────────────────┐              │
│  后端 (Spring)   │────│  K8s Services    │──────────────┘
└─────────────────┘    └──────────────────┘
```

### 核心组件
- **EKS Cluster**: Kubernetes 1.34
- **VPC**: 10.0.0.0/16 (2私有子网 + 2公有子网)
- **Worker Nodes**: 2x t3.medium (自动扩展1-3个)
- **网络**: NAT Gateway + Internet Gateway
- **Load Balancer**: Network Load Balancer (NLB)
- **NGINX Ingress Controller**: Kubernetes Ingress Controller
- **ECR**: Elastic Container Registry

### 费用估算
| 资源 | 月费用 | 说明 |
|------|--------|------|
| EKS控制平面 | ~$73 | Kubernetes集群管理 |
| EC2实例 (2x t3.medium) | ~$60 | 工作节点 |
| NAT网关 | ~$35 | 私有子网出网关 |
| EIP | ~$3.65 | 弹性IP地址 |
| 数据传输 | ~$5-10 | 流量费用 |
| **总计** | **~$170** | **预估月费用** |

## 一键部署

### 完整部署 (推荐)
```bash
# 部署基础设施 + 应用
./scripts/deploy.sh
```

### 手动部署
```bash
cd infra
terraform init                    # 初始化Terraform
terraform plan                    # 查看执行计划
terraform apply                   # 部署基础设施 (输入yes确认)
```

## 配置kubectl

```bash
aws eks --region ap-northeast-1 update-kubeconfig --name tix-eks-fresh-magpie
kubectl get nodes                 # 验证集群连接
```

## 部署应用到现有集群

```bash
# 仅部署应用 (跳过基础设施)
./scripts/deploy.sh --skip-infra

# 或使用kubectl直接部署
kubectl apply -k cicd/k8s/ -n ticket-dev
```

## 验证部署

```bash
# 检查Pod状态
kubectl get pods -n ticket-dev

# 检查服务
kubectl get services -n ticket-dev

# 检查Ingress
kubectl get ingress -n ticket-dev

# 测试API
LB_URL=$(kubectl get ingress ticket-management-ingress -n ticket-dev -o jsonpath='{.status.loadBalancer.ingress[0].hostname}')
curl http://$LB_URL/api/tickets
```

## Terraform 管理

### 查看集群状态
```bash
kubectl cluster-info
kubectl get nodes -o wide
```

### 扩展节点
```bash
# 修改 infra/terraform.tfvars 中的节点数量
terraform apply
```

### 资源清理 (重要！)
```bash
# 方法1: 使用清理脚本
./scripts/destroy.sh

# 方法2: 使用Terraform
cd infra && terraform destroy
```

## Terraform 配置结构

```
infra/
├── main.tf                 # 主配置文件
├── variables.tf            # 变量定义
├── outputs.tf              # 输出配置
├── terraform.tfvars        # 变量值
├── versions.tf             # Terraform版本约束
├── provider.tf             # AWS提供者配置
└── modules/                # 模块化配置
    ├── vpc/                # VPC网络模块
    │   ├── main.tf
    │   ├── variables.tf
    │   └── outputs.tf
    └── ecr/                # ECR镜像仓库模块
        ├── main.tf
        ├── variables.tf
        └── outputs.tf
```

## 标签策略

所有AWS资源都使用统一标签：
- `Project`: ticket-management
- `Environment`: dev
- `ManagedBy`: terraform
- `Owner`: PES-SongBai
- `Purpose`: CI-CD-Demo

## 最佳实践

1. **成本控制**: 不使用时运行 `./scripts/destroy.sh` 清理资源
2. **安全**: 使用IAM角色而非访问密钥
3. **监控**: 定期检查AWS账单和控制台
4. **备份**: 重要配置变更前备份状态文件

## 故障排除

### 常见问题

1. **权限错误**
   ```bash
   aws sts get-caller-identity  # 检查当前凭证
   ```

2. **Terraform状态锁定**
   ```bash
   terraform force-unlock LOCK_ID  # 强制解锁
   ```

3. **EKS集群无法连接**
   ```bash
   aws eks update-kubeconfig --region ap-northeast-1 --name tix-eks-fresh-magpie
   kubectl get nodes
   ```

## 下一步

基础设施部署完成后：
1. 部署应用到K8s: `./scripts/deploy.sh --skip-infra`
2. 配置ArgoCD和Image Updater
3. 设置CI/CD自动部署流程