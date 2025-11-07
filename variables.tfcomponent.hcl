variable "aws_region" {
  type        = string
  description = "AWS region for VPC deployment"
  default     = "us-west-2"
}

variable "vpc_name" {
  type        = string
  description = "Name of the VPC"
  default     = "landing-zone-vpc"
}

variable "vpc_cidr" {
  type        = string
  description = "CIDR block for VPC"
  default     = "10.0.0.0/16"
}

variable "azs" {
  type        = list(string)
  description = "Availability zones"
  default     = ["us-west-2a", "us-west-2b", "us-west-2c"]
}

variable "private_subnets" {
  type        = list(string)
  description = "Private subnet CIDR blocks"
  default     = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
}

variable "public_subnets" {
  type        = list(string)
  description = "Public subnet CIDR blocks"
  default     = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]
}

variable "enable_nat_gateway" {
  type        = bool
  description = "Enable NAT gateway for private subnets"
  default     = true
}

variable "enable_vpn_gateway" {
  type        = bool
  description = "Enable VPN gateway"
  default     = false
}

variable "role_arn" {
  type        = string
  description = "ARN of the IAM role to assume for AWS operations. Value provided by 'stacks-examples' variable set in HCP Terraform"
  sensitive   = true
  ephemeral   = true  # Required 
}

variable "identity_token" {
  type        = string
  description = "OIDC identity token for AWS authentication"
  ephemeral   = true
}

variable "environment" {
  type        = string
  description = "Environment name (e.g., dev, staging, prod)"
  default     = "dev"
}
