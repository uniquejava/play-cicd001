# GitHub Actions CI/CD 配置指南

本文档说明如何配置GitHub Actions来实现完整的CI/CD流程。

## 📋 前置要求

1. GitHub仓库已创建并包含项目代码
2. AWS CLI已配置并有相应权限
3. 项目已部署到EKS集群

## 🔧 GitHub Secrets 配置

在GitHub仓库中设置以下Secrets：

### 1. AWS凭证
```bash
# 在GitHub仓库设置中添加以下Secrets
AWS_ACCESS_KEY_ID: <your-aws-access-key-id>
AWS_SECRET_ACCESS_KEY: <your-aws-secret-access-key>
```

### 2. 获取AWS凭证
```bash
# 创建具有必要权限的IAM用户
aws iam create-user --user-name cicd-github-actions

# 添加必要策略
aws iam attach-user-policy --user-name cicd-github-actions --policy-arn arn:aws:iam::aws:policy/AWSCodeBuildDeveloperAccess
aws iam attach-user-policy --user-name cicd-github-actions --policy-arn arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryFullAccess

# 创建访问密钥
aws iam create-access-key --user-name cicd-github-actions
```

## 🚀 CI Pipeline 功能

### CI流程 (`cicd/github-actions/ci.yml`)

**触发条件**:
- Push到 `main` 或 `develop` 分支
- Pull Request到 `main` 分支

**执行步骤**:

1. **后端测试和构建**
   - 设置JDK 17
   - 运行Maven测试: `mvn test`
   - 构建JAR文件: `mvn package`

2. **前端测试和构建**
   - 设置Node.js 18
   - 安装pnpm
   - 运行前端测试: `pnpm test`
   - 构建前端: `pnpm build`

3. **Docker镜像构建和推送** (仅在main分支)
   - 登录Amazon ECR
   - 构建并推送后端镜像
   - 构建并推送前端镜像
   - 更新Kubernetes manifests

## 📊 构建产物

### Docker镜像标签
- `latest`: 最新版本
- `<git-sha>`: 基于Git提交哈希的版本

### ECR仓库地址
```bash
# 后端
488363440930.dkr.ecr.ap-northeast-1.amazonaws.com/ticket-management-backend-dev

# 前端
488363440930.dkr.ecr.ap-northeast-1.amazonaws.com/ticket-management-frontend-dev
```

## 🔍 监控和调试

### 查看CI运行状态
1. 进入GitHub仓库
2. 点击 "Actions" 标签
3. 查看workflow运行历史和日志

### 常见问题

**权限问题**:
```bash
# 检查IAM用户权限
aws iam list-attached-user-policies --user-name cicd-github-actions
```

**ECR推送失败**:
- 确保ECR仓库已存在
- 检查AWS凭证是否正确
- 验证区域设置是否正确

**构建失败**:
- 检查项目依赖是否完整
- 验证Dockerfile是否正确
- 查看详细的构建日志

## 🔄 工作流程

### 开发流程
1. 在本地完成开发和测试
2. 创建功能分支: `git checkout -b feature/new-feature`
3. 提交代码并推送: `git push origin feature/new-feature`
4. 创建Pull Request到main分支
5. CI自动运行测试和构建
6. PR合并后自动构建和推送Docker镜像

### 部署流程
1. CI完成后，镜像自动推送到ECR
2. Kubernetes manifests自动更新镜像标签
3. 使用ArgoCD或kubectl部署到集群

## 📈 性能优化

### 构建缓存
- Maven依赖缓存
- Node.js依赖缓存
- Docker层缓存

### 并行执行
- 前后端测试并行运行
- 构建步骤串行执行

## 🛡️ 安全考虑

- 使用IAM角色而非访问密钥（推荐）
- 限制IAM权限范围
- 使用GitHub Secrets管理敏感信息
- 定期轮换访问密钥

## 📝 示例配置

### .github/workflows/ci.yml (已配置)
完整的CI流程配置，包含测试、构建和镜像推送。

### .github/workflows/cd-dev.yml
开发环境自动部署配置。

### .github/workflows/cd-prod.yml
生产环境手动部署配置。

---

**注意事项**:
1. 确保AWS凭证具有最小必要权限
2. 定期更新GitHub Actions版本
3. 监控构建失败情况
4. 设置构建通知

**最后更新**: 2025-10-16