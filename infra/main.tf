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

# EKS Module
module "eks" {
  source = "./modules/eks"

  aws_region    = var.aws_region
  project_name  = var.project_name
  environment   = var.environment
  cluster_name  = var.cluster_name
  eks_version   = var.eks_version

  vpc_id          = module.vpc.vpc_id
  private_subnets = module.vpc.private_subnets
  public_subnets  = module.vpc.public_subnets

  instance_type = var.instance_type
  desired_size  = var.desired_size
  max_size      = var.max_size
  min_size      = var.min_size
  ssh_key_name  = var.ssh_key_name

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
# Note: These are conditional resources that will be created after the cluster exists
data "aws_eks_cluster" "cluster" {
  name = module.eks.cluster_name
  depends_on = [module.eks]
}

data "aws_eks_cluster_auth" "cluster" {
  name = module.eks.cluster_name
  depends_on = [module.eks]
}