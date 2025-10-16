# EKS部署指南

## 快速部署
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

## 部署应用
```bash
# 一键部署（基础设施+应用）
./scripts/deploy.sh

# 仅部署应用到现有集群
./scripts/deploy.sh --skip-infra
```

## 成本估算
- **总计**: ~$170/月
- EKS控制平面: ~$73
- EC2实例 (2x t3.medium): ~$60
- NAT网关: ~$35

## 清理资源（重要！）
```bash
./cleanup-eks.sh
# 或
cd infra && terraform destroy
```

## 验证部署
```bash
kubectl get pods -n ticket-dev
kubectl get ingress -n ticket-dev

# 测试API
LB_URL=$(kubectl get ingress ticket-management-ingress -n ticket-dev -o jsonpath='{.status.loadBalancer.ingress[0].hostname}')
curl http://$LB_URL/api/tickets
```