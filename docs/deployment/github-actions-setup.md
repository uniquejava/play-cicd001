# GitHub Actions配置

## Secrets配置
在GitHub仓库Settings > Secrets中添加：
```bash
AWS_ACCESS_KEY_ID=<your-key>
AWS_SECRET_ACCESS_KEY=<your-secret>
```

## 创建IAM用户
```bash
aws iam create-user --user-name cicd-github-actions
aws iam attach-user-policy --user-name cicd-github-actions --policy-arn arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryPowerUser
aws iam create-access-key --user-name cicd-github-actions
```

## CI流程
- **触发**: push到main/develop分支，PR到main
- **测试**: 后端(Maven) + 前端(pnpm)
- **构建**: Docker镜像 + ECR推送

## 监控命令
```bash
# 查看运行状态
gh run list --repo uniquejava/play-cicd001

# 查看具体运行
gh run view <run-id> --repo uniquejava/play-cicd001

# 重新运行失败workflow
gh run rerun <run-id> --repo uniquejava/play-cicd001
```

## ECR镜像地址
```bash
# 后端
488363440930.dkr.ecr.ap-northeast-1.amazonaws.com/ticket-management-backend-dev

# 前端
488363440930.dkr.ecr.ap-northeast-1.amazonaws.com/ticket-management-frontend-dev
```

## 故障排除
```bash
# 检查权限
aws sts get-caller-identity

# 检查ECR仓库
aws ecr describe-repositories --repository-names ticket-management-backend-dev

# 测试ECR登录
aws ecr get-login-password --region ap-northeast-1 | docker login --username AWS --password-stdin 488363440930.dkr.ecr.ap-northeast-1.amazonaws.com
```