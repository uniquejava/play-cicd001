# Ticket Management System

一个基于Spring Boot + Vue 3的工单管理系统，演示完整的CI/CD流程。

## 🚀 快速开始

### 环境要求
- Java 17+
- Node.js 18+
- Maven 3.6+
- pnpm

### 本地运行

1. **启动后端**:
```bash
cd backend
mvn spring-boot:run
```
访问: http://localhost:8080

2. **启动前端**:
```bash
cd frontend
pnpm install
pnpm dev
```
访问: http://localhost:5173

## 🎯 功能特性

- ✅ 工单创建、编辑、删除
- ✅ 工单状态管理（待处理、处理中、已完成）
- ✅ RESTful API
- ✅ 响应式UI设计

## 🛠️ 技术栈

**后端**:
- Java 17
- Spring Boot 3.5.6
- Maven

**前端**:
- Vue 3
- TypeScript
- Vite
- pnpm

## 📦 CI/CD

- Docker容器化
- Kubernetes部署
- GitHub Actions
- Helm Charts
- ArgoCD GitOps

详细部署文档请查看 [DEPLOYMENT.md](DEPLOYMENT.md)

## 📁 项目结构

```
play-cicd001/
├── backend/           # Spring Boot后端
├── frontend/          # Vue 3前端
├── cicd/             # CI/CD配置
└── docs/             # 文档
```