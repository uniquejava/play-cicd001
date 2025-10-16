# 前端开发指南

## 技术栈
- Vue 3 + TypeScript + Vite
- pnpm包管理
- 端口: 5173(开发), 80(生产)

## 开发命令
```bash
cd frontend
pnpm install          # 安装依赖
pnpm dev              # 开发服务器(5173)
pnpm build            # 生产构建
pnpm test             # 运行测试
pnpm preview          # 预览构建结果
```

## 项目结构
```
frontend/
├── src/
│   ├── components/    # Vue组件
│   ├── services/      # API服务
│   ├── App.vue        # 主组件
│   └── main.ts        # 入口文件
├── package.json       # 配置文件
└── vite.config.ts     # Vite配置
```

## 主要组件
- `App.vue` - 应用主布局
- `TicketList.vue` - 工单列表
- `TicketForm.vue` - 工单表单

## API集成
```typescript
// 服务调用示例
import { ticketService } from './services/ticketService'

const tickets = await ticketService.getTickets()
```

## 构建部署
```bash
# 构建Docker镜像
docker build -f cicd/docker/frontend/Dockerfile -t ticket-frontend ./frontend

# CI/CD自动构建并推送到ECR
# ECR地址: 488363440930.dkr.ecr.ap-northeast-1.amazonaws.com/ticket-management-frontend-dev
```