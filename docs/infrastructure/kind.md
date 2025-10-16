# Kind本地集群

## 创建集群
```bash
kind create cluster --name my-kind --config kind-config.yaml
kubectl get nodes
```

## 部署应用
```bash
# 加载镜像到Kind
kind load docker-image ticket-backend:latest --name my-kind
kind load docker-image ticket-frontend:latest --name my-kind

# 部署到本地集群
kubectl apply -f cicd/k8s/ -n ticket-dev
```

## 测试
```bash
# 检查Pod状态
kubectl get pods -n ticket-dev

# 端口转发测试
kubectl port-forward -n ticket-dev service/backend-service 8081:8080
curl http://localhost:8081/api/tickets

kubectl port-forward -n ticket-dev service/frontend-service 8082:80
curl http://localhost:8082
```

## 清理
```bash
# 删除应用
kubectl delete namespace ticket-dev

# 删除集群
kind delete cluster --name my-kind
```

## 用途
- 本地开发和测试
- CI/CD流程验证
- 无需AWS资源