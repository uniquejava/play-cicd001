# Ticket Management System

[English](README.md) | [简体中文](README.zh-CN.md)

A modern ticket management system based on Spring Boot + Vue 3, demonstrating complete DevOps and CI/CD workflows.

**Development:**
[![Dev CI](https://github.com/uniquejava/play-cicd001/actions/workflows/ci.yml/badge.svg?branch=develop)](https://github.com/uniquejava/play-cicd001/actions/workflows/ci.yml)

**Production:**
[![Prod CI](https://github.com/uniquejava/play-cicd001/actions/workflows/ci.yml/badge.svg?branch=main)](https://github.com/uniquejava/play-cicd001/actions/workflows/ci.yml)


![screenshot](./docs/screenshot.jpg)

## 🎯 Project Overview

This is a **microservices architecture** project with separated frontend and backend, showcasing complete DevOps practices from development to production:

- 🏗️ **Modern Architecture**: Spring Boot 3.5.6 + Vue 3 + TypeScript
- 🚀 **Containerized Deployment**: Docker + Kubernetes + EKS
- 🔄 **CI/CD Pipeline**: GitHub Actions + Kubernetes + ArgoCD
- 📊 **Observability**: Log monitoring + Health checks
- 🛡️ **Security Best Practices**: Principle of least privilege + Security scanning

## ⚡ Quick Start

### 📋 Prerequisites

- **AWS CLI**: Configured credentials
- **kubectl**: Kubernetes command line tool
- **Terraform**: Infrastructure as code tool
- **Docker**: Containerization tool
- **Helm**: Kubernetes package manager

### 🚀 One-Click Deployment

```bash
# Clone project
git clone <repository-url>
cd play-cicd001

# Complete deployment (infrastructure + applications)
./scripts/deploy.sh

# Access application
# Frontend: http://<load-balancer-address>/
# Backend API: http://<load-balancer-address>/api/tickets
```

### 🔧 Local Development

```bash
# Start backend (port: 8080)
cd backend
mvn spring-boot:run

# Start frontend (port: 5173)
cd frontend
pnpm install && pnpm dev
```

## 🏗️ System Architecture

### Technology Stack

**Backend (Spring Boot)**
- Java 17 + Spring Boot 3.5.6
- Maven build tool
- RESTful API design
- In-memory data storage (for demo)
- Health check endpoints

**Frontend (Vue 3)**
- Vue 3 + Composition API + TypeScript
- Vite 7.1.7 + pnpm
- Responsive UI design
- API service encapsulation

**Infrastructure (AWS)**
- Amazon EKS 1.34 (Kubernetes)
- 2x t3.medium worker nodes
- Network Load Balancer (NLB)
- NGINX Ingress Controller
- Amazon ECR (Container Registry)
- VPC + subnets + security groups

### Deployment Architecture

```
┌─────────────────┐    ┌──────────────────┐    ┌────────────────────┐
│   Frontend (Vue 3)  │────│  NGINX Ingress   │────│ Network Load Balancer │
└─────────────────┘    └──────────────────┘    └────────────────────┘
                                                        │
┌─────────────────┐    ┌──────────────────┐              │
│   Backend (Spring) │────│  K8s Services    │──────────────┘
└─────────────────┘    └──────────────────┘
```

## 📚 Documentation

### 🏗️ Core Documentation
- [**Infrastructure Deployment**](docs/INFRASTRUCTURE.md) - Terraform + EKS Complete Deployment Guide
- [**CI/CD Pipeline**](docs/CICD.md) - GitHub Actions + ArgoCD + Image Updater
- [**Automation Scripts**](docs/SCRIPTS.md) - Deployment and Management Scripts Guide
- [**CI/CD Structure**](cicd/README.md) - Complete CI/CD Directory Structure Guide

### 📋 Other Documentation
- [**Project Description**](docs/INSTRUCTION.md) - Project Background and Architecture
- [**Frontend Development**](docs/frontend-README.md) - Vue 3 Development Guide
- [**Project Plan**](docs/plan.md) - Development Milestones
- [**Kind Local Cluster**](docs/infrastructure/kind.md) - Local Development Environment

## 🛠️ Development Guide

### 📁 Project Structure

```
play-cicd001/
├── backend/                    # Spring Boot backend application
├── frontend/                  # Vue 3 frontend application
├── cicd/                      # CI/CD configurations
│   ├── docker/               # Docker build configurations
│   ├── kubernetes/           # Kubernetes manifests (Kustomize)
│   │   ├── base/             # Base configurations
│   │   ├── overlays/         # Environment-specific configs
│   │   │   ├── dev/          # Development environment
│   │   │   └── prod/         # Production environment
│   │   └── tools/            # K8s tool configurations
│   ├── argocd/               # ArgoCD GitOps configurations
│   │   ├── apps/             # ArgoCD Application definitions
│   │   └── project.yaml      # ArgoCD Project configuration
│   └── github_action/        # GitHub Actions scripts
├── infra/                     # Terraform infrastructure
│   ├── modules/              # Terraform modules
│   │   ├── vpc/              # VPC network configuration
│   │   └── ecr/              # ECR image repository
│   ├── main.tf               # Main configuration file
│   ├── variables.tf          # Variable definitions
│   └── outputs.tf            # Output configuration
├── scripts/                   # Automation scripts
│   ├── deploy.sh             # One-click deployment script
│   ├── destroy.sh            # One-click cleanup script
│   ├── docker/               # Docker build scripts
│   ├── k8s/                  # Kubernetes management scripts
│   └── terraform/            # Terraform management scripts
├── .github/workflows/         # GitHub Actions workflows
├── docs/                      # Project documentation
│   ├── INFRASTRUCTURE.md      # Terraform + EKS deployment guide
│   ├── CICD.md               # CI/CD complete workflow
│   ├── SCRIPTS.md            # Automation scripts guide
│   ├── INSTRUCTION.md        # Project background and architecture
│   └── plan.md               # Development milestones
├── records.txt                # Deployment records
├── CLAUDE.md                  # Claude Code configuration
└── cicd/README.md             # CI/CD directory structure guide
```

### 🔧 Common Commands

```bash
# 🚀 Deployment Management
./scripts/deploy.sh                               # Complete deployment (infrastructure + applications)
./scripts/deploy.sh --skip-infra                  # Deploy applications to existing cluster only
./scripts/deploy.sh --skip-apps                   # Deploy infrastructure only
./scripts/destroy.sh                              # One-click cleanup of all resources (save costs)

# 🏗️ Infrastructure Management
cd infra
terraform init                                    # Initialize Terraform
terraform plan                                    # Show execution plan
terraform apply                                   # Deploy infrastructure
terraform destroy                                 # Destroy infrastructure
aws eks --region ap-northeast-1 update-kubeconfig --name tix-eks-fresh-magpie  # Configure kubectl

# ☸️ Kubernetes Operations
kubectl get pods -n ticket-dev                    # Check pod status
kubectl get services -n ticket-dev                # Check services
kubectl get ingress -n ticket-dev                 # Check ingress
kubectl logs -f deployment/backend-deployment -n ticket-dev  # View backend logs
kubectl logs -f deployment/frontend-deployment -n ticket-dev # View frontend logs

# 🚢 ArgoCD Management
argocd app list                                   # List all applications
argocd app get ticket-system-dev                # Get application status
argocd app sync ticket-system-dev               # Manual sync application
argocd app logs ticket-system-dev               # View application sync logs
argocd cluster list                              # List clusters
kubectl get applications -n argocd               # View ArgoCD application resources
kubectl get appprojects -n argocd                # View ArgoCD projects

# 🔍 ArgoCD Image Updater Debugging
kubectl logs -n argocd -l app.kubernetes.io/name=argocd-image-updater -f  # View Image Updater logs
kubectl get pods -n argocd -l app.kubernetes.io/name=argocd-image-updater  # Check Image Updater status

# 🔐 ECR Credentials Management (ArgoCD Image Updater)
./scripts/setup-ecr-credentials.sh               # Generate ECR credentials
kubectl apply -k cicd/kubernetes/tools/argocd/   # Deploy ECR credentials to ArgoCD

# 🐳 Local Development
cd backend && mvn spring-boot:run                 # Start backend (port: 8080)
cd frontend && pnpm install && pnpm dev           # Start frontend (port: 5173)

# 🔨 Local Build
docker build -f cicd/docker/backend/Dockerfile -t ticket-backend ./backend
docker build -f cicd/docker/frontend/Dockerfile -t ticket-frontend ./frontend
./scripts/docker/build-frontend.sh production    # Frontend production build
./scripts/docker/build-frontend.sh development   # Frontend development build

# 🧪 Testing
cd backend && mvn test                            # Backend tests
cd frontend && pnpm test                          # Frontend tests
curl http://localhost:8080/api/tickets            # API testing

# 📊 Deployment Verification
LB_URL=$(kubectl get ingress ticket-management-ingress -n ticket-dev -o jsonpath='{.status.loadBalancer.ingress[0].hostname}')  # Get load balancer address
curl http://$LB_URL/api/tickets                   # Test production API
curl -I http://$LB_URL/                          # Test frontend page

# 📱 GitHub Actions Monitoring
gh run list --repo uniquejava/play-cicd001       # View CI/CD run status
gh run view <run-id> --repo uniquejava/play-cicd001  # View specific run details
gh run rerun <run-id> --repo uniquejava/play-cicd001  # Rerun failed workflow
```

## 📊 Cost Estimation

| Resource | Monthly Cost | Description |
|----------|--------------|-------------|
| EKS Control Plane | ~$73 | Kubernetes cluster management |
| EC2 Instances (2x t3.medium) | ~$60 | Worker nodes |
| NAT Gateway | ~$35 | Private subnet outbound gateway |
| EIP | ~$3.65 | Elastic IP address |
| Data Transfer | ~$5-10 | Traffic fees |
| **Total** | **~$170** | **Estimated monthly cost** |

> 💡 **Cost Control**: Run `./scripts/destroy.sh` when not using to avoid unnecessary charges.

## 🎯 Features

### Core Features
- ✅ **Ticket Management**: Create, edit, delete tickets
- ✅ **Status Tracking**: Open → In Progress → Completed
- ✅ **RESTful API**: Standardized API interfaces
- ✅ **Responsive Design**: Multi-device support
- ✅ **Real-time Updates**: Frontend-backend data synchronization

### Technical Features
- ✅ **Containerization**: Docker image building
- ✅ **Microservices**: Frontend-backend separated architecture
- ✅ **Load Balancing**: NGINX Ingress Controller
- ✅ **Health Checks**: Service status monitoring
- ✅ **Auto-scaling**: Kubernetes HPA (configurable)

## 🔄 CI/CD Pipeline

### Development Workflow
1. **Code Commit** → GitHub repository
2. **Auto Build** → GitHub Actions CI
3. **Image Build** → Docker + ECR push
4. **Auto Deploy** → ArgoCD Image Updater
5. **Service Release** → Kubernetes cluster

### Branch Strategy
- `main`: Production branch
- `develop`: Development branch
- `feature/*`: Feature development branches
- `hotfix/*`: Emergency fix branches

## 🧪 Testing

Test commands are included in the "🧪 Testing" section of the "Common Commands" above.

## 🛡️ Security Features

- **Least Privilege**: IAM role permission minimization
- **Network Isolation**: VPC private subnet deployment
- **Container Security**: Non-root user execution
- **Image Scanning**: ECR automatic security scanning
- **Secret Management**: AWS Secrets Manager (extensible)

## ⚠️ Important Reminder

Run `./scripts/destroy.sh` when not using the project to delete all AWS resources and avoid charges!

## 📄 License

This project is licensed under the MIT License.

**📅 Last Updated**: 2025-10-17