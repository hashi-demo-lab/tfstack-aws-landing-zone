output "vpc_id" {
  type        = string
  description = "The ID of the VPC"
  value       = component.vpc.vpc_id
}

output "vpc_cidr_block" {
  type        = string
  description = "The CIDR block of the VPC"
  value       = component.vpc.vpc_cidr_block
}

output "private_subnets" {
  type        = list(string)
  description = "List of IDs of private subnets"
  value       = component.vpc.private_subnets
}

output "public_subnets" {
  type        = list(string)
  description = "List of IDs of public subnets"
  value       = component.vpc.public_subnets
}

output "nat_gateway_ids" {
  type        = list(string)
  description = "List of NAT Gateway IDs"
  value       = component.vpc.natgw_ids
}
