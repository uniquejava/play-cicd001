# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a **Ticket Management System CI/CD demonstration project** showcasing modern DevOps practices with a microservices architecture (Spring Boot backend + Vue 3 frontend). The project demonstrates a complete pipeline from development to production deployment using infrastructure as code, containerization, and GitOps.

## Architecture & Technology Stack

### Backend (Spring Boot)
- **Framework**: Spring Boot 3.5.6 with Java 17
- **Build Tool**: Maven
- **Port**: 8080
- **Structure**: RESTful API with full CRUD operations
- **Key Components**:
  - `TicketController.java` - REST API endpoints with CORS support for localhost:5173, localhost:3000
  - `TicketService.java` - Business logic layer
  - `Ticket.java` - Entity model with status management (OPEN, IN_PROGRESS, COMPLETED)
  - `TicketDto.java` - Data transfer objects
  - `CreateTicketRequest.java` - Request DTOs for ticket creation

### Frontend (Vue 3)
- **Framework**: Vue 3 with Composition API and TypeScript
- **Build Tool**: Vite 7.1.7
- **Package Manager**: pnpm
- **Port**: 5173 (development), 80 (production)
- **Key Components**:
  - `App.vue` - Main application layout
  - `TicketList.vue` - Ticket management interface
  - `TicketForm.vue` - Ticket creation/editing form

## Development Commands

### Backend (Spring Boot)
```bash
cd backend
mvn clean install            # Build and run tests
mvn spring-boot:run          # Run application (port 8080)
mvn test                     # Run tests only
mvn clean package -DskipTests # Build without tests
```

### Frontend (Vue 3 + TypeScript)
```bash
cd frontend
pnpm install                 # Install dependencies
pnpm dev                     # Start development server (port 5173)
pnpm build                   # Build for production
pnpm preview                 # Preview production build
```

### Docker Containerization
```bash
# Build images
docker build -f cicd/docker/backend/Dockerfile -t ticket-backend ./backend
docker build -f cicd/docker/frontend/Dockerfile -t ticket-frontend ./frontend

# Images use multi-stage builds with security-focused non-root users
# Backend includes health checks via curl to /api/tickets
```

## CI/CD Pipeline

### GitHub Actions Workflows
- **CI Pipeline** (`cicd/github-actions/ci.yml`):
  - Triggers on push to main/develop and PRs to main
  - Tests and builds both backend (Maven) and frontend (pnpm)
  - Builds and pushes Docker images on main branch merges
  - **ECR Registry**: `488363440930.dkr.ecr.ap-northeast-1.amazonaws.com`
  - **Image Names**:
    - Backend: `ticket-management-backend-dev`
    - Frontend: `ticket-management-frontend-dev`

- **CD Pipelines** (`cicd/github-actions/cd-dev.yml`, `cicd/github-actions/cd-prod.yml`):
  - Separate deployment workflows for dev and prod environments
  - Manual trigger for production deployment

### Container Orchestration
- **Kubernetes** (`cicd/k8s/`): Separate deployments for frontend/backend with service configurations
- **Helm Charts** (`cicd/helm/`): Package management with environment-specific values
- **ArgoCD** (`cicd/argocd/`): GitOps configuration for continuous deployment

### Kubernetes Management
```bash
# Namespace and deployment management
kubectl create namespace ticket-dev --dry-run=client -o yaml | kubectl apply -f -
kubectl apply -f cicd/k8s/backend/ -n ticket-dev
kubectl apply -f cicd/k8s/frontend/ -n ticket-dev

# Monitor deployments
kubectl get pods -n ticket-dev
kubectl get services -n ticket-dev
kubectl get ingress -n ticket-dev
kubectl logs -f deployment/backend-deployment -n ticket-dev
kubectl logs -f deployment/frontend-deployment -n ticket-dev

# Cleanup
./scripts/k8s/cleanup-k8s.sh
```

## Infrastructure as Code

### Terraform EKS Setup (`/infra/`)
- **Provider**: AWS
- **Service**: EKS Kubernetes 1.32
- **Compute**: 2x t3.medium worker nodes (auto-scaling 1-3)
- **Network**: Custom VPC (10.0.0.0/16) with public/private subnets
- **Region**: ap-northeast-1
- **Estimated Cost**: ~$170/month

### Infrastructure Commands
```bash
cd infra
terraform init                                    # Initialize Terraform
terraform plan                                    # Show execution plan
terraform apply                                   # Deploy infrastructure
aws eks --region ap-northeast-1 update-kubeconfig --name tix-eks-fresh-magpie  # Configure kubectl
terraform destroy                                 # Destroy all resources
./cleanup-eks.sh                                  # Alternative cleanup script
```

### Deployment Scripts
```bash
# One-click deployment (infrastructure + applications)
./scripts/deploy.sh                               # Full deployment
./scripts/deploy.sh --skip-infra                  # Deploy apps to existing cluster
./scripts/deploy.sh --skip-apps                   # Deploy infrastructure only

# Docker builds
./scripts/docker/build-frontend.sh production     # Build frontend for production
./scripts/docker/build-frontend.sh development    # Build frontend for development
```

## Key Configuration Details

### CORS Configuration
Backend configured for local development with origins:
- `http://localhost:5173` (Vite dev server)
- `http://localhost:3000` (alternative frontend port)

### Health Checks
- Backend: `/api/tickets` endpoint check via curl every 30 seconds
- Docker: Health checks configured with 60-second start period

### Security Features
- Multi-stage Docker builds with minimal attack surface
- Non-root container users (UID 1001)
- Resource limits configured in Kubernetes deployments
- Infrastructure tags for cost tracking and resource management

### Cost Management
All AWS resources are tagged with:
- `Project`: ticket-management
- `Environment`: dev
- `ManagedBy`: terraform
- `Owner`: PES-SongBai
- `Purpose`: CI-CD-Demo

## Testing

### Backend Tests
```bash
cd backend && mvn test
```
- Uses JUnit 5 (spring-boot-starter-test)
- Single test class: `BackendApplicationTests.java`

### Frontend Tests
```bash
cd frontend && pnpm test  # Currently no tests configured
```
- Note: CI pipeline expects tests but none are currently implemented
- Test framework not yet configured in package.json

## Development Workflow

1. **Local Development**: Run backend on 8080, frontend on 5173
2. **Testing**: Ensure all tests pass before committing
3. **CI Pipeline**: Automatic on push to main/develop
4. **Docker Images**: Built and pushed automatically on main branch
5. **Deployment**: Use CD workflows or GitOps via ArgoCD

## Important Notes

- **No Database**: Uses in-memory storage for simplicity
- **Resource Cleanup**: Use `./cleanup-eks.sh` when not using to avoid costs
- **Bilingual Support**: Documentation available in Chinese and English
- **Production Ready**: Includes monitoring, health checks, and security best practices

## Network and Deployment Guidelines

### Network Issues
- If experiencing slow network or timeouts when executing local commands, use `emea2` or `emea` commands
- These are aliases defined in `.zshrc` for setting HTTP proxy (try one if the other doesn't work)

### Architecture Rules
- This is a frontend-backend separated architecture
- Set appropriate ingress rules:
  - Access frontend via `http://domain`
  - Access backend API via `http://domain/api`

### AWS Resource Management
- When rebuilding important AWS resources like EKS, ECS, always use a new cluster name to prevent AWS caching issues
- Tag all AWS resources appropriately for easier maintenance
- Don't delete the entire `.terraform` directory casually, only delete providers that need upgrading

### Development Practices
- Confirm current directory before executing search commands (find)
- Avoid searching in subdirectories when not necessary