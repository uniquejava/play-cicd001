output "cluster_name" {
  description = "Kubernetes Cluster Name"
  value       = aws_eks_cluster.cluster.name
}

output "cluster_endpoint" {
  description = "EKS cluster endpoint"
  value       = aws_eks_cluster.cluster.endpoint
}

output "cluster_certificate_authority_data" {
  description = "EKS cluster certificate authority data"
  value       = aws_eks_cluster.cluster.certificate_authority[0].data
}

output "cluster_security_group_id" {
  description = "Security group id attached to the EKS cluster control plane"
  value       = aws_eks_cluster.cluster.vpc_config[0].cluster_security_group_id
}

output "region" {
  description = "AWS region"
  value       = var.aws_region
}

output "node_role_arn" {
  description = "ARN of the node role"
  value       = aws_iam_role.eks_node_role.arn
}

output "configure_kubectl" {
  description = "Configure kubectl: make sure you're logged in with the right AWS profile and run the following command to update your kubeconfig"
  value       = "aws eks --region ${var.aws_region} update-kubeconfig --name ${aws_eks_cluster.cluster.name}"
}