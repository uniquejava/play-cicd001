# NGINX Ingress Controller Setup

本文档说明如何在已删除ALB配置后使用NGINX Ingress Controller。

## 已删除的ALB配置

以下ALB相关配置已被删除：
- `/infra/modules/alb/` - 整个ALB Terraform模块
- `/infra/register-targets.sh` - ALB目标注册脚本
- `/cicd/k8s/alb-ingress.yaml` - ALB Ingress配置
- `/infra/main.tf` 中的ALB模块调用
- `/infra/modules/eks/main.tf` 中的ALB安全组
- `/infra/modules/eks/outputs.tf` 中的ALB输出

## 新增的NGINX配置

### 1. NGINX Ingress Controller
- `nginx-ingress-controller.yaml` - 完整的NGINX Ingress Controller部署配置
- `ingress-class.yaml` - NGINX IngressClass定义
- `deploy-nginx-ingress.sh` - 自动化部署脚本

### 2. 应用Ingress配置
- `ingress.yaml` - 已更新为使用NGINX Ingress Controller的应用路由配置

## 部署步骤

### 前置条件
- 已有运行的Kubernetes集群
- kubectl已配置并可以访问集群
- Helm已安装

### 1. 部署NGINX Ingress Controller

使用自动化脚本（推荐）：
```bash
cd cicd/k8s
./deploy-nginx-ingress.sh
```

或手动部署：
```bash
# 1. 创建命名空间
kubectl apply -f nginx-ingress-controller.yaml

# 2. 使用Helm部署（如果不用上面的YAML文件）
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
helm repo update
helm upgrade --install ingress-nginx ingress-nginx/ingress-nginx \
  --namespace ingress-nginx \
  --create-namespace
```

### 2. 部署应用Ingress配置

```bash
# 1. 创建IngressClass
kubectl apply -f ingress-class.yaml

# 2. 部署应用Ingress
kubectl apply -f ingress.yaml
```

### 3. 验证部署

```bash
# 检查NGINX Ingress Controller状态
kubectl get pods -n ingress-nginx
kubectl get svc -n ingress-nginx

# 检查Ingress资源
kubectl get ingress -n ticket-dev

# 获取外部IP地址
EXTERNAL_IP=$(kubectl get svc ingress-nginx-controller -n ingress-nginx -o jsonpath='{.status.loadBalancer.ingress[0].ip}')
echo "NGINX Ingress Controller External IP: $EXTERNAL_IP"
```

## 配置说明

### Ingress路由规则

当前配置的路由规则：
- **主机**: `ticket-management.local`
- **API路径**: `/api/*` → `backend-service:8080`
- **前端路径**: `/*` → `frontend-service:80`

### 访问应用

#### 方法1：使用hosts文件
```bash
# 添加到本地hosts文件
echo "<EXTERNAL_IP> ticket-management.local" | sudo tee -a /etc/hosts

# 访问应用
curl http://ticket-management.local/api/tickets
```

#### 方法2：使用curl with Host header
```bash
curl -H "Host: ticket-management.local" http://<EXTERNAL_IP>/api/tickets
```

## 与ALB的主要区别

1. **配置方式**：
   - ALB使用AWS Load Balancer Controller
   - NGINX使用Kubernetes原生Ingress资源

2. **注解**：
   - ALB: `alb.ingress.kubernetes.io/*`
   - NGINX: `nginx.ingress.kubernetes.io/*`

3. **部署方式**：
   - ALB需要AWS IAM权限和安全组配置
   - NGINX只需在集群内部署

4. **成本**：
   - ALB有额外的AWS费用
   - NGINX在集群内运行，无额外费用

## 故障排除

### 检查Pod状态
```bash
kubectl get pods -n ingress-nginx
kubectl logs -n ingress-nginx deployment/ingress-nginx-controller
```

### 检查Ingress状态
```bash
kubectl describe ingress ticket-management-ingress -n ticket-dev
```

### 检查服务连接
```bash
kubectl exec -it -n ticket-dev deployment/backend -- curl http://backend-service:8080/api/tickets
kubectl exec -it -n ticket-dev deployment/frontend -- curl http://frontend-service:80
```

## 清理

如需删除NGINX Ingress Controller：
```bash
helm uninstall ingress-nginx -n ingress-nginx
kubectl delete namespace ingress-nginx
```

## 注意事项

1. 确保Kubernetes集群有足够的资源运行NGINX Ingress Controller
2. 如果使用云服务商的Kubernetes服务，LoadBalancer可能会产生额外费用
3. 在生产环境中，建议配置HTTPS/TLS证书
4. 考虑设置资源限制和请求以确保稳定性