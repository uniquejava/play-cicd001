# Ticket Management System - 部署指南

## 🚀 项目概述

这是一个完整的CI/CD演示项目，包含前后端分离的Ticket管理系统，采用现代DevOps技术栈实现自动化部署。

## 📁 项目结构

```
play-cicd001/
├── backend/                    # Spring Boot 后端
├── frontend/                   # Vue 3 前端
├── cicd/                       # CI/CD 配置
│   ├── docker/                 # Docker 镜像配置
│   │   ├── backend/
│   │   └── frontend/
│   ├── k8s/                    # Kubernetes 部署清单
│   │   ├── namespace.yaml
│   │   ├── backend/
│   │   └── frontend/
│   ├── helm/                   # Helm Charts
│   │   └── ticket-system/
│   ├── argocd/                 # ArgoCD 配置
│   │   └── applications/
│   └── github-actions/          # GitHub Actions 工作流
├── plan.md                     # 项目实施计划
└── DEPLOYMENT.md              # 部署指南
```

## 🔧 技术栈

- **后端**: Java 17 + Spring Boot 3.5.6
- **前端**: Vue 3 + TypeScript + Vite
- **容器化**: Docker
- **CI/CD**: GitHub Actions
- **编排**: Kubernetes
- **包管理**: Helm Charts
- **GitOps**: ArgoCD

## 🐳 本地开发

### 前置要求
- Java 17+
- Node.js 18+
- Maven 3.6+
- pnpm
- Docker

### 启动服务

1. **启动后端服务**:
```bash
cd backend
mvn spring-boot:run
```
访问: http://localhost:8080

2. **启动前端服务**:
```bash
cd frontend
pnpm install
pnpm dev
```
访问: http://localhost:5173

## 🐳 Docker 部署

### 构建镜像
```bash
# 构建后端镜像
docker build -t your-username/ticket-backend:latest -f cicd/docker/backend/Dockerfile ./backend

# 构建前端镜像
docker build -t your-username/ticket-frontend:latest -f cicd/docker/frontend/Dockerfile ./frontend
```

### 本地运行Docker
```bash
# 启动后端容器
docker run -d -p 8080:8080 --name ticket-backend your-username/ticket-backend:latest

# 启动前端容器
docker run -d -p 80:80 --name ticket-frontend your-username/ticket-frontend:latest
```

## ☸️ Kubernetes 部署

### 准备工作
1. 准备Kubernetes集群
2. 配置kubectl访问权限
3. 安装Helm 3.x

### 部署命名空间
```bash
kubectl apply -f cicd/k8s/namespace.yaml
```

### 使用kubectl部署
```bash
# 部署后端
kubectl apply -f cicd/k8s/backend/

# 部署前端
kubectl apply -f cicd/k8s/frontend/

# 检查部署状态
kubectl get pods -n ticket-dev
```

### 使用Helm部署
```bash
cd cicd/helm/ticket-system

# 部署到开发环境
helm upgrade --install ticket-system . \
  --namespace ticket-dev \
  --create-namespace \
  --values values-dev.yaml

# 部署到生产环境
helm upgrade --install ticket-system . \
  --namespace ticket-prod \
  --create-namespace \
  --values values-prod.yaml
```

## 🔄 CI/CD 流水线

### GitHub Actions 工作流

1. **CI Pipeline** (`cicd/github-actions/ci.yml`)
   - 自动触发：push到main/develop分支
   - 后端测试和构建
   - 前端测试和构建
   - Docker镜像构建和推送

2. **CD - 开发环境** (`cicd/github-actions/cd-dev.yml`)
   - 自动触发：push到develop分支
   - 部署到Kubernetes集群

3. **CD - 生产环境** (`cicd/github-actions/cd-prod.yml`)
   - 手动触发：创建tag
   - 使用Helm部署到生产环境

### GitHub Secrets 配置
需要在GitHub仓库中配置以下Secrets：
- `DOCKER_USERNAME`: Docker Hub用户名
- `DOCKER_PASSWORD`: Docker Hub密码
- `KUBECONFIG_DEV`: 开发环境kubeconfig (base64编码)
- `KUBECONFIG_PROD`: 生产环境kubeconfig (base64编码)

## 🚀 ArgoCD GitOps

### 安装ArgoCD
```bash
kubectl create namespace argocd
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/v2.4.0/manifests/install.yaml
```

### 配置ArgoCD项目
```bash
kubectl apply -f cicd/argocd/project.yaml
```

### 创建ArgoCD应用
```bash
kubectl apply -f cicd/argocd/applications/dev-app.yaml
```

### 监控部署
访问ArgoCD UI：`kubectl port-forward svc/argocd-server -n argocd 8080:8080`

## 🔍 健康检查

### API端点测试
```bash
# 获取所有tickets
curl http://localhost:8080/api/tickets

# 创建新ticket
curl -X POST http://localhost:8080/api/tickets \
  -H "Content-Type: application/json" \
  -d '{"title":"Test Ticket","description":"Test Description"}'
```

### Kubernetes状态检查
```bash
# 检查Pod状态
kubectl get pods -n ticket-dev

# 检查服务状态
kubectl get svc -n ticket-dev

# 查看日志
kubectl logs -f deployment/backend-deployment -n ticket-dev
```

## 📊 监控和日志

### 应用监控
- Spring Boot Actuator端点：`/actuator/health`
- Kubernetes资源监控：`kubectl top pods -n ticket-dev`
- 日志聚合：`kubectl logs -l app=ticket -n ticket-dev`

## 🛠️ 故障排除

### 常见问题

1. **前端无法连接后端**
   - 检查网络策略配置
   - 验证Service DNS解析
   - 检查跨域配置

2. **Docker镜像构建失败**
   - 确认Dockerfile路径正确
   - 检查网络连接
   - 验证基础镜像可用性

3. **Kubernetes部署失败**
   - 检查资源配额
   - 验证镜像拉取权限
   - 检查Pod资源限制

4. **ArgoCD同步失败**
   - 检查Git仓库访问权限
   - 验证ArgoCD RBAC配置
   - 检查网络连接

## 📚 参考链接

- [Spring Boot官方文档](https://spring.io/projects/spring-boot)
- [Vue.js官方文档](https://vuejs.org/)
- [Kubernetes官方文档](https://kubernetes.io/)
- [Helm官方文档](https://helm.sh/)
- [ArgoCD官方文档](https://argoproj.io/)

## 🤝 贡献

欢迎提交Issue和Pull Request来改进这个项目！

## 📄 许可证

本项目采用MIT许可证 - 查看 [LICENSE](LICENSE) 文件了解详情。