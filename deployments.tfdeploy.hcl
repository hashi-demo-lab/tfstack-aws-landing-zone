# Unique identity token per team deployment
identity_token "aws_team1" {
  audience = ["aws.workload.identity"]
}

identity_token "aws_team2" {
  audience = ["aws.workload.identity"]
}

locals {
  # Update these with your AWS IAM role ARNs for HCP Terraform OIDC authentication
  # Each team deployment uses its own dedicated role
  team1_role_arn = "arn:aws:iam::ACCOUNT_ID:role/hcp-terraform-stacks-team1"
  team2_role_arn = "arn:aws:iam::ACCOUNT_ID:role/hcp-terraform-stacks-team2"
}

# Deployment group for both team deployments
deployment_group "dev_teams_auto" {}

deployment "vpc-team1-dev" {
  deployment_group = deployment_group.dev_teams_auto

  inputs = {
    aws_region         = "ap-southeast-2"
    vpc_name           = "team1-dev-vpc"
    vpc_cidr           = "10.0.0.0/16"
    azs                = ["ap-southeast-2a", "ap-southeast-2b", "ap-southeast-2c"]
    private_subnets    = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
    public_subnets     = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]
    enable_nat_gateway = true
    enable_vpn_gateway = false
    environment        = "dev"
    role_arn           = local.team1_role_arn
    identity_token     = identity_token.aws_team1.jwt
  }

}

publish_output "vpc_id" {
    value = deployment.vpc-team1-dev.vpc_id
}

publish_output "private_subnets" {
    value = deployment.vpc-team1-dev.private_subnets
}


# deployment "vpc-team2-dev" {
#   deployment_group = deployment_group.dev_teams_auto

#   inputs = {
#     aws_region         = "ap-southeast-1"
#     vpc_name           = "team2-dev-vpc"
#     vpc_cidr           = "10.1.0.0/16"
#     azs                = ["ap-southeast-1a", "ap-southeast-1b", "ap-southeast-1c"]
#     private_subnets    = ["10.1.1.0/24", "10.1.2.0/24", "10.1.3.0/24"]
#     public_subnets     = ["10.1.101.0/24", "10.1.102.0/24", "10.1.103.0/24"]
#     enable_nat_gateway = true
#     enable_vpn_gateway = false
#     environment        = "dev"
#     role_arn           = local.team2_role_arn
#     identity_token     = identity_token.aws_team2.jwt
#   }

#   publish_output "vpc_id" {
#     value = deployment.vpc-team2-dev.vpc_id
#   }

#   publish_output "private_subnets" {
#     value = deployment.vpc-team2-dev.private_subnets
#   }
# }
