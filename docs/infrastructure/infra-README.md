# EKS基础设施

## 架构
- **EKS Cluster**: Kubernetes 1.32
- **VPC**: 10.0.0.0/16 (2私有子网 + 2公有子网)
- **Worker Nodes**: 2x t3.medium (可扩展1-3个)
- **网络**: NAT Gateway + Internet Gateway

## 部署命令
```bash
cd infra
terraform init
terraform plan
terraform apply  # 输入yes确认
```

## 配置kubectl
```bash
aws eks --region ap-northeast-1 update-kubeconfig --name tix-eks-fresh-magpie
kubectl get nodes
```

## 成本估算
- **总计**: ~$170/月
- EKS控制平面: ~$73
- EC2实例 (2x t3.medium): ~$60
- NAT网关: ~$35

## 管理命令
```bash
# 查看集群状态
kubectl cluster-info
kubectl get nodes -o wide

# 扩展节点 (修改terraform.tfvars后)
terraform apply

# 删除集群
terraform destroy
```

## 清理资源
```bash
# 删除所有AWS资源
./cleanup-eks.sh
# 或
cd infra && terraform destroy
```

## 下一步
基础设施部署完成后：
1. 部署应用到K8s: `./scripts/deploy.sh --skip-infra`
2. 配置ArgoCD Image Updater
3. 设置CI/CD自动部署流程