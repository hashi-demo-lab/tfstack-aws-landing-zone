component "vpc" {
  source  = "app.terraform.io/hashi-demos-apj/vpc/aws"
  version = "6.5.0"

  inputs = {
    name   = var.vpc_name
    cidr   = var.vpc_cidr

    azs             = var.azs
    private_subnets = var.private_subnets
    public_subnets  = var.public_subnets

    enable_nat_gateway = var.enable_nat_gateway
    enable_vpn_gateway = var.enable_vpn_gateway

    tags = {
      Name        = var.vpc_name
      Environment = var.environment
    }
  }

  providers = {
    aws = provider.aws.this
  }
}
