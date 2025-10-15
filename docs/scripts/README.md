# Scripts Directory

统一的脚本管理目录，包含所有自动化脚本。

## 📁 目录结构

```
scripts/
├── README.md                  # 本文件
├── deploy.sh                 # 一键部署脚本
├── destroy.sh                # 一键删除脚本
├── docker/
│   └── build-frontend.sh     # 前端Docker构建脚本
├── k8s/
│   └── cleanup-k8s.sh        # K8s资源清理脚本
└── terraform/
    └── cleanup-terraform.sh  # Terraform资源清理脚本
```

## 🚀 使用方法

### 一键部署
```bash
./scripts/deploy.sh
```

### 一键删除
```bash
./scripts/destroy.sh
```

### 单独功能脚本

#### Docker构建
```bash
# 构建前端（生产模式）
./scripts/docker/build-frontend.sh production

# 构建前端（开发模式）
./scripts/docker/build-frontend.sh development
```

#### K8s资源管理
```bash
# 清理K8s资源
./scripts/k8s/cleanup-k8s.sh
```

#### Terraform资源管理
```bash
# 清理Terraform资源
./scripts/terraform/cleanup-terraform.sh
```

## ⚡ 特性

- ✅ **统一管理**：所有脚本集中管理，方便维护
- ✅ **一键操作**：支持一键部署和一键删除
- ✅ **安全确认**：删除操作需要用户确认
- ✅ **错误处理**：完整的错误处理和状态检查
- ✅ **日志输出**：彩色日志输出，便于调试
- ✅ **依赖检查**：自动检查必要的工具和权限

## 🔧 前置要求

- AWS CLI 已配置
- kubectl 已配置
- Terraform 已安装
- Docker 已安装
- Helm 已安装

## 💡 注意事项

1. 运行删除脚本前请确保已备份重要数据
2. 建议在开发环境先测试脚本
3. 如遇问题可查看具体脚本的日志输出