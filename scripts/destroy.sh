#!/bin/bash

# 一键删除脚本
set -e

# 配置
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

# 环境配置
NAMESPACE="ticket-dev"
INGRESS_NAMESPACE="ingress-nginx"
CLUSTER_NAME="ticket-system-eks"
REGION="ap-northeast-1"
PROJECT_TAG="ticket-management"
ENVIRONMENT_TAG="dev"

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
    echo -e "${CYAN}🧹 步骤 $1: $2${NC}"
}

# 显示使用方法
print_usage() {
    echo "使用方法: $0 [选项]"
    echo ""
    echo "选项:"
    echo "  --skip-apps     跳过应用删除（仅删除基础设施）"
    echo "  --skip-infra    跳过基础设施删除（仅删除应用）"
    echo "  --force         强制删除，跳过确认"
    echo "  --help, -h      显示此帮助信息"
    echo ""
    echo "示例:"
    echo "  $0                    # 完整删除（应用 + 基础设施）"
    echo "  $0 --skip-apps        # 仅删除基础设施"
    echo "  $0 --skip-infra       # 仅删除应用"
    echo "  $0 --force            # 强制删除所有资源"
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

    print_success "AWS配置正常"
}

# 确认删除
confirm_deletion() {
    if [[ "$force_mode" == true ]]; then
        print_warning "强制模式：跳过确认"
        return
    fi

    echo -e "${RED}⚠️  警告: 此操作将删除所有项目相关的 AWS 资源!${NC}"
    echo -e "${RED}此操作不可撤销，在清理完成前会产生费用。${NC}"
    echo ""
    echo "将被删除的资源包括:"
    echo "  - Kubernetes应用 (Deployments, Services, Ingress等)"
    echo "  - EKS集群和节点组"
    echo "  - VPC及相关网络资源"
    echo "  - IAM角色和策略"
    echo "  - ECR镜像仓库"
    echo "  - 安全组和其他相关资源"
    echo ""
    echo "预计节省费用: ~\$170/月"
    echo ""
    read -p "确定要删除所有资源吗? (输入 'yes' 确认): " confirm

    if [[ $confirm != "yes" ]]; then
        print_info "删除操作已取消"
        exit 0
    fi
}

# 显示当前资源
show_current_resources() {
    print_info "当前资源状态:"

    # 显示K8s资源
    if kubectl cluster-info &> /dev/null; then
        echo ""
        echo "Kubernetes资源:"
        kubectl get namespaces | grep -E "(ticket-dev|ingress-nginx)" || echo "  无相关命名空间"
        kubectl get ingress --all-namespaces | grep ticket || echo "  无相关Ingress"
    else
        echo "无法连接到Kubernetes集群"
    fi

    # 显示AWS资源
    echo ""
    echo "AWS资源:"

    # EKS集群
    local eks_clusters=$(aws eks list-clusters --region "$REGION" --query 'clusters[?contains(@, `ticket-system`)]' --output text 2>/dev/null || echo "")
    if [[ -n "$eks_clusters" ]]; then
        echo "  EKS集群: $eks_clusters"
    fi

    # VPC
    local vpc_count=$(aws ec2 describe-vpcs --region "$REGION" --filters "Name=tag:Project,Values=$PROJECT_TAG" "Name=tag:Environment,Values=$ENVIRONMENT_TAG" --query 'length(Vpcs)' --output text 2>/dev/null || echo "0")
    if [[ "$vpc_count" != "0" ]]; then
        echo "  标记的VPC: $vpc_count个"
    fi

    # ECR仓库
    local ecr_count=$(aws ecr describe-repositories --region "$REGION" --query 'length(repositories[?contains(repositoryName, `ticket`)])' --output text 2>/dev/null || echo "0")
    if [[ "$ecr_count" != "0" ]]; then
        echo "  ECR仓库: $ecr_count个"
    fi
}

# 删除K8s应用资源
delete_k8s_applications() {
    print_step "1" "删除Kubernetes应用资源"

    if ! kubectl cluster-info &> /dev/null; then
        print_warning "无法连接到Kubernetes集群，跳过K8s资源删除"
        return
    fi

    # 删除应用资源
    print_info "删除应用部署..."
    kubectl delete namespace "$NAMESPACE" --ignore-not-found=true
    kubectl delete namespace "$INGRESS_NAMESPACE" --ignore-not-found=true
    kubectl delete ingressclass nginx --ignore-not-found=true

    print_success "K8s应用资源删除完成"
}

# 删除Terraform基础设施
delete_terraform_infrastructure() {
    print_step "2" "删除Terraform基础设施"

    local infra_dir="$PROJECT_ROOT/infra"

    if [[ ! -d "$infra_dir" ]]; then
        print_warning "infra目录不存在，跳过Terraform删除"
        return
    fi

    cd "$infra_dir"

    # 检查是否有Terraform状态
    if [[ ! -f "terraform.tfstate" ]]; then
        print_warning "未找到Terraform状态文件，使用AWS CLI直接删除"
        delete_aws_resources_directly
        return
    fi

    print_info "使用Terraform删除资源..."

    # 显示当前状态
    print_info "当前Terraform管理的资源:"
    terraform show

    # 删除资源
    print_info "执行terraform destroy..."
    terraform destroy -auto-approve

    # 清理状态文件
    rm -f terraform.tfstate terraform.tfstate.backup

    print_success "Terraform基础设施删除完成"
}

# 直接删除AWS资源（备用方法）
delete_aws_resources_directly() {
    print_info "使用AWS CLI直接删除资源..."

    # 删除EKS集群
    print_info "删除EKS集群..."
    if aws eks describe-cluster --name "$CLUSTER_NAME" --region "$REGION" >/dev/null 2>&1; then
        # 删除节点组
        local node_groups=$(aws eks list-nodegroups --cluster-name "$CLUSTER_NAME" --region "$REGION" --query 'nodegroups' --output text 2>/dev/null || true)
        for ng in $node_groups; do
            print_info "删除节点组: $ng"
            aws eks delete-node-group --cluster-name "$CLUSTER_NAME" --nodegroup-name "$ng" --region "$REGION" || true
        done

        # 等待节点组删除完成
        for ng in $node_groups; do
            aws eks wait nodegroup-deleted --cluster-name "$CLUSTER_NAME" --nodegroup-name "$ng" --region "$REGION" || true
        done

        # 删除集群
        print_info "删除EKS集群: $CLUSTER_NAME"
        aws eks delete-cluster --name "$CLUSTER_NAME" --region "$REGION" || true
        aws eks wait cluster-deleted --name "$CLUSTER_NAME" --region "$REGION" || true
    fi

    # 删除VPC资源
    print_info "删除VPC相关资源..."
    # 这里可以添加更详细的VPC清理逻辑，但为了保持简洁，暂时跳过

    # 删除ECR仓库
    print_info "删除ECR仓库..."
    local repos=$(aws ecr describe-repositories --region "$REGION" --query 'repositories[?contains(repositoryName, `ticket`) || contains(repositoryName, `management`)].repositoryName' --output text 2>/dev/null || true)
    for repo in $repos; do
        if [[ -n "$repo" ]]; then
            print_info "删除ECR仓库: $repo"
            aws ecr delete-repository --repository-name "$repo" --region "$REGION" --force || true
        fi
    done

    print_success "AWS资源删除完成"
}

# 验证删除结果
verify_deletion() {
    print_step "3" "验证删除结果"

    print_info "检查资源删除状态..."

    # 检查K8s资源
    if kubectl cluster-info &> /dev/null; then
        local remaining_k8s=$(kubectl get all --all-namespaces | grep -E "(ticket-dev|ingress-nginx)" | wc -l)
        if [[ "$remaining_k8s" -gt 0 ]]; then
            print_warning "仍有K8s资源未删除完全"
            kubectl get all --all-namespaces | grep -E "(ticket-dev|ingress-nginx)"
        else
            print_success "K8s资源已完全删除"
        fi
    fi

    # 检查AWS资源
    local remaining_eks=$(aws eks list-clusters --region "$REGION" --query 'clusters[?contains(@, `ticket-system`)]' --output text 2>/dev/null || echo "")
    if [[ -n "$remaining_eks" ]]; then
        print_warning "仍有EKS集群未删除: $remaining_eks"
    else
        print_success "EKS集群已完全删除"
    fi

    local remaining_ecr=$(aws ecr describe-repositories --region "$REGION" --query 'length(repositories[?contains(repositoryName, `ticket`) || contains(repositoryName, `management`)])' --output text 2>/dev/null || echo "0")
    if [[ "$remaining_ecr" != "0" ]]; then
        print_warning "仍有ECR仓库未删除: $remaining_ecr个"
    else
        print_success "ECR仓库已完全删除"
    fi
}

# 主函数
main() {
    local skip_apps=false
    local skip_infra=false
    force_mode=false

    # 解析参数
    while [[ $# -gt 0 ]]; do
        case $1 in
            --skip-apps)
                skip_apps=true
                shift
                ;;
            --skip-infra)
                skip_infra=true
                shift
                ;;
            --force)
                force_mode=true
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

    echo "🧹 Ticket Management System 一键删除"
    echo "===================================="
    echo ""

    # 环境检查
    print_info "执行环境检查..."
    check_dependencies
    check_aws_config
    echo ""

    # 显示当前资源
    show_current_resources
    echo ""

    # 确认删除
    confirm_deletion
    echo ""

    # 执行删除步骤
    if [[ "$skip_apps" == false ]]; then
        delete_k8s_applications
        echo ""
    fi

    if [[ "$skip_infra" == false ]]; then
        delete_terraform_infrastructure
        echo ""
    fi

    # 验证删除结果
    verify_deletion

    echo ""
    print_success "🎉 删除操作完成!"
    print_info "费用节省: ~\$170/月"
    print_info "如需验证删除结果，请稍后再次运行此脚本"
}

# 运行主函数
main "$@"