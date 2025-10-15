#!/bin/bash

# =============================================================================
# EKS Cluster Cleanup Script
# Author: PES-SongBai
# Created: 2025-10-15
# Purpose: Delete all AWS resources created for EKS demo to save costs
# =============================================================================

set -e  # Exit on any error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
CLUSTER_NAME="ticket-system-eks"
REGION="ap-southeast-1"
PROJECT_TAG="ticket-management"
ENVIRONMENT_TAG="dev"

# Function to print colored output
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Function to confirm before proceeding
confirm_deletion() {
    echo -e "${RED}⚠️  WARNING: This will delete all EKS-related resources!${NC}"
    echo -e "${RED}This action cannot be undone and will incur costs until cleanup is complete.${NC}"
    echo ""
    echo "Resources to be deleted:"
    echo "  - EKS Cluster: $CLUSTER_NAME"
    echo "  - EKS Node Groups"
    echo "  - VPC and related networking resources"
    echo "  - IAM Roles"
    echo "  - Security Groups"
    echo "  - EIPs"
    echo "  - NAT Gateways"
    echo ""
    read -p "Are you sure you want to proceed? (yes/no): " confirm

    if [[ $confirm != "yes" ]]; then
        echo "Cleanup cancelled."
        exit 0
    fi
}

# Function to delete Terraform resources
cleanup_terraform() {
    print_status "Starting Terraform cleanup..."

    if [ ! -d "infra" ]; then
        print_error "infra directory not found!"
        exit 1
    fi

    cd infra

    if [ ! -f "terraform.tfstate" ]; then
        print_warning "No Terraform state file found. Resources might not be managed by Terraform."
        return
    fi

    # Destroy Terraform resources
    print_status "Running terraform destroy..."
    terraform destroy -auto-approve

    cd ..
    print_success "Terraform cleanup completed."
}

# Function to delete EKS cluster directly (backup method)
cleanup_eks_directly() {
    print_status "Starting direct EKS cleanup..."

    # Delete EKS cluster
    if aws eks describe-cluster --name "$CLUSTER_NAME" --region "$REGION" >/dev/null 2>&1; then
        print_status "Deleting EKS cluster: $CLUSTER_NAME"
        aws eks delete-cluster --name "$CLUSTER_NAME" --region "$REGION"

        print_status "Waiting for EKS cluster deletion to complete..."
        aws eks wait cluster-deleted --name "$CLUSTER_NAME" --region "$REGION"
        print_success "EKS cluster deleted."
    else
        print_warning "EKS cluster $CLUSTER_NAME not found."
    fi
}

# Function to delete node groups
cleanup_node_groups() {
    print_status "Deleting EKS node groups..."

    # Get all node groups for the cluster
    NODE_GROUPS=$(aws eks list-nodegroups --cluster-name "$CLUSTER_NAME" --region "$REGION" --query 'nodegroups' --output text 2>/dev/null || true)

    if [ -n "$NODE_GROUPS" ]; then
        for node_group in $NODE_GROUPS; do
            print_status "Deleting node group: $node_group"
            aws eks delete-node-group --cluster-name "$CLUSTER_NAME" --nodegroup-name "$node_group" --region "$REGION"
            aws eks wait nodegroup-deleted --cluster-name "$CLUSTER_NAME" --nodegroup-name "$node_group" --region "$REGION"
        done
        print_success "All node groups deleted."
    else
        print_warning "No node groups found."
    fi
}

# Function to delete IAM roles
cleanup_iam_roles() {
    print_status "Deleting IAM roles..."

    # Delete EKS cluster role
    CLUSTER_ROLE="${CLUSTER_NAME}-cluster-role"
    if aws iam get-role --role-name "$CLUSTER_ROLE" >/dev/null 2>&1; then
        print_status "Deleting cluster role: $CLUSTER_ROLE"
        # Detach policies first
        aws iam detach-role-policy --role-name "$CLUSTER_ROLE" --policy-arn arn:aws:iam::aws:policy/AmazonEKSClusterPolicy
        # Delete role
        aws iam delete-role --role-name "$CLUSTER_ROLE"
    fi

    # Delete EKS node role
    NODE_ROLE="${CLUSTER_NAME}-node-role"
    if aws iam get-role --role-name "$NODE_ROLE" >/dev/null 2>&1; then
        print_status "Deleting node role: $NODE_ROLE"
        # Detach policies
        aws iam detach-role-policy --role-name "$NODE_ROLE" --policy-arn arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy
        aws iam detach-role-policy --role-name "$NODE_ROLE" --policy-arn arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy
        aws iam detach-role-policy --role-name "$NODE_ROLE" --policy-arn arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly
        # Delete role
        aws iam delete-role --role-name "$NODE_ROLE"
    fi

    print_success "IAM roles cleanup completed."
}

# Function to delete VPC resources
cleanup_vpc() {
    print_status "Deleting VPC resources..."

    # Find VPC by tag
    VPC_ID=$(aws ec2 describe-vpcs --region "$REGION" --filters "Name=tag:Project,Values=$PROJECT_TAG" "Name=tag:Environment,Values=$ENVIRONMENT_TAG" --query 'Vpcs[0].VpcId' --output text 2>/dev/null || true)

    if [ "$VPC_ID" != "None" ] && [ -n "$VPC_ID" ]; then
        print_status "Found VPC: $VPC_ID"

        # Delete subnets
        SUBNET_IDS=$(aws ec2 describe-subnets --region "$REGION" --filters "Name=vpc-id,Values=$VPC_ID" --query 'Subnets[].SubnetId' --output text)
        for subnet_id in $SUBNET_IDS; do
            if [ "$subnet_id" != "None" ] && [ -n "$subnet_id" ]; then
                print_status "Deleting subnet: $subnet_id"
                aws ec2 delete-subnet --subnet-id "$subnet_id" --region "$REGION" || true
            fi
        done

        # Delete route tables
        RT_IDS=$(aws ec2 describe-route-tables --region "$REGION" --filters "Name=vpc-id,Values=$VPC_ID" --query 'RouteTables[?!(Associations[0].Main)].RouteTableId' --output text)
        for rt_id in $RT_IDS; do
            if [ "$rt_id" != "None" ] && [ -n "$rt_id" ]; then
                print_status "Deleting route table: $rt_id"
                aws ec2 delete-route-table --route-table-id "$rt_id" --region "$REGION" || true
            fi
        done

        # Delete internet gateway
        IGW_ID=$(aws ec2 describe-internet-gateways --region "$REGION" --filters "Name=attachment.vpc-id,Values=$VPC_ID" --query 'InternetGateways[0].InternetGatewayId' --output text 2>/dev/null || true)
        if [ "$IGW_ID" != "None" ] && [ -n "$IGW_ID" ]; then
            print_status "Deleting internet gateway: $IGW_ID"
            aws ec2 detach-internet-gateway --internet-gateway-id "$IGW_ID" --vpc-id "$VPC_ID" --region "$REGION" || true
            aws ec2 delete-internet-gateway --internet-gateway-id "$IGW_ID" --region "$REGION" || true
        fi

        # Delete NAT gateway and EIP
        NAT_IDS=$(aws ec2 describe-nat-gateways --region "$REGION" --filter "Name=vpc-id,Values=$VPC_ID" --query 'NatGateways[].NatGatewayId' --output text)
        for nat_id in $NAT_IDS; do
            if [ "$nat_id" != "None" ] && [ -n "$nat_id" ]; then
                print_status "Deleting NAT gateway: $nat_id"
                # Get and delete EIP first
                ALLOCATION_ID=$(aws ec2 describe-nat-gateways --region "$REGION" --nat-gateway-ids "$nat_id" --query 'NatGateways[0].NatGatewayAddresses[0].AllocationId' --output text)
                if [ "$ALLOCATION_ID" != "None" ] && [ -n "$ALLOCATION_ID" ]; then
                    aws ec2 release-address --allocation-id "$ALLOCATION_ID" --region "$REGION" || true
                fi
                aws ec2 delete-nat-gateway --nat-gateway-id "$nat_id" --region "$REGION" || true
            fi
        done

        # Delete security groups
        SG_IDS=$(aws ec2 describe-security-groups --region "$REGION" --filters "Name=vpc-id,Values=$VPC_ID" --query 'SecurityGroups[?!(GroupName =~ /^default|^sg-/)].GroupId' --output text)
        for sg_id in $SG_IDS; do
            if [ "$sg_id" != "None" ] && [ -n "$sg_id" ]; then
                print_status "Deleting security group: $sg_id"
                aws ec2 delete-security-group --group-id "$sg_id" --region "$REGION" || true
            fi
        done

        # Finally delete VPC
        print_status "Deleting VPC: $VPC_ID"
        aws ec2 delete-vpc --vpc-id "$VPC_ID" --region "$REGION" || true

    else
        print_warning "No tagged VPC found for cleanup."
    fi

    print_success "VPC cleanup completed."
}

# Function to delete ECR repositories
cleanup_ecr() {
    print_status "Deleting ECR repositories..."

    REPO_NAMES=$(aws ecr describe-repositories --region "$REGION" --query 'repositories[?contains(repositoryName, `ticket-system`)].repositoryName' --output text 2>/dev/null || true)

    for repo_name in $REPO_NAMES; do
        if [ "$repo_name" != "None" ] && [ -n "$repo_name" ]; then
            print_status "Deleting ECR repository: $repo_name"
            # Delete all images first
            IMAGE_IDS=$(aws ecr list-images --repository-name "$repo_name" --region "$REGION" --query 'imageIds' --output text 2>/dev/null || true)
            if [ -n "$IMAGE_IDS" ]; then
                aws ecr batch-delete-image --repository-name "$repo_name" --image-ids $IMAGE_IDS --region "$REGION" || true
            fi
            # Delete repository
            aws ecr delete-repository --repository-name "$repo_name" --region "$REGION" --force || true
        fi
    done

    print_success "ECR cleanup completed."
}

# Function to show cost summary
show_cost_summary() {
    print_status "Cost Savings Summary:"
    echo "  - EKS Cluster: ~$73/month -> $0/month"
    echo "  - 2x t3.medium: ~$60/month -> $0/month"
    echo "  - NAT Gateway: ~$35/month -> $0/month"
    echo "  - EIP: ~$3.65/month -> $0/month"
    echo "  - Data Transfer: ~$5-10/month -> $0/month"
    echo ""
    echo "  Total monthly savings: ~$170/month"
    echo ""
}

# Main execution
main() {
    echo "=================================================================="
    echo "🧹 EKS Cluster Cleanup Script"
    echo "=================================================================="
    echo "This script will delete all AWS resources created for the EKS demo."
    echo ""

    # Check AWS CLI
    if ! command -v aws &> /dev/null; then
        print_error "AWS CLI is not installed or not in PATH"
        exit 1
    fi

    # Verify AWS credentials
    if ! aws sts get-caller-identity &> /dev/null; then
        print_error "AWS credentials are not configured properly"
        exit 1
    fi

    print_success "AWS CLI configured successfully"
    print_success "Current identity: $(aws sts get-caller-identity --query 'Arn' --output text)"

    # Show current resources
    print_status "Current resources to be cleaned up:"

    # Show EKS clusters
    EKS_CLUSTERS=$(aws eks list-clusters --region "$REGION" --query 'clusters[?contains(@, `ticket-system`)]' --output text 2>/dev/null || true)
    if [ -n "$EKS_CLUSTERS" ]; then
        echo "  EKS Clusters: $EKS_CLUSTERS"
    fi

    # Show tagged VPCs
    VPC_COUNT=$(aws ec2 describe-vpcs --region "$REGION" --filters "Name=tag:Project,Values=$PROJECT_TAG" "Name=tag:Environment,Values=$ENVIRONMENT_TAG" --query 'length(Vpcs)' --output text 2>/dev/null || echo "0")
    if [ "$VPC_COUNT" != "0" ]; then
        echo "  Tagged VPCs: $VPC_COUNT"
    fi

    echo ""

    # Confirm deletion
    confirm_deletion

    # Start cleanup
    print_status "Starting cleanup process..."

    # Try Terraform cleanup first
    if [ -d "infra" ] && [ -f "infra/terraform.tfstate" ]; then
        cleanup_terraform
    else
        print_warning "Terraform state not found, using direct AWS CLI cleanup..."
        cleanup_node_groups
        cleanup_eks_directly
        cleanup_vpc
        cleanup_iam_roles
    fi

    # Cleanup ECR (always run this)
    cleanup_ecr

    # Show cost summary
    show_cost_summary

    print_success "🎉 Cleanup completed successfully!"
    print_success "All EKS-related resources have been deleted."
    print_status "You can verify the cleanup by running:"
    echo "  aws eks list-clusters --region $REGION"
    echo "  aws ec2 describe-vpcs --region $REGION --filters Name=tag:Project,Values=$PROJECT_TAG"
}

# Run main function
main "$@"