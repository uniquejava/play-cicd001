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

- **CD Pipelines** (`cicd/github-actions/cd-dev.yml`, `cicd/github-actions/cd-prod.yml`):
  - Separate deployment workflows for dev and prod environments
  - Manual trigger for production deployment

### Container Orchestration
- **Kubernetes** (`cicd/k8s/`): Separate deployments for frontend/backend with service configurations
- **Helm Charts** (`cicd/helm/`): Package management with environment-specific values
- **ArgoCD** (`cicd/argocd/`): GitOps configuration for continuous deployment

## Infrastructure as Code

### Terraform EKS Setup (`/infra/`)
- **Provider**: AWS
- **Service**: EKS Kubernetes 1.28
- **Compute**: 2x t3.medium worker nodes (auto-scaling 1-3)
- **Network**: Custom VPC (10.0.0.0/16) with public/private subnets
- **Region**: ap-southeast-1
- **Estimated Cost**: ~$170/month

### Infrastructure Commands
```bash
cd infra
terraform init                                    # Initialize Terraform
terraform plan                                    # Show execution plan
terraform apply                                   # Deploy infrastructure
aws eks --region ap-southeast-1 update-kubeconfig --name ticket-system-eks  # Configure kubectl
terraform destroy                                 # Destroy all resources
./cleanup-eks.sh                                  # Alternative cleanup script
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
cd frontend && pnpm test
```
- Uses Vitest and Vue Test Utils
- Test files should follow `*.test.ts` pattern

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