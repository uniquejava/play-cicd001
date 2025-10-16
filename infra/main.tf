# Fixed cluster name
# Removed random_pet module to use consistent cluster name across deployments

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

# EKS Module - 使用稳定版本
module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "19.21.0"

  cluster_name    = "tix-eks-fresh-magpie"
  cluster_version = var.eks_version

  vpc_id          = module.vpc.vpc_id
  subnet_ids      = module.vpc.private_subnets

  cluster_endpoint_public_access = true

  eks_managed_node_groups = {
    workers = {
      min_size       = var.min_size
      max_size       = var.max_size
      desired_size   = var.desired_size
      instance_types = [var.instance_type]
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

