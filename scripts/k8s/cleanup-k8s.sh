#!/bin/bash

# K8s资源清理脚本
set -e

# 配置
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
K8S_DIR="$PROJECT_ROOT/cicd/k8s"

# 命名空间
NAMESPACE="ticket-dev"
INGRESS_NAMESPACE="ingress-nginx"

# 颜色输出
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m'

print_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

# 检查kubectl
check_kubectl() {
    if ! command -v kubectl &> /dev/null; then
        print_error "kubectl 未安装或不在PATH中"
        exit 1
    fi
    print_success "kubectl 检查通过"
}

# 检查集群连接
check_cluster_connection() {
    if ! kubectl cluster-info &> /dev/null; then
        print_error "无法连接到 Kubernetes 集群"
        exit 1
    fi
    print_success "集群连接正常"
}

# 确认删除
confirm_deletion() {
    echo -e "${RED}⚠️  警告: 此操作将删除所有 K8s 应用资源!${NC}"
    echo -e "${RED}包括: deployments, services, ingress, configmaps 等${NC}"
    echo ""
    read -p "确定要继续吗? (输入 'yes' 确认): " confirm

    if [[ $confirm != "yes" ]]; then
        print_info "清理操作已取消"
        exit 0
    fi
}

# 清理应用资源
cleanup_application() {
    print_info "清理应用资源..."

    # 删除应用相关的资源
    kubectl delete -f "$K8S_DIR/backend/deployment.yaml" --ignore-not-found=true
    kubectl delete -f "$K8S_DIR/backend/service.yaml" --ignore-not-found=true
    kubectl delete -f "$K8S_DIR/frontend/deployment.yaml" --ignore-not-found=true
    kubectl delete -f "$K8S_DIR/frontend/service.yaml" --ignore-not-found=true
    kubectl delete -f "$K8S_DIR/ingress.yaml" --ignore-not-found=true

    print_success "应用资源清理完成"
}

# 清理NGINX Ingress Controller
cleanup_ingress() {
    print_info "清理 NGINX Ingress Controller..."

    # 使用Helm删除
    if command -v helm &> /dev/null; then
        helm uninstall ingress-nginx -n "$INGRESS_NAMESPACE" --ignore-not-found
        print_success "Helm 卸载完成"
    fi

    # 删除命名空间
    kubectl delete namespace "$INGRESS_NAMESPACE" --ignore-not-found=true

    # 删除IngressClass
    kubectl delete ingressclass nginx --ignore-not-found=true

    print_success "NGINX Ingress Controller 清理完成"
}

# 清理命名空间
cleanup_namespace() {
    print_info "清理命名空间: $NAMESPACE"

    # 强制删除命名空间中的所有资源
    kubectl delete namespace "$NAMESPACE" --ignore-not-found=true

    print_success "命名空间清理完成"
}

# 显示清理后状态
show_status() {
    print_info "清理后状态:"

    echo "命名空间:"
    kubectl get namespaces | grep -E "(ticket-dev|ingress-nginx)" || echo "  无相关命名空间"

    echo ""
    echo "Ingress:"
    kubectl get ingress --all-namespaces | grep -E "(ticket-dev)" || echo "  无相关Ingress"

    echo ""
    echo "Services:"
    kubectl get services --all-namespaces | grep -E "(ticket-dev|ingress-nginx)" || echo "  无相关Services"

    echo ""
    echo "Deployments:"
    kubectl get deployments --all-namespaces | grep -E "(ticket-dev|ingress-nginx)" || echo "  无相关Deployments"
}

# 主函数
main() {
    echo "🧹 K8s 资源清理脚本"
    echo "=================="
    echo ""

    # 环境检查
    check_kubectl
    check_cluster_connection

    echo ""
    print_info "当前集群:"
    kubectl cluster-info
    echo ""

    # 显示当前状态
    print_info "当前相关资源:"
    show_status
    echo ""

    # 确认删除
    confirm_deletion

    # 开始清理
    print_info "开始清理 K8s 资源..."

    # 按顺序清理
    cleanup_application
    cleanup_ingress
    cleanup_namespace

    echo ""
    print_success "🎉 K8s 资源清理完成!"

    # 显示清理后状态
    echo ""
    print_info "清理后状态:"
    show_status
}

# 运行主函数
main "$@"