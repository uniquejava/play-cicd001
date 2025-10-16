# VPC Module
module "vpc" {
  source = "./modules/vpc"

  aws_region      = var.aws_region
  project_name    = var.project_name
  environment     = var.environment
  vpc_cidr        = var.vpc_cidr
  private_subnets = var.private_subnets
  public_subnets  = var.public_subnets

  tags = var.common_tags
}

# EKS Module - 使用官方模块
module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "21.4.0"

  cluster_name    = var.cluster_name
  cluster_version = var.eks_version

  cluster_endpoint_public_access = true

  vpc_id                   = module.vpc.vpc_id
  subnet_ids               = module.vpc.private_subnets
  control_plane_subnet_ids = module.vpc.public_subnets

  eks_managed_node_groups = {
    workers = {
      min_size       = 1
      max_size       = 3
      desired_size   = 2
      instance_types = ["t3.medium"]
    }
  }

  tags = var.common_tags
}

# ECR Module
module "ecr" {
  source = "./modules/ecr"

  project_name = var.project_name
  environment  = var.environment

  repository_names = var.ecr_repositories

  image_tag_mutability = "MUTABLE"
  encryption_type     = "AES256"
  scan_on_push        = true

  tags = var.common_tags
}

# Data sources for EKS cluster authentication
data "aws_eks_cluster" "cluster" {
  name = module.eks.cluster_name
  depends_on = [module.eks]
}

data "aws_eks_cluster_auth" "cluster" {
  name = module.eks.cluster_name
  depends_on = [module.eks]
}