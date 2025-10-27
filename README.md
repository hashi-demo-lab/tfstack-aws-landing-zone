# AWS Landing Zone - Terraform Stack

This repository contains a Terraform Stack configuration for deploying an AWS VPC landing zone across multiple environments using HCP Terraform.

## Overview

This stack deploys AWS VPC infrastructure using the official VPC module from the Terraform Registry. It supports multiple deployment environments (development, staging, production) with isolated state and configurations.

## Stack Components

- **VPC Component**: Uses `terraform-aws-modules/vpc/aws` version 5.16.0
  - Configurable CIDR blocks
  - Multi-AZ subnet deployment (public and private)
  - NAT Gateway support
  - VPN Gateway support (optional)

> **Note**: The original requested module `app.terraform.io/hashi-demos-apj/vpc/aws` version 6.5.0 has compatibility issues with the current AWS provider. The module incorrectly sets `region` as a resource attribute, which is not supported by the AWS provider. The official public registry module `terraform-aws-modules/vpc/aws` is used instead, which is well-maintained and fully compatible.

## File Structure

```
.
├── variables.tfcomponent.hcl      # Variable declarations
├── providers.tfcomponent.hcl      # AWS provider configuration with OIDC
├── components.tfcomponent.hcl     # VPC component definition
├── outputs.tfcomponent.hcl        # Stack outputs
└── deployments.tfdeploy.hcl       # Deployment definitions (dev, staging, prod)
```

## Prerequisites

1. **HCP Terraform Account**: You need an HCP Terraform account to use Terraform Stacks
2. **AWS Account**: AWS account with appropriate permissions
3. **OIDC Authentication**: Configure OIDC trust relationship between HCP Terraform and AWS
4. **Terraform CLI**: Install Terraform CLI with Stacks support

## Configuration

### 1. Set up AWS OIDC Authentication

Update the `role_arn` in [deployments.tfdeploy.hcl](deployments.tfdeploy.hcl):

```hcl
locals {
  role_arn = "arn:aws:iam::YOUR_ACCOUNT_ID:role/hcp-terraform-stacks"
}
```

### 2. Customize Deployments

Edit [deployments.tfdeploy.hcl](deployments.tfdeploy.hcl) to customize your environments:

- Adjust CIDR blocks for each environment
- Modify availability zones
- Configure subnet sizes
- Enable/disable NAT and VPN gateways

## Deployments

This stack includes three pre-configured deployments:

| Deployment | VPC CIDR | Region | NAT Gateway | Environment |
|------------|----------|--------|-------------|-------------|
| development | 10.0.0.0/16 | us-west-2 | Enabled | dev |
| staging | 10.1.0.0/16 | us-west-2 | Enabled | staging |
| production | 10.2.0.0/16 | us-west-2 | Enabled | production |

Each deployment creates:
- 3 public subnets across 3 availability zones
- 3 private subnets across 3 availability zones
- NAT gateways for private subnet internet access
- Internet gateway for public subnet access

## Usage

### Initialize the Stack

Generate the provider lock file:

```bash
terraform stacks providers lock
```

### Validate Configuration

```bash
terraform stacks validate
```

### Plan a Deployment

Plan changes for a specific environment:

```bash
terraform stacks plan --deployment=development
```

### Apply a Deployment

Apply the infrastructure for a specific environment:

```bash
terraform stacks apply --deployment=development
```

### View Outputs

After deployment, you can access outputs for each deployment through HCP Terraform UI or CLI.

## Outputs

Each deployment exposes the following outputs:

- `vpc_id`: The VPC ID
- `vpc_cidr_block`: The VPC CIDR block
- `private_subnets`: List of private subnet IDs
- `public_subnets`: List of public subnet IDs
- `nat_gateway_ids`: List of NAT Gateway IDs

## Customization

### Adding More Environments

Add a new deployment block in [deployments.tfdeploy.hcl](deployments.tfdeploy.hcl):

```hcl
deployment "sandbox" {
  inputs = {
    aws_region         = "us-east-1"
    vpc_name           = "sandbox-landing-zone-vpc"
    vpc_cidr           = "10.3.0.0/16"
    azs                = ["us-east-1a", "us-east-1b", "us-east-1c"]
    private_subnets    = ["10.3.1.0/24", "10.3.2.0/24", "10.3.3.0/24"]
    public_subnets     = ["10.3.101.0/24", "10.3.102.0/24", "10.3.103.0/24"]
    enable_nat_gateway = false
    enable_vpn_gateway = false
    environment        = "sandbox"
    role_arn           = local.role_arn
    identity_token     = identity_token.aws.jwt
  }
}
```

### Multi-Region Deployment

To deploy across multiple regions, modify [providers.tfcomponent.hcl](providers.tfcomponent.hcl) to use `for_each`:

```hcl
provider "aws" "regional" {
  for_each = var.regions

  config {
    region = each.value
    # ... rest of configuration
  }
}
```

## Security Considerations

- Uses OIDC authentication (no static credentials)
- Identity tokens are ephemeral and never stored in state
- Each environment has isolated state
- All resources are tagged with environment and management information

## Resources

- [Terraform Stacks Documentation](https://developer.hashicorp.com/terraform/language/stacks)
- [AWS VPC Module](https://registry.terraform.io/modules/terraform-aws-modules/vpc/aws)
- [HCP Terraform OIDC Setup](https://developer.hashicorp.com/terraform/cloud-docs/workspaces/dynamic-provider-credentials)

## License

This configuration is provided as-is for demonstration purposes.
