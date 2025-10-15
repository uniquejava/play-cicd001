# Frontend Development Guide

## 技术栈

- **框架**: Vue 3 with Composition API
- **语言**: TypeScript
- **构建工具**: Vite 7.1.7
- **包管理器**: pnpm
- **端口**: 5173 (development), 80 (production)

## 项目结构

```
frontend/
├── src/
│   ├── components/        # Vue组件
│   ├── services/         # API服务
│   ├── types/           # TypeScript类型定义
│   ├── App.vue          # 主应用组件
│   └── main.ts          # 应用入口
├── public/              # 静态资源
├── index.html           # HTML模板
├── package.json         # 项目配置
├── tsconfig.json        # TypeScript配置
├── vite.config.ts       # Vite配置
└── pnpm-lock.yaml       # 依赖锁定文件
```

## 开发命令

```bash
# 安装依赖
pnpm install

# 启动开发服务器
pnpm dev

# 构建生产版本
pnpm build

# 预览生产构建
pnpm preview

# 运行测试
pnpm test
```

## 开发规范

### 组件命名
- 使用PascalCase命名组件
- 文件名与组件名保持一致

### API服务
- 所有API调用放在 `src/services/` 目录
- 使用TypeScript定义接口类型
- 统一的错误处理

### 状态管理
- 使用Vue 3 Composition API
- 组件间通信使用props和emits

## 样式规范

- 使用CSS模块化
- 遵循BEM命名约定
- 响应式设计

## 部署

前端应用部署在Kubernetes中，通过NGINX Ingress Controller提供服务。

- **开发环境**: http://localhost:5173
- **生产环境**: 通过负载均衡器访问

---

**相关链接**:
- [Vue 3 官方文档](https://vuejs.org/)
- [Vite 官方文档](https://vitejs.dev/)
- [TypeScript 手册](https://www.typescriptlang.org/docs/)