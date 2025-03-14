output "vpc_id" {
  description = "The ID of the VPC"
  value       = length(module.vpc) > 0 ? module.vpc[0].vpc_id : var.vpc_id
}

output "vpc_arn" {
  description = "The ARN of the VPC"
  value       = length(module.vpc) > 0 ? module.vpc[0].vpc_id : var.vpc_id
}

output "cluster_name" {
  description = "The name of the EKS cluster."
  value       = module.eks.cluster_name
}

output "cluster_endpoint" {
  description = "Endpoint for your Kubernetes API server."
  value       = module.eks.cluster_endpoint
}

output "cluster_version" {
  description = "The Kubernetes version for the cluster."
  value       = module.eks.cluster_version
}

output "iam_node_role_name" {
  description = "IAM role name for nodes."
  value       = module.eks.node_iam_role_name
}

output "cluster_iam_role_name" {
  description = "Cluster IAM role name."
  value       = module.eks.cluster_iam_role_name
}

output "cluster_iam_role_arn" {
  description = "Cluster IAM role ARN."
  value       = module.eks.cluster_iam_role_arn
}

output "cluster_primary_security_group_id" {
  description = "Cluster primary security group ID."
  value       = module.eks.cluster_primary_security_group_id
}

output "cluster_additional_security_group_id" {
  description = "Cluster additional security group ID."
  value       = module.eks.cluster_security_group_id
}

output "cluster_additional_security_group_arn" {
  description = "Cluster additional security group ARN"
  value       = module.eks.cluster_security_group_arn
}
