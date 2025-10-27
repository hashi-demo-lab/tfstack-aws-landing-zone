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

# Deployment group with automatic approval
orchestrate "auto_approve" "dev_teams" {
  check {
    # All deployments must have successful plans
    condition = context.plan.deployment_group_applyable
    reason    = "Plan must be successful for all deployments in the group"
  }
}

deployment_group "dev_teams_auto" {
  orchestration "auto_approve" "dev_teams" {}
}

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
# }
