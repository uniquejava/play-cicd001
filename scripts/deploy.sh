#!/bin/bash

# 一键部署脚本
set -e

# 配置
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
INFRA_DIR="$PROJECT_ROOT/infra"
K8S_DIR="$PROJECT_ROOT/cicd/k8s"

# 环境配置
NAMESPACE="ticket-dev"
CLUSTER_NAME="tix-eks-fresh-magpie"
REGION="ap-northeast-1"

# 颜色输出
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
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

print_step() {
    echo -e "${CYAN}🚀 步骤 $1: $2${NC}"
}

# 显示使用方法
print_usage() {
    echo "使用方法: $0 [选项]"
    echo ""
    echo "选项:"
    echo "  --skip-infra    跳过基础设施部署（仅部署K8s应用）"
    echo "  --skip-apps     跳过应用部署（仅部署基础设施）"
    echo "  --help, -h      显示此帮助信息"
    echo ""
    echo "示例:"
    echo "  $0                    # 完整部署（基础设施 + 应用）"
    echo "  $0 --skip-infra       # 仅部署应用到现有集群"
    echo "  $0 --skip-apps        # 仅部署基础设施"
}

# 检查必要工具
check_dependencies() {
    print_info "检查必要工具..."

    local missing_tools=()

    if ! command -v aws &> /dev/null; then
        missing_tools+=("aws")
    fi

    if ! command -v kubectl &> /dev/null; then
        missing_tools+=("kubectl")
    fi

    if ! command -v terraform &> /dev/null; then
        missing_tools+=("terraform")
    fi

    if ! command -v helm &> /dev/null; then
        missing_tools+=("helm")
    fi

    if [[ ${#missing_tools[@]} -gt 0 ]]; then
        print_error "缺少以下工具: ${missing_tools[*]}"
        print_info "请安装缺少的工具后重试"
        exit 1
    fi

    print_success "所有必要工具已安装"
}

# 检查AWS配置
check_aws_config() {
    print_info "检查AWS配置..."

    if ! aws sts get-caller-identity &> /dev/null; then
        print_error "AWS凭证未配置或无效"
        print_info "请运行: aws configure"
        exit 1
    fi

    local account_id=$(aws sts get-caller-identity --query Account --output text)
    local region=$(aws configure get region || echo "$REGION")

    print_success "AWS配置正常"
    print_info "账户ID: $account_id"
    print_info "区域: $region"
}

# 部署基础设施
deploy_infrastructure() {
    print_step "1" "部署基础设施 (Terraform)"

    cd "$INFRA_DIR"

    # 初始化Terraform
    print_info "初始化Terraform..."
    terraform init

    # 规划部署
    print_info "规划部署..."
    terraform plan

    # 应用配置
    print_info "应用Terraform配置..."
    terraform apply -auto-approve

    print_success "基础设施部署完成"

    # 配置kubectl
    print_info "配置kubectl..."

    # 如果跳过基础设施部署，检查当前kubectl上下文
    if [[ "$skip_infra" == true ]]; then
        local current_context=$(kubectl config current-context 2>/dev/null || echo "")
        if [[ -n "$current_context" ]]; then
            print_success "kubectl已配置到集群: $current_context"
        else
            print_error "kubectl未配置，无法连接到集群"
            exit 1
        fi
    else
        # 只有在部署基础设施时才更新kubeconfig
        aws eks --region "$REGION" update-kubeconfig --name "$CLUSTER_NAME"
        print_success "kubectl配置完成"
    fi
}

# 部署NGINX Ingress Controller
deploy_ingress() {
    print_step "2" "部署 NGINX Ingress Controller"

    # 添加Helm仓库
    print_info "添加NGINX Ingress Helm仓库..."
    helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
    helm repo update

    # 部署NGINX Ingress Controller
    print_info "部署NGINX Ingress Controller..."
    helm upgrade --install ingress-nginx ingress-nginx/ingress-nginx \
        --namespace ingress-nginx \
        --create-namespace \
        --set controller.replicaCount=1 \
        --set controller.resources.requests.cpu=100m \
        --set controller.resources.requests.memory=128Mi \
        --set controller.resources.limits.cpu=500m \
        --set controller.resources.limits.memory=512Mi \
        --set controller.service.type=LoadBalancer \
        --set controller.service.externalTrafficPolicy=Local

    print_success "NGINX Ingress Controller部署完成"
}

# 创建命名空间
create_namespace() {
    print_step "3" "创建命名空间"

    kubectl create namespace "$NAMESPACE" --dry-run=client -o yaml | kubectl apply -f -

    print_success "命名空间创建完成"
}

# 部署应用
deploy_applications() {
    print_step "4" "部署应用"

    cd "$K8S_DIR"

    # 部署后端
    print_info "部署后端服务..."
    kubectl apply -f backend/deployment.yaml
    kubectl apply -f backend/service.yaml

    # 部署前端
    print_info "部署前端服务..."
    kubectl apply -f frontend/deployment.yaml
    kubectl apply -f frontend/service.yaml

    # 部署Ingress
    print_info "部署Ingress配置..."
    kubectl apply -f ingress-class.yaml
    kubectl apply -f ingress.yaml

    print_success "应用部署完成"
}

# 等待部署完成
wait_for_deployment() {
    print_step "5" "等待部署完成"

    print_info "等待Pod启动..."
    kubectl wait --for=condition=available --timeout=300s deployment/backend-deployment -n "$NAMESPACE"
    kubectl wait --for=condition=available --timeout=300s deployment/frontend-deployment -n "$NAMESPACE"

    print_info "等待Ingress Controller就绪..."
    kubectl wait --for=condition=available --timeout=300s deployment/ingress-nginx-controller -n ingress-nginx

    print_success "所有部署完成"
}

# 显示部署结果
show_results() {
    print_step "6" "显示部署结果"

    echo ""
    print_info "=== 部署状态 ==="

    # 显示Pod状态
    echo ""
    echo "Pod状态:"
    kubectl get pods -n "$NAMESPACE"

    # 显示服务状态
    echo ""
    echo "服务状态:"
    kubectl get services -n "$NAMESPACE"

    # 显示Ingress状态
    echo ""
    echo "Ingress状态:"
    kubectl get ingress -n "$NAMESPACE"

    # 获取负载均衡器地址
    echo ""
    print_info "=== 访问地址 ==="

    local lb_address=$(kubectl get svc ingress-nginx-controller -n ingress-nginx -o jsonpath='{.status.loadBalancer.ingress[0].hostname}' 2>/dev/null || echo "")

    if [[ -n "$lb_address" ]]; then
        echo "前端地址: http://$lb_address/"
        echo "后端API:  http://$lb_address/api/tickets"
    else
        print_warning "负载均衡器地址暂未获取到，请稍后运行以下命令查看:"
        echo "kubectl get svc ingress-nginx-controller -n ingress-nginx"
    fi

    echo ""
    print_success "🎉 部署完成!"
}

# 主函数
main() {
    local skip_infra=false
    local skip_apps=false

    # 解析参数
    while [[ $# -gt 0 ]]; do
        case $1 in
            --skip-infra)
                skip_infra=true
                shift
                ;;
            --skip-apps)
                skip_apps=true
                shift
                ;;
            --help|-h)
                print_usage
                exit 0
                ;;
            *)
                print_error "未知参数: $1"
                print_usage
                exit 1
                ;;
        esac
    done

    echo "🚀 Ticket Management System 一键部署"
    echo "===================================="
    echo ""

    # 环境检查
    print_info "执行环境检查..."
    check_dependencies
    check_aws_config
    echo ""

    # 检查集群连接（如果跳过基础设施部署）
    if [[ "$skip_infra" == true ]]; then
        if ! kubectl cluster-info &> /dev/null; then
            print_error "无法连接到Kubernetes集群"
            print_info "请确保集群已启动且kubectl已正确配置"
            exit 1
        fi
        print_success "集群连接正常"
    fi

    # 执行部署步骤
    if [[ "$skip_infra" == false ]]; then
        deploy_infrastructure
        deploy_ingress
    fi

    if [[ "$skip_apps" == false ]]; then
        create_namespace
        deploy_applications
        wait_for_deployment
    fi

    show_results
}

# 运行主函数
main "$@"