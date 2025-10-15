# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a CI/CD demonstration project for a simple ticket management system with modern microservices architecture (Java Spring Boot backend + Vue 3 frontend). The project is designed to showcase CI/CD pipelines using DevOps tools and practices.

## Architecture

- **Backend**: Spring Boot 3.5.6 with Java 17, Maven build system, runs on port 8080
- **Frontend**: Vue 3 with Composition API, TypeScript, Vite build tool, pnpm package manager
- **No database**: Uses in-memory storage for simplicity
- **CI/CD**: GitHub Actions → Docker → Kubernetes → Helm → ArgoCD pipeline

## Development Commands

### Frontend (Vue 3 + TypeScript)
```bash
cd frontend
pnpm install          # Install dependencies
pnpm dev             # Start development server (typically port 5173)
pnpm build           # Build for production
pnpm preview         # Preview production build
```

### Backend (Spring Boot)
```bash
cd backend
mvn clean install    # Build and run tests
mvn spring-boot:run  # Run application (port 8080)
mvn test            # Run tests only
```

## Project Structure

```
play-cicd001/
├── backend/                    # Spring Boot API
│   ├── src/main/java/net/billcat/demo/backend/
│   ├── src/main/resources/
│   └── pom.xml
├── frontend/                   # Vue 3 SPA
│   ├── src/components/
│   ├── src/App.vue
│   └── package.json
└── README.md                   # Project requirements (Chinese)
```

## Key Technologies & Configurations

- **Backend Framework**: Spring Boot 3.x with Java 17
- **Frontend Framework**: Vue 3 with Composition API and TypeScript
- **Build Tools**: Maven (backend), Vite (frontend)
- **Package Manager**: pnpm (frontend)
- **Testing**: JUnit 5 (backend), Vitest/Vue Test Utils (frontend)
- **CI/CD Stack**: GitHub Actions, Docker, Kubernetes, Helm, ArgoCD

## Development Notes

- Both frontend and backend projects are scaffolded but core functionality (ticket CRUD) needs implementation
- The project includes IDE configurations in `.idea/` directory
- All dependencies and basic project structure are already configured
- Focus should be on implementing ticket management features and CI/CD pipeline components

## Implementation Roadmap

1. Implement ticket CRUD operations in both frontend and backend
2. Create Dockerfiles for containerization
3. Set up GitHub Actions workflows for CI/CD
4. Create Kubernetes deployment manifests
5. Configure Helm charts for package management
6. Set up ArgoCD for GitOps deployment