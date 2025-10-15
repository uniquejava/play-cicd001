#!/bin/bash

# Terraform资源清理脚本
set -e

# 配置
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
INFRA_DIR="$PROJECT_ROOT/infra"

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

# 检查Terraform
check_terraform() {
    if ! command -v terraform &> /dev/null; then
        print_error "Terraform 未安装或不在PATH中"
        exit 1
    fi
    print_success "Terraform 检查通过"
}

# 检查infra目录
check_infra_dir() {
    if [[ ! -d "$INFRA_DIR" ]]; then
        print_error "infra 目录不存在: $INFRA_DIR"
        exit 1
    fi
    print_success "infra 目录检查通过"
}

# 确认删除
confirm_deletion() {
    echo -e "${RED}⚠️  警告: 此操作将删除所有通过 Terraform 创建的 AWS 资源!${NC}"
    echo -e "${RED}此操作不可撤销，在清理完成前会产生费用。${NC}"
    echo ""
    read -p "确定要继续吗? (输入 'yes' 确认): " confirm

    if [[ $confirm != "yes" ]]; then
        print_info "清理操作已取消"
        exit 0
    fi
}

# 清理Terraform资源
cleanup_terraform() {
    cd "$INFRA_DIR"

    print_info "切换到 infra 目录"

    # 检查是否有状态文件
    if [[ ! -f "terraform.tfstate" ]]; then
        print_warning "未找到 Terraform 状态文件，可能没有通过 Terraform 创建的资源"
        return
    fi

    print_info "发现 Terraform 状态文件"

    # 显示当前状态
    print_info "当前资源状态:"
    terraform show

    echo ""
    print_warning "即将删除以下资源:"
    terraform destroy -auto-approve -target=module.alb || true
    terraform destroy -auto-approve

    print_success "Terraform 资源清理完成"

    # 删除状态文件
    if [[ -f "terraform.tfstate" ]]; then
        print_info "删除状态文件..."
        rm -f terraform.tfstate terraform.tfstate.backup
        print_success "状态文件已删除"
    fi
}

# 主函数
main() {
    echo "🧹 Terraform 资源清理脚本"
    echo "================================"
    echo ""

    # 环境检查
    check_terraform
    check_infra_dir

    echo ""
    print_info "当前目录: $(pwd)"
    print_info "项目根目录: $PROJECT_ROOT"
    print_info "Infra 目录: $INFRA_DIR"
    echo ""

    # 确认删除
    confirm_deletion

    # 开始清理
    print_info "开始清理 Terraform 资源..."
    cleanup_terraform

    echo ""
    print_success "🎉 Terraform 清理完成!"
    print_info "你可以通过以下命令验证清理结果:"
    echo "  cd $INFRA_DIR && terraform show"
}

# 运行主函数
main "$@"