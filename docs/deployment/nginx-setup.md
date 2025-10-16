# NGINX Ingress Controller设置

## 快速部署
```bash
# NGINX Ingress Controller已通过deploy.sh自动部署
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.12.0-beta.0/deploy/static/provider/cloud/deploy.yaml
```

## 验证部署
```bash
# 检查NGINX Controller
kubectl get pods -n ingress-nginx
kubectl get svc -n ingress-nginx

# 检查应用Ingress
kubectl get ingress -n ticket-dev

# 获取负载均衡器地址
kubectl get svc ingress-nginx-controller -n ingress-nginx -o jsonpath='{.status.loadBalancer.ingress[0].hostname}'
```

## Ingress路由配置
- **前端**: `/` → `frontend-service:80`
- **后端API**: `/api` → `backend-service:8080`

## 测试访问
```bash
# 获取LB地址
LB_URL=$(kubectl get svc ingress-nginx-controller -n ingress-nginx -o jsonpath='{.status.loadBalancer.ingress[0].hostname}')

# 测试前端
curl http://$LB_URL/

# 测试后端API
curl http://$LB_URL/api/tickets
```

## 故障排除
```bash
# 查看日志
kubectl logs -n ingress-nginx deployment/ingress-nginx-controller

# 检查Ingress详情
kubectl describe ingress ticket-management-ingress -n ticket-dev

# 检查服务连接
kubectl exec -it -n ticket-dev deployment/backend -- curl http://backend-service:8080/api/tickets
```