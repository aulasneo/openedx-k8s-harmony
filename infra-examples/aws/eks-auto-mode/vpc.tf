module "vpc" {
  count           = var.vpc_id == null ? 1 : 0
  source          = "terraform-aws-modules/vpc/aws"
  version         = "~> 5.13"
  name            = var.vpc_name
  cidr            = var.cidr
  azs             = var.azs
  private_subnets = var.private_subnets
  public_subnets  = var.public_subnets

  enable_nat_gateway     = var.enable_nat_gateway
  single_nat_gateway     = var.single_nat_gateway
  one_nat_gateway_per_az = var.one_nat_gateway_per_az

  tags = var.additional_tags

  # Tag the subnets so the ELB is properly created
  private_subnet_tags = {
    "kubernetes.io/role/internal-elb": "1"
  }
  public_subnet_tags = {
    "kubernetes.io/role/elb": "1"
  }
}
