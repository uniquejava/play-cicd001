# EKS Infrastructure with Terraform

这个Terraform配置用于在AWS上创建一个完整的EKS集群，用于部署Ticket Management System。

## 🏗️ 架构概览

- **EKS Cluster**: Kubernetes 1.32 控制平面
- **VPC**: 10.0.0.0/16 网络段
- **Subnets**:
  - 2个私有子网 (用于Worker Nodes)
  - 2个公有子网 (用于Load Balancers)
- **Worker Nodes**: 2个 t3.medium 实例 (可扩展1-3个)
- **Networking**: NAT Gateway + Internet Gateway
- **Security**: SSH访问配置

## 📋 前置要求

1. **AWS CLI**: 已安装并配置
2. **Terraform**: v1.0+
3. **kubectl**: 已安装
4. **AWS权限**:
   - EKS Full Access
   - VPC Full Access
   - EC2 Full Access
   - IAM Full Access

## 🚀 部署步骤

### 1. 初始化Terraform
```bash
cd infra
terraform init
```

### 2. 配置变量
```bash
# 复制并编辑配置文件
cp terraform.tfvars.example terraform.tfvars

# 编辑配置 (根据需要修改)
# 确保SSH密钥存在: ssh_key_name = "your-ssh-key-name"
```

### 3. 执行部署
```bash
# 查看执行计划
terraform plan

# 应用配置
terraform apply

# 输入yes确认
```

### 4. 配置kubectl
```bash
# 更新kubeconfig
aws eks --region ap-southeast-1 update-kubeconfig --name ticket-system-eks

# 验证连接
kubectl get nodes
```

## 📊 资源说明

### 主要组件
- **EKS Cluster**: 管理的Kubernetes控制平面
- **EKS Node Group**: Worker节点组
- **VPC**: 网络隔离
- **IAM Roles**: 服务角色和权限

### 网络
- **VPC CIDR**: 10.0.0.0/16
- **私有子网**: 10.0.1.0/24, 10.0.2.0/24
- **公有子网**: 10.0.101.0/24, 10.0.102.0/24

### 计算
- **实例类型**: t3.medium (2 vCPU, 4GB RAM)
- **节点数量**: 2个 (可扩展)
- **Kubernetes版本**: 1.32

## 💰 成本估算

**月度成本估算 (ap-southeast-1)**:
- EKS控制平面: ~$0.10/hour = ~$73/month
- 2x t3.medium: ~$0.0416/hour = ~$60/month
- NAT Gateway: ~$0.045/hour + 数据传输 = ~$35/month
- EIP: ~$3.65/month
- **总计**: ~$170/month

## 🛠️ 管理和维护

### 查看集群状态
```bash
kubectl cluster-info
kubectl get nodes -o wide
kubectl get pods --all-namespaces
```

### 扩展节点
```bash
# 修改 terraform.tfvars 中的 desired_size
terraform apply
```

### 删除集群
```bash
terraform destroy
```

## 🔍 故障排除

### 常见问题

1. **权限错误**: 确保AWS用户有足够的权限
2. **SSH密钥**: 确保指定的SSH密钥对存在
3. **VPC限制**: 检查区域VPC配额
4. **实例类型**: 确保选择的实例类型在区域可用

### 日志查看
```bash
# 查看Terraform日志
terraform console

# 查看AWS CloudWatch日志
aws logs describe-log-groups --log-group-name-prefix /aws/eks
```

## 📝 下一步

集群创建后，可以继续以下步骤：
1. 构建和推送Docker镜像到ECR
2. 部署应用到EKS
3. 安装ArgoCD进行GitOps
4. 配置Ingress和Load Balancer
5. 设置监控和日志

---

*注意: 请确保在生产环境中适当调整安全组和网络配置。*