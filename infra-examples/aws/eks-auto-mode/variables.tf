variable "aws_region" {
  description = "The AWS Region in which to deploy the resources"
  type        = string
}
variable "private_subnets" {
  description = "List of private subnets"
  type        = list(string)
  default     = []
}
variable "public_subnets" {
  description = "List of public subnets"
  type        = list(string)
  default     = []
}
variable "cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}
variable "azs" {
  description = "List of availability zones to use"
  type        = list(string)
  default     = []
}
variable "vpc_name" {
  description = "The VPC name"
  type        = string
}
variable "enable_nat_gateway" {
  description = "Enable NAT Gateway"
  type        = bool
  default     = true
}
variable "single_nat_gateway" {
  description = "Single NAT Gateway"
  type        = bool
  default     = false
}
variable "one_nat_gateway_per_az" {
  description = "One NAT gateway per AZ"
  type        = bool
  default     = true
}
variable "cluster_version" {
  default     = "1.29"
  type        = string
  description = "Kubernetes version"
}
variable "cluster_name" {
  type        = string
  description = "Name of the cluster"
}
variable "iam_role_use_name_prefix" {
  description = "Determinate if it is necessary to create an iam role prefix for the cluster"
  type        = bool
  default     = true
}
variable "node_iam_role_use_name_prefix" {
  description = "Determinate if it is necessary to create an iam role prefix for the nodes"
  type        = bool
  default     = true
}
variable "iam_role_name" {
  description = "Cluster IAM role name"
  type        = string
  default     = null
}
variable "node_iam_role_name" {
  description = "Cluster node IAM role name"
  type        = string
  default     = null
}
variable "cluster_security_group_use_name_prefix" {
  description = "Determinate if it is necessary to create an security group prefix for the cluster"
  type        = bool
  default     = true
}
variable "cluster_security_group_name" {
  description = "Cluster security group name"
  type        = string
  default     = null
}
variable "cluster_security_group_description" {
  description = "Cluster security group description"
  type        = string
  default     = "EKS cluster security group"
}
variable "cluster_tags" {
  description = "A map of tags to add to the cluster"
  type        = map(string)
  default     = {}
}
variable "additional_tags" {
  description = "Tags to add to all resources"
  type        = map(string)
  default     = {}
}
variable "vpc_id" {
  type        = string
  default     = null
  description = "Existing VPC Id. Set it to skip VPC creation."
}
variable "private_subnet_ids" {
  description = "List of existing private subnet ids. Set it to skip VPC creation."
  type        = list(string)
  default     = null
}
variable "node_pools" {
  description = "List of node pools for EKS in auto mode. Set to an empty list to disable build-in node pools."
  type        = list(string)
  default     = ["general-purpose"]
}
variable "bastion_sg" {
  description = "Security group of the bastion host. Set to the bastion host SG id to allow access from the bastion host."
  type        = string
  default     = null
}