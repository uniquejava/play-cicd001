# CI/CD 流程

## 核心流程

```
代码推送 → GitHub Actions CI → 构建Docker镜像 → 推送到ECR → ArgoCD Image Updater检测 → 自动更新K8s部署
```

## GitHub Actions 配置

**文件位置**: `.github/workflows/ci.yml`

### 触发条件
- `main` 分支推送：完整 CI/CD（测试+构建+推送）
- `develop` 分支推送：仅测试
- PR 到 `main`：测试验证

### 关键配置
```yaml
env:
  AWS_REGION: ap-northeast-1
  ECR_REGISTRY: 488363440930.dkr.ecr.ap-northeast-1.amazonaws.com
```

## AWS 凭证配置

### GitHub Secrets 设置
1. Repository → Settings → Secrets and variables → Actions
2. 添加 secrets：
   - `AWS_ACCESS_KEY_ID`
   - `AWS_SECRET_ACCESS_KEY`

### 快速创建 IAM 用户
```bash
aws iam create-user --user-name GitHubActions
aws iam attach-user-policy --user-name GitHubActions --policy-arn arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryPowerUser
aws iam create-access-key --user-name GitHubActions
```

## 常用命令

### 本地测试
```bash
# 后端
cd backend && mvn test

# 前端
cd frontend && pnpm install --frozen-lockfile && pnpm test
```

### ECR 镜像管理
```bash
# 查看镜像列表
aws ecr list-images --repository-name ticket-management-backend-dev --region ap-northeast-1
aws ecr list-images --repository-name ticket-management-frontend-dev --region ap-northeast-1

# 查看特定标签镜像
aws ecr list-images --repository-name REPO_NAME --region ap-northeast-1 | jq -r '.imageIds[] | select((.imageTag // "") | startswith("SHA_PREFIX"))'
```

### CI 监控
```bash
# GitHub Actions CLI (需要安装 gh)
gh run list --repo uniquejava/play-cicd001
gh run view --repo uniquejava/play-cicd001 RUN_ID

# 查看最新运行状态
gh run list --repo uniquejava/play-cicd001 --limit 5
```

## 故障排除

### 常见错误解决

**1. AWS 凭证错误**
```bash
# 检查凭证是否有效
aws sts get-caller-identity
```

**2. 前端依赖问题**
```bash
# 重新安装依赖
rm -rf node_modules pnpm-lock.yaml
pnpm install --frozen-lockfile
```

**3. ECR 推送失败**
- 检查 IAM 权限：`AmazonEC2ContainerRegistryPowerUser`
- 验证区域配置：`ap-northeast-1`

### 调试技巧

**查看 CI 日志关键信息**
- 检查构建时间：正常 1-2 分钟
- 确认镜像标签格式：`${COMMIT_SHA}` (40位)
- 验证 ECR 推送状态：应包含 "✅ Backend/Frontend image" 消息

**本地验证构建**
```bash
# 手动构建验证
docker build -f cicd/docker/backend/Dockerfile -t test-backend ./backend
docker build -f cicd/docker/frontend/Dockerfile -t test-frontend ./frontend
```

## 重要提醒

- **环境一致性**：本地环境需与 CI 保持一致（Node.js 22, pnpm 10.18.2, Java 17）
- **标签格式**：镜像使用完整 Git commit SHA (40位) 作为标签
- **权限最小化**：IAM 用户仅授予必要的 ECR 权限
- **定期更新**：依赖版本和 AWS 凭证需要定期轮换

## 自动化部署

ArgoCD Image Updater 每2分钟检查 ECR 新镜像，自动匹配符合 `^[a-fA-F0-9]{40}$` 正则的标签并更新部署。

完整流程监控：GitHub Actions → ECR → ArgoCD → Kubernetes