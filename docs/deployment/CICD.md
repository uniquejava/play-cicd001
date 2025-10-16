# CI/CD 配置指南

本文档详细说明了 Ticket Management System 的 CI/CD 配置和设置步骤。

## 目录

- [GitHub Actions CI Pipeline](#github-actions-ci-pipeline)
- [AWS 凭证配置](#aws-凭证配置)
- [CI/CD 流程](#cicd-流程)
- [故障排除](#故障排除)

## GitHub Actions CI Pipeline

### 概述

项目使用 GitHub Actions 实现完整的 CI/CD 流水线，包括：

- ✅ **后端测试**：Maven 构建和单元测试
- ✅ **前端测试**：pnpm 安装依赖、运行测试、构建应用
- ✅ **Docker 镜像构建**：构建后端和前端 Docker 镜像
- ✅ **ECR 推送**：自动推送镜像到 AWS ECR

### 触发条件

CI Pipeline 在以下情况下触发：

- **推送到 main 分支**：运行完整 CI/CD 流程（包括镜像推送）
- **推送到 develop 分支**：运行测试流程（不包括镜像推送）
- **Pull Request 到 main**：运行测试验证

### CI 配置文件

位置：`.github/workflows/ci.yml`

#### 关键配置参数

```yaml
env:
  AWS_REGION: ap-northeast-1
  ECR_REGISTRY: 488363440930.dkr.ecr.ap-northeast-1.amazonaws.com
```

#### Node.js 和 pnpm 版本

- **Node.js**: 22（与 Dockerfile 保持一致）
- **pnpm**: 10.18.2（与本地开发环境保持一致）

## AWS 凭证配置

### 步骤 1：进入 GitHub Repository Settings

1. 访问您的 GitHub 仓库：`https://github.com/uniquejava/play-cicd001`
2. 点击 **Settings** 标签页
3. 在左侧菜单中找到 **Secrets and variables** → **Actions**

### 步骤 2：添加 Repository Secrets

点击 **New repository secret** 按钮，添加以下两个 secrets：

#### Secret 1: AWS_ACCESS_KEY_ID

- **Name**: `AWS_ACCESS_KEY_ID`
- **Value**: `YOUR_AWS_ACCESS_KEY_ID`

#### Secret 2: AWS_SECRET_ACCESS_KEY

- **Name**: `AWS_SECRET_ACCESS_KEY`
- **Value**: `YOUR_AWS_SECRET_ACCESS_KEY`

> 📝 **注意**: 实际的凭证需要通过 AWS IAM 控制台创建。参考下面的 IAM 用户配置部分。

### 使用 AWS CLI 创建 IAM 用户

如果您有 AWS CLI 访问权限，可以使用以下命令快速创建 GitHub Actions 用户：

```bash
# 1. 创建 GitHubActions IAM 用户
aws iam create-user --user-name GitHubActions --region ap-northeast-1

# 2. 附加 ECR 权限策略
aws iam attach-user-policy --user-name GitHubActions --policy-arn arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryPowerUser --region ap-northeast-1

# 3. 创建访问密钥
aws iam create-access-key --user-name GitHubActions --region ap-northeast-1
```

#### 输出示例

创建访问密钥后的输出：
```json
{
    "AccessKey": {
        "UserName": "GitHubActions",
        "AccessKeyId": "AKIA...",
        "Status": "Active",
        "SecretAccessKey": "...",
        "CreateDate": "2025-10-16T11:11:01+00:00"
    }
}
```

> ⚠️ **重要**: 将输出的 `AccessKeyId` 和 `SecretAccessKey` 复制到 GitHub Secrets 中。

### AWS IAM 用户配置

#### 用户信息

- **用户名**: GitHubActions
- **ARN**: `arn:aws:iam::488363440930:user/GitHubActions`
- **权限策略**: AmazonEC2ContainerRegistryPowerUser

#### 权限说明

此 IAM 用户具有以下权限：

- 推送和拉取 ECR 镜像
- 创建和管理 ECR repositories
- 执行镜像漏洞扫描
- 管理镜像标签和生命周期

## CI/CD 流程

### 完整流程图

```
代码推送 → GitHub Actions →
├── 后端测试 (Maven)
├── 前端测试 (pnpm + Vitest)
├── Docker 镜像构建
│   ├── 后端镜像构建
│   └── 前端镜像构建
└── ECR 推送 (main 分支)
    ├── 后端镜像推送
    └── 前端镜像推送
```

### 1. 后端测试流程

```bash
cd backend
mvn test                    # 运行单元测试
mvn clean package -DskipTests  # 构建 JAR 文件
```

### 2. 前端测试流程

```bash
cd frontend
pnpm install --frozen-lockfile  # 安装依赖（使用锁定版本）
pnpm test                      # 运行 Vitest 测试
pnpm build                     # 构建生产版本
```

### 3. Docker 镜像构建

#### 后端镜像

- **构建上下文**: `./backend`
- **Dockerfile**: `cicd/docker/backend/Dockerfile`
- **标签**: `${ECR_REGISTRY}/ticket-management-backend-dev:${COMMIT_SHA}`

#### 前端镜像

- **构建上下文**: `./frontend`
- **Dockerfile**: `cicd/docker/frontend/Dockerfile`
- **标签**: `${ECR_REGISTRY}/ticket-management-frontend-dev:${COMMIT_SHA}`

### 4. ECR 推送

镜像会自动推送到以下 ECR repositories：

- `488363440930.dkr.ecr.ap-northeast-1.amazonaws.com/ticket-management-backend-dev`
- `488363440930.dkr.ecr.ap-northeast-1.amazonaws.com/ticket-management-frontend-dev`

## 本地开发

### 环境要求

确保本地开发环境与 CI 环境一致：

- **Node.js**: 22
- **pnpm**: 10.18.2
- **Java**: 17
- **Maven**: 3.8+

### 验证本地测试

```bash
# 后端测试
cd backend
mvn test

# 前端测试
cd frontend
pnpm install --frozen-lockfile
pnpm test
```

## 故障排除

### 常见问题

#### 1. 前端测试失败

**问题**: Vitest 依赖冲突错误
```
TypeError: Cannot read properties of undefined (reading 'get')
```

**解决方案**:
- 确保 Node.js 版本与 CI 一致（v22）
- 确保 pnpm 版本与 CI 一致（v10.18.2）
- 重新安装依赖：`rm -rf node_modules && pnpm install --frozen-lockfile`

#### 2. AWS 凭证错误

**问题**:
```
Error: Credentials could not be loaded, please check your action inputs
```

**解决方案**:
- 检查 GitHub Secrets 中的 `AWS_ACCESS_KEY_ID` 和 `AWS_SECRET_ACCESS_KEY`
- 确保 AWS IAM 用户具有正确的 ECR 权限
- 验证 AWS 区域配置（ap-northeast-1）

#### 3. Docker 标签格式错误

**问题**:
```
ERROR: failed to build: invalid tag "/image:tag": invalid reference format
```

**解决方案**:
- 这是 AWS 凭证未配置时的正常行为
- CI 会跳过镜像构建步骤，专注于测试
- 配置正确的 AWS 凭证即可解决

#### 4. pnpm lockfile 兼容性问题

**问题**:
```
ERR_PNPM_NO_LOCKFILE Cannot install with "frozen-lockfile" because pnpm-lock.yaml is absent
```

**解决方案**:
- 确保 pnpm 版本在本地和 CI 中一致
- 使用 `pnpm install --frozen-lockfile` 确保依赖版本锁定

### 监控和日志

#### GitHub Actions 日志

1. 访问仓库的 **Actions** 标签页
2. 点击具体的 workflow 运行记录
3. 查看各个步骤的详细日志

#### AWS CloudTrail 监控

- 监控 GitHub Actions IAM 用户的 API 调用
- 检查 ECR 相关操作的审计日志

## 安全最佳实践

### 1. 密钥管理

- ✅ 使用 GitHub Secrets 存储敏感信息
- ✅ 定期轮换 AWS 凭证
- ✅ 使用最小权限原则

### 2. 依赖安全

- ✅ 使用 `--frozen-lockfile` 确保依赖版本固定
- ✅ 定期更新依赖包
- ✅ 使用镜像漏洞扫描

### 3. 代码安全

- ✅ 在 PR 中强制运行测试
- ✅ 使用 protected 分支保护 main 分支
- ✅ 定期审查 GitHub Actions 配置

## 扩展配置

### 环境变量

可以在 `.github/workflows/ci.yml` 中添加更多环境变量：

```yaml
env:
  AWS_REGION: ap-northeast-1
  ECR_REGISTRY: 488363440930.dkr.ecr.ap-northeast-1.amazonaws.com
  # 添加更多环境变量
  NODE_ENV: test
  MAVEN_OPTS: "-Dmaven.repo.local=$HOME/.m2/repository"
```

### 条件执行

可以根据不同条件调整 CI 行为：

```yaml
- name: Deploy to Production
  if: github.ref == 'refs/heads/main' && github.event_name == 'push'
  run: echo "Deploying to production"
```

## 联系和支持

如果遇到问题，请：

1. 检查 GitHub Actions 日志
2. 验证 AWS 凭证配置
3. 确认本地环境与 CI 环境一致性
4. 查看项目 Issue 或创建新的 Issue

---

**最后更新**: 2025-10-16
**维护者**: cyper <uniquejava@gmail.com>