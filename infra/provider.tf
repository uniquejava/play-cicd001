provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Project     = "ticket-management"
      Environment = var.environment
      ManagedBy   = "terraform"
      Owner       = "PES-SongBai"
      CreatedAt   = "2025-10-15"
      Purpose     = "CI-CD-Demo"
    }
  }
}

provider "kubernetes" {
  host                   = data.aws_eks_cluster.cluster.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority[0].data)
  token                  = data.aws_eks_cluster_auth.token
}

provider "helm" {
  kubernetes {
    host                   = data.aws_eks_cluster.cluster.endpoint
    cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority[0].data)
    token                  = data.aws_eks_cluster_auth.token
  }
}