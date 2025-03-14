module "eks" {
  source                         = "terraform-aws-modules/eks/aws"
  version                        = "~> 20.33"
  cluster_name                   = var.cluster_name
  cluster_version                = var.cluster_version
  cluster_endpoint_public_access = true
  enable_cluster_creator_admin_permissions = true

  cluster_compute_config = {
    enabled    = true
    node_pools = var.node_pools
  }

  # If vpc_id and subnet_ids are provided, do not create them.
  vpc_id       = length(module.vpc) > 0 ? module.vpc[0].vpc_id : var.vpc_id
  subnet_ids   = length(module.vpc) > 0 ? module.vpc[0].private_subnets : var.private_subnet_ids
  cluster_tags                   = var.cluster_tags
  tags                           = var.additional_tags

  # Disable secrets encryption
  cluster_encryption_config = {}

  iam_role_use_name_prefix = var.iam_role_use_name_prefix
  iam_role_name            = var.iam_role_name
  node_iam_role_use_name_prefix = var.node_iam_role_use_name_prefix
  node_iam_role_name            = var.node_iam_role_name

  # Add a rule for the bastion host if needed.
  cluster_security_group_additional_rules = var.bastion_sg != null ? {
	  from_bastion = {
		  type                     = "ingress"
		  from_port                = 0
		  to_port                  = 0
		  protocol                 = "-1"
		  source_security_group_id = var.bastion_sg
		  description              = "Allow all traffic from bastion security group"
	  }
  } : null

}

# Create access entries for nodes for the Karpenter autoscaler to work.
resource "aws_eks_access_entry" "node_access_entry" {
  cluster_name      = module.eks.cluster_name
  principal_arn     = module.eks.node_iam_role_arn
  type              = "EC2"
}

resource "aws_eks_access_policy_association" "node_access_policy" {
  cluster_name  = module.eks.cluster_name
  policy_arn    = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSAutoNodePolicy"
  principal_arn = module.eks.node_iam_role_arn

  access_scope {
    type       = "cluster"
  }
}

# Attach Inline policy to the IAM role created by the EKS module.iam_role_additional_policies.
# This is required to make Karpenter work with custom node pools.
# See https://docs.aws.amazon.com/eks/latest/userguide/auto-learn-iam.html#tag-prop
# and https://github.com/aws/containers-roadmap/issues/2487
resource "aws_iam_role_policy" "fix-eks-auto-mode" {
  name = "fix-eks-auto-mode"
  role = module.eks.node_iam_role_name

  policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "Compute",
            "Effect": "Allow",
            "Action": [
                "ec2:CreateFleet",
                "ec2:RunInstances",
                "ec2:CreateLaunchTemplate"
            ],
            "Resource": "*",
            "Condition": {
                "StringEquals": {
                    "aws:RequestTag/eks:eks-cluster-name": "$${aws:PrincipalTag/eks:eks-cluster-name}"
                },
                "StringLike": {
                    "aws:RequestTag/eks:kubernetes-node-class-name": "*",
                    "aws:RequestTag/eks:kubernetes-node-pool-name": "*"
                }
            }
        },
        {
            "Sid": "Storage",
            "Effect": "Allow",
            "Action": [
                "ec2:CreateVolume",
                "ec2:CreateSnapshot"
            ],
            "Resource": [
                "arn:aws:ec2:*:*:volume/*",
                "arn:aws:ec2:*:*:snapshot/*"
            ],
            "Condition": {
                "StringEquals": {
                    "aws:RequestTag/eks:eks-cluster-name": "$${aws:PrincipalTag/eks:eks-cluster-name}"
                }
            }
        },
        {
            "Sid": "Networking",
            "Effect": "Allow",
            "Action": "ec2:CreateNetworkInterface",
            "Resource": "*",
            "Condition": {
                "StringEquals": {
                    "aws:RequestTag/eks:eks-cluster-name": "$${aws:PrincipalTag/eks:eks-cluster-name}"
                },
                "StringLike": {
                    "aws:RequestTag/eks:kubernetes-cni-node-name": "*"
                }
            }
        },
        {
            "Sid": "LoadBalancer",
            "Effect": "Allow",
            "Action": [
                "elasticloadbalancing:CreateLoadBalancer",
                "elasticloadbalancing:CreateTargetGroup",
                "elasticloadbalancing:CreateListener",
                "elasticloadbalancing:CreateRule",
                "ec2:CreateSecurityGroup"
            ],
            "Resource": "*",
            "Condition": {
                "StringEquals": {
                    "aws:RequestTag/eks:eks-cluster-name": "$${aws:PrincipalTag/eks:eks-cluster-name}"
                }
            }
        },
        {
            "Sid": "ShieldProtection",
            "Effect": "Allow",
            "Action": [
                "shield:CreateProtection"
            ],
            "Resource": "*",
            "Condition": {
                "StringEquals": {
                    "aws:RequestTag/eks:eks-cluster-name": "$${aws:PrincipalTag/eks:eks-cluster-name}"
                }
            }
        },
        {
            "Sid": "ShieldTagResource",
            "Effect": "Allow",
            "Action": [
                "shield:TagResource"
            ],
            "Resource": "arn:aws:shield::*:protection/*",
            "Condition": {
                "StringEquals": {
                    "aws:RequestTag/eks:eks-cluster-name": "$${aws:PrincipalTag/eks:eks-cluster-name}"
                }
            }
        }
    ]
  })
}

