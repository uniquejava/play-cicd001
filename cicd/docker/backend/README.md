# Backend Dockerfiles

## Dockerfile (CI/Production)

适用于 GitHub Actions CI 和生产环境：
- 使用公共 Maven Central 仓库
- 不依赖私有网络资源
- 可在任何 Docker 环境中构建

## Dockerfile_local (Local Development)

适用于本地开发环境：
- 配置了私有 Nexus 仓库 (http://192.168.3.22:8081)
- 依赖内部网络资源
- 构建速度更快（使用本地缓存）

## 使用方法

### CI/生产环境
```bash
docker build -f cicd/docker/backend/Dockerfile -t ticket-backend ./backend
```

### 本地开发
```bash
docker build -f cicd/docker/backend/Dockerfile_local -t ticket-backend ./backend
```

## 切换文件

如需在本地使用 CI 版本：
```bash
cp cicd/docker/backend/Dockerfile cicd/docker/backend/Dockerfile_local
```

如需恢复本地配置：
```bash
cp cicd/docker/backend/Dockerfile_local cicd/docker/backend/Dockerfile
```