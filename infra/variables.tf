variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "ap-northeast-1"
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "dev"
}

variable "cluster_name" {
  description = "EKS cluster name"
  type        = string
  default     = "ticket-system-eks-final"
}

variable "eks_version" {
  description = "EKS Kubernetes version"
  type        = string
  default     = "1.34"
}

variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "private_subnets" {
  description = "Private subnets for EKS workers"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "public_subnets" {
  description = "Public subnets for load balancers"
  type        = list(string)
  default     = ["10.0.101.0/24", "10.0.102.0/24"]
}

variable "instance_type" {
  description = "EC2 instance type for worker nodes"
  type        = string
  default     = "t3.medium"
}

variable "desired_size" {
  description = "Desired number of worker nodes"
  type        = number
  default     = 2
}

variable "max_size" {
  description = "Maximum number of worker nodes"
  type        = number
  default     = 3
}

variable "min_size" {
  description = "Minimum number of worker nodes"
  type        = number
  default     = 1
}

variable "ssh_key_name" {
  description = "SSH key name for EC2 instances"
  type        = string
}

variable "ecr_repositories" {
  description = "List of ECR repository names"
  type        = list(string)
  default     = ["backend", "frontend"]
}

variable "project_name" {
  description = "Project name for tagging"
  type        = string
  default     = "ticket-management"
}

variable "common_tags" {
  description = "Common tags to apply to all resources"
  type        = map(string)
  default = {
    Project     = "ticket-management"
    Environment = "dev"
    ManagedBy   = "terraform"
    Owner       = "PES-SongBai"
    CreatedAt   = "2025-10-15"
    Purpose     = "CI-CD-Demo"
  }
}