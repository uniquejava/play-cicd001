# Ticket Management System

一个基于Spring Boot + Vue 3的现代化工单管理系统，演示完整的DevOps和CI/CD流程。

[![CI Pipeline](https://github.com/uniquejava/play-cicd001/actions/workflows/ci.yml/badge.svg)](https://github.com/uniquejava/play-cicd001/actions/workflows/ci.yml)


![screenshot](./docs/screenshot.jpg)

## 🎯 项目概览

这是一个**前后端分离的微服务架构**项目，展示了从开发到生产的完整DevOps实践：

- 🏗️ **现代化架构**: Spring Boot 3.5.6 + Vue 3 + TypeScript
- 🚀 **容器化部署**: Docker + Kubernetes + EKS
- 🔄 **CI/CD流水线**: GitHub Actions + Kubernetes + ArgoCD
- 📊 **可观测性**: 日志监控 + 健康检查
- 🛡️ **安全最佳实践**: 最小权限原则 + 安全扫描

## ⚡ 快速开始

### 📋 前置要求

- **AWS CLI**: 已配置凭证
- **kubectl**: Kubernetes命令行工具
- **Terraform**: 基础设施即代码工具
- **Docker**: 容器化工具
- **Helm**: Kubernetes包管理器

### 🚀 一键部署

```bash
# 克隆项目
git clone <repository-url>
cd play-cicd001

# 完整部署（基础设施 + 应用）
./scripts/deploy.sh

# 访问应用
# 前端: http://<负载均衡器地址>/
# 后端API: http://<负载均衡器地址>/api/tickets
```

### 🔧 本地开发

```bash
# 启动后端 (端口: 8080)
cd backend
mvn spring-boot:run

# 启动前端 (端口: 5173)
cd frontend
pnpm install && pnpm dev
```

## 🏗️ 系统架构

### 技术栈

**后端 (Spring Boot)**
- Java 17 + Spring Boot 3.5.6
- Maven构建工具
- RESTful API设计
- 内存数据存储（演示用）
- 健康检查端点

**前端 (Vue 3)**
- Vue 3 + Composition API + TypeScript
- Vite 7.1.7 + pnpm
- 响应式UI设计
- API服务封装

**基础设施 (AWS)**
- Amazon EKS 1.32 (Kubernetes)
- 2x t3.medium 工作节点
- Application Load Balancer
- Amazon ECR (容器镜像仓库)
- VPC + 子网 + 安全组

### 部署架构

```
┌─────────────────┐    ┌──────────────────┐    ┌─────────────────┐
│   前端 (Vue 3)   │────│  NGINX Ingress   │────│  Load Balancer  │
└─────────────────┘    └──────────────────┘    └─────────────────┘
                                                        │
┌─────────────────┐    ┌──────────────────┐              │
│  后端 (Spring)   │────│  K8s Services    │──────────────┘
└─────────────────┘    └──────────────────┘
```

## 📚 文档导航

### 🚀 部署相关
- [**部署指南**](docs/deployment/DEPLOYMENT.md) - 完整部署流程
- [**EKS部署指南**](docs/deployment/EKS_DEPLOYMENT_GUIDE.md) - AWS EKS详细步骤
- [**NGINX配置**](docs/deployment/nginx-setup.md) - Ingress Controller设置
- [**CI/CD验证**](docs/deployment/CICD_VERIFICATION.md) - 流程验证测试

### 🏗️ 基础设施
- [**基础设施文档**](docs/infrastructure/infra-README.md) - Terraform配置说明
- [**本地开发环境**](docs/infrastructure/kind.md) - Kind集群设置

### 📜 自动化脚本
- [**脚本使用指南**](docs/scripts/README.md) - 自动化脚本说明

### 📋 项目文档
- [**项目说明**](docs/INSTRUCTION.md) - 项目背景和架构
- [**前端开发指南**](docs/frontend-README.md) - Vue 3开发说明
- [**项目计划**](docs/plan.md) - 开发里程碑

## 🛠️ 开发指南

### 📁 项目结构

```
play-cicd001/
├── backend/                    # Spring Boot后端应用
│   ├── src/main/java/         # Java源代码
│   ├── src/test/              # 单元测试
│   ├── pom.xml               # Maven配置
│   └── Dockerfile            # 容器化配置
├── frontend/                  # Vue 3前端应用
│   ├── src/                   # Vue源代码
│   ├── public/               # 静态资源
│   ├── package.json          # 前端依赖
│   └── Dockerfile            # 容器化配置
├── cicd/                      # CI/CD配置文件
│   ├── docker/               # Docker构建配置
│   ├── k8s/                  # Kubernetes部署文件
│   ├── helm/                 # Helm Charts
│   └── github-actions/       # GitHub Actions工作流
├── infra/                     # Terraform基础设施
│   ├── modules/              # Terraform模块
│   ├── main.tf               # 主配置文件
│   └── variables.tf          # 变量定义
├── scripts/                   # 自动化脚本
│   ├── deploy.sh             # 一键部署脚本
│   ├── destroy.sh            # 一键删除脚本
│   └── docker/               # Docker构建脚本
├── docs/                      # 项目文档
└── CLAUDE.md                  # Claude Code配置
```

### 🔧 常用命令

```bash
# === 应用管理 ===
# 一键部署
./scripts/deploy.sh

# 一键删除（节省费用）
./scripts/destroy.sh

# 仅部署应用到现有集群
./scripts/deploy.sh --skip-infra

# === 基础设施 ===
# 初始化Terraform
cd infra && terraform init

# 查看执行计划
terraform plan

# 应用基础设施
terraform apply

# 删除基础设施
terraform destroy

# === Kubernetes ===
# 查看Pod状态
kubectl get pods -n ticket-dev

# 查看服务
kubectl get services -n ticket-dev

# 查看Ingress
kubectl get ingress -n ticket-dev

# === Docker构建 ===
# 构建前端镜像
./scripts/docker/build-frontend.sh production

# 构建后端镜像
docker build -f cicd/docker/backend/Dockerfile -t ticket-backend ./backend
```

## 📊 成本估算

| 资源 | 月费用 | 说明 |
|------|--------|------|
| EKS控制平面 | ~$73 | Kubernetes集群管理 |
| EC2实例 (2x t3.medium) | ~$60 | 工作节点 |
| NAT网关 | ~$35 | 私有子网出网关 |
| EIP | ~$3.65 | 弹性IP地址 |
| 数据传输 | ~$5-10 | 流量费用 |
| **总计** | **~$170** | **预估月费用** |

> 💡 **费用控制**: 使用完毕后请运行 `./scripts/destroy.sh` 清理资源以避免不必要的费用。

## 🎯 功能特性

### 核心功能
- ✅ **工单管理**: 创建、编辑、删除工单
- ✅ **状态追踪**: 待处理 → 处理中 → 已完成
- ✅ **RESTful API**: 标准化API接口
- ✅ **响应式设计**: 支持多设备访问
- ✅ **实时更新**: 前后端数据同步

### 技术特性
- ✅ **容器化**: Docker镜像构建
- ✅ **微服务**: 前后端分离架构
- ✅ **负载均衡**: NGINX Ingress Controller
- ✅ **健康检查**: 服务状态监控
- ✅ **自动扩缩容**: Kubernetes HPA（可配置）

## 🔄 CI/CD流水线

### 开发流程
1. **代码提交** → GitHub仓库
2. **自动构建** → GitHub Actions CI
3. **镜像构建** → Docker + ECR推送
4. **自动部署** → GitHub Actions CD
5. **服务发布** → Kubernetes集群

### 分支策略
- `main`: 生产环境分支
- `develop`: 开发环境分支
- `feature/*`: 功能开发分支
- `hotfix/*`: 紧急修复分支

## 🧪 测试

```bash
# 后端测试
cd backend && mvn test

# 前端测试
cd frontend && pnpm test

# API测试
curl http://localhost:8080/api/tickets
```

## 🛡️ 安全特性

- **最小权限**: IAM角色权限最小化
- **网络隔离**: VPC私有子网部署
- **容器安全**: 非root用户运行
- **镜像扫描**: ECR自动安全扫描
- **密钥管理**: AWS Secrets Manager（可扩展）

## 📞 支持

### 🆘 故障排除

**常见问题**:
1. **权限错误**: 检查AWS IAM权限
2. **网络超时**: 检查安全组配置
3. **部署失败**: 查看Pod日志: `kubectl logs -n ticket-dev deployment/backend-deployment`

### 📖 更多资源

- [Vue 3 官方文档](https://vuejs.org/)
- [Spring Boot 文档](https://spring.io/projects/spring-boot)
- [Kubernetes 文档](https://kubernetes.io/docs/)
- [AWS EKS 文档](https://docs.aws.amazon.com/eks/)

### 🤝 贡献

欢迎提交Issue和Pull Request来改进项目。

---

## 📄 许可证

本项目采用 MIT 许可证 - 查看 [LICENSE](LICENSE) 文件了解详情。

---

**⚠️ 重要提醒**: 在不使用项目时，请运行 `./scripts/destroy.sh` 删除所有AWS资源以避免产生费用！

**📅 最后更新**: 2025-10-16