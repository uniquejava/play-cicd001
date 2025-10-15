#!/bin/bash

# Deploy NGINX Ingress Controller
set -e

echo "🚀 Deploying NGINX Ingress Controller..."

# Create namespace
echo "Creating namespace..."
kubectl apply -f - <<EOF
apiVersion: v1
kind: Namespace
metadata:
  name: ingress-nginx
  labels:
    app.kubernetes.io/name: ingress-nginx
    app.kubernetes.io/instance: ingress-nginx
EOF

# Add NGINX Ingress Controller Helm repository
echo "Adding NGINX Ingress Controller Helm repository..."
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
helm repo update

# Install NGINX Ingress Controller using Helm
echo "Installing NGINX Ingress Controller..."
helm upgrade --install ingress-nginx ingress-nginx/ingress-nginx \
  --namespace ingress-nginx \
  --create-namespace \
  --set controller.replicaCount=2 \
  --set controller.resources.requests.cpu=100m \
  --set controller.resources.requests.memory=128Mi \
  --set controller.resources.limits.cpu=500m \
  --set controller.resources.limits.memory=512Mi \
  --set controller.service.type=LoadBalancer \
  --set controller.service.externalTrafficPolicy=Local \
  --set controller.publishService.enabled=true

echo "✅ NGINX Ingress Controller deployed successfully!"
echo ""
echo "To check the status of the Ingress Controller:"
echo "kubectl get pods -n ingress-nginx"
echo "kubectl get svc -n ingress-nginx"
echo ""
echo "To get the external IP of the LoadBalancer:"
echo "kubectl get svc ingress-nginx-controller -n ingress-nginx -o wide"
echo ""
echo "After the Ingress Controller is ready, apply the application ingress:"
echo "kubectl apply -f ingress-class.yaml"
echo "kubectl apply -f ingress.yaml"