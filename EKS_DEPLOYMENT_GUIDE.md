# EKS部署指南

## 🚀 快速开始

### 前置条件检查
```bash
# 1. 检查AWS CLI配置
aws sts get-caller-identity

# 2. 检查Terraform
terraform version

# 3. 检查kubectl
kubectl version --client
```

### 部署步骤

#### 1. 初始化Terraform
```bash
cd infra
terraform init
```

#### 2. 检查执行计划
```bash
terraform plan
```

#### 3. 部署EKS集群
```bash
terraform apply
# 输入yes确认
```

#### 4. 配置kubectl
```bash
aws eks --region ap-southeast-1 update-kubeconfig --name ticket-system-eks
kubectl get nodes
```

## 📊 成本监控

### 月度成本估算
- **EKS控制平面**: ~$73/月
- **2x t3.medium**: ~$60/月
- **NAT Gateway**: ~$35/月
- **EIP**: ~$3.65/月
- **数据传输**: ~$5-10/月
- **总计**: ~$170/月

### 实时成本检查
```bash
# AWS Cost Explorer (控制台)
# 或使用AWS CLI查询账单
aws ce get-cost-and-usage --time-period Start=2025-10-15,End=2025-10-16 --granularity=DAILY
```

## 🧹 清理资源

### 方法1: 使用清理脚本 (推荐)
```bash
# 在项目根目录执行
./cleanup-eks.sh
```

### 方法2: 使用Terraform
```bash
cd infra
terraform destroy
```

### 手动清理 (紧急情况)
```bash
# 删除EKS集群
aws eks delete-cluster --name ticket-system-eks --region ap-southeast-1

# 删除VPC和网络安全组
aws ec2 delete-vpc --vpc-id <vpc-id> --region ap-southeast-1
```

## 📋 资源标签

所有AWS资源都标记了以下标签：
- `Project`: ticket-management
- `Environment`: dev
- `ManagedBy`: terraform
- `Owner`: PES-SongBai
- `CreatedAt`: 2025-10-15
- `Purpose`: CI-CD-Demo

这些标签便于：
1. 成本分配和追踪
2. 资源管理和查找
3. 自动化清理脚本识别

## 🛠️ 故障排除

### 常见问题

1. **权限不足**: 确保AWS用户有以下权限
   - AmazonEKSFullAccess
   - AmazonVPCFullAccess
   - AmazonEC2FullAccess
   - IAMFullAccess

2. **SSH密钥不存在**: 确保monitoring-key.pem存在或在AWS中创建

3. **配额限制**: 检查VPC、EKS、EC2实例配额

4. **网络问题**: 确保选择的区域支持EKS和所选实例类型

### 日志查看
```bash
# 查看Terraform日志
terraform console

# 查看EKS控制平面日志
aws logs describe-log-groups --log-group-name-prefix /aws/eks --region ap-southeast-1

# 查看CloudFormation堆栈
aws cloudformation list-stacks --region ap-southeast-1
```

## 📞 联系信息

- **Owner**: PES-SongBai
- **项目**: Ticket Management System CI/CD Demo
- **创建时间**: 2025-10-15

---

⚠️ **重要提醒**: 下班或不使用时，请务必运行 `./cleanup-eks.sh` 删除所有资源以避免产生不必要的费用！