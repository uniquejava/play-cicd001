# CI/CD Directory Structure

This directory contains all CI/CD configurations following GitOps and Infrastructure as Code best practices.

## 📁 Directory Structure

```
cicd/
├── docker/                    # 🐳 Docker configurations
│   ├── backend/Dockerfile     # Backend container definition
│   └── frontend/Dockerfile    # Frontend container definition
├── kubernetes/                # ☸️ Kubernetes manifests (Kustomize)
│   ├── base/                  # Base configurations shared across environments
│   │   ├── namespace.yaml     # Namespace definition
│   │   ├── backend/           # Backend base manifests
│   │   ├── frontend/          # Frontend base manifests
│   │   └── kustomization.yaml  # Base kustomization
│   ├── overlays/              # Environment-specific configurations
│   │   ├── dev/               # Development environment
│   │   │   ├── kustomization.yaml
│   │   │   ├── backend-dev-config.yaml
│   │   │   ├── frontend-dev-config.yaml
│   │   │   └── ingress.yaml
│   │   └── prod/              # Production environment
│   │       ├── kustomization.yaml
│   │       ├── backend-prod-config.yaml
│   │       └── frontend-prod-config.yaml
│   └── tools/                 # 🛠️ Kubernetes tool configurations
│       ├── argocd/            # ArgoCD ECR credentials
│       └── secrets/           # ECR credential templates
├── argocd/                    # 🚢 ArgoCD GitOps configurations
│   ├── apps/                  # ArgoCD Application definitions
│   │   ├── ticket-system-dev.yaml    # Dev environment app
│   │   └── ticket-system-prod.yaml   # Prod environment app
│   └── project.yaml           # ArgoCD Project configuration
└── github_action/             # 🔄 GitHub Actions scripts
    └── git_update.sh          # Automatic Git tagging script
```

## 🎯 Usage

### Development Deployment
```bash
# Preview dev configuration
kubectl kustomize cicd/kubernetes/overlays/dev

# Deploy via script
./scripts/deploy.sh

# Deploy via ArgoCD
kubectl apply -f cicd/argocd/project.yaml
kubectl apply -f cicd/argocd/apps/ticket-system-dev.yaml
```

### Production Deployment
```bash
# Preview prod configuration
kubectl kustomize cicd/kubernetes/overlays/prod

# Deploy via ArgoCD
kubectl apply -f cicd/argocd/apps/ticket-system-prod.yaml
```

## 🔧 Environment Differences

| Configuration | Development | Production |
|---------------|-------------|------------|
| Namespace | `ticket-dev` | `ticket-prod` |
| Replicas | 1 each | 2 each (HA) |
| Spring Profile | `dev` | `prod` |
| Image Tags | `dev-<commit>` | `v<semver>` |
| Update Strategy | newest-build | semver |

## 📚 Key Concepts

- **Base**: Shared configurations across all environments
- **Overlays**: Environment-specific customizations using Kustomize
- **GitOps**: All configurations stored in Git and managed by ArgoCD
- **Infrastructure as Code**: All infrastructure defined as code