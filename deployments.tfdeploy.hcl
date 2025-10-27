identity_token "aws" {
  audience = ["aws.workload.identity"]
}

locals {
  # Update this with your AWS IAM role ARN for HCP Terraform OIDC authentication
  role_arn = "arn:aws:iam::ACCOUNT_ID:role/hcp-terraform-stacks"
}

deployment "development" {
  inputs = {
    aws_region         = "us-west-2"
    vpc_name           = "dev-landing-zone-vpc"
    vpc_cidr           = "10.0.0.0/16"
    azs                = ["us-west-2a", "us-west-2b", "us-west-2c"]
    private_subnets    = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
    public_subnets     = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]
    enable_nat_gateway = true
    enable_vpn_gateway = false
    environment        = "dev"
    role_arn           = local.role_arn
    identity_token     = identity_token.aws.jwt
  }
}

deployment "staging" {
  inputs = {
    aws_region         = "us-west-2"
    vpc_name           = "staging-landing-zone-vpc"
    vpc_cidr           = "10.1.0.0/16"
    azs                = ["us-west-2a", "us-west-2b", "us-west-2c"]
    private_subnets    = ["10.1.1.0/24", "10.1.2.0/24", "10.1.3.0/24"]
    public_subnets     = ["10.1.101.0/24", "10.1.102.0/24", "10.1.103.0/24"]
    enable_nat_gateway = true
    enable_vpn_gateway = false
    environment        = "staging"
    role_arn           = local.role_arn
    identity_token     = identity_token.aws.jwt
  }
}

deployment "production" {
  inputs = {
    aws_region         = "us-west-2"
    vpc_name           = "prod-landing-zone-vpc"
    vpc_cidr           = "10.2.0.0/16"
    azs                = ["us-west-2a", "us-west-2b", "us-west-2c"]
    private_subnets    = ["10.2.1.0/24", "10.2.2.0/24", "10.2.3.0/24"]
    public_subnets     = ["10.2.101.0/24", "10.2.102.0/24", "10.2.103.0/24"]
    enable_nat_gateway = true
    enable_vpn_gateway = false
    environment        = "production"
    role_arn           = local.role_arn
    identity_token     = identity_token.aws.jwt
  }
}
