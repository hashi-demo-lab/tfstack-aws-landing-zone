# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a **Terraform Stack** configuration for deploying AWS VPC landing zones across multiple environments using HCP Terraform. It uses the Terraform Stacks feature (not workspaces) which requires Terraform CLI 1.13.4+ and HCP Terraform.

## Key Architecture Concepts

### Terraform Stacks Structure

This repository uses Terraform Stacks, NOT traditional Terraform modules. The key distinction:

- **Component files** (`.tfcomponent.hcl`): Define reusable infrastructure components and their configurations
- **Deployment files** (`.tfdeploy.hcl`): Define concrete deployment instances with specific input values
- **Stacks vs Workspaces**: Each deployment in a stack has isolated state, but they're managed together as a cohesive unit

The stack is organized into:

1. **variables.tfcomponent.hcl**: Stack-level variable declarations (NOT deployment-specific)
2. **providers.tfcomponent.hcl**: AWS provider configuration with OIDC authentication
3. **components.tfcomponent.hcl**: VPC component using a module from Terraform Registry
4. **outputs.tfcomponent.hcl**: Stack outputs exposed from component outputs
5. **deployments.tfdeploy.hcl**: Deployment definitions (development, staging, production)

### Authentication Pattern

This stack uses **OIDC (OpenID Connect) authentication** with AWS:
- Identity tokens are defined in `deployments.tfdeploy.hcl` using `identity_token` blocks
- Each deployment can have its own identity token and IAM role ARN
- The `identity_token` variable is marked as `ephemeral = true` (never persisted in state)
- Provider configuration uses `assume_role_with_web_identity` with the identity token

### Module Source Note

The VPC component sources from `app.terraform.io/hashi-demos-apj/vpc/aws` v6.5.0 (a private registry module). The README mentions this module has compatibility issues and suggests using `terraform-aws-modules/vpc/aws` from the public registry instead if needed.

## Common Commands

### Lock File Management
```bash
# Update provider lock file (required after provider version changes)
terraform stacks providers-lock

# If lock file has version conflicts, remove and recreate:
rm .terraform.lock.hcl && terraform stacks providers-lock
```

### Validation
```bash
# Validate entire stack configuration
terraform stacks validate
```

### Planning and Applying
```bash
# Plan changes for a specific deployment
terraform stacks plan --deployment=development
terraform stacks plan --deployment=staging
terraform stacks plan --deployment=production

# Apply infrastructure for a specific deployment
terraform stacks apply --deployment=development
```

### Stack Management
```bash
# Initialize stack (if needed)
terraform stacks init

# Format stack configuration files
terraform stacks fmt

# View help for any command
terraform stacks <command> -usage
```

## Configuration Patterns

### Adding New Deployments

When adding a new deployment to `deployments.tfdeploy.hcl`:

1. Create a unique `identity_token` block if the deployment needs its own token
2. Add the IAM role ARN to the `locals` block
3. Create a new `deployment` block with appropriate inputs
4. Ensure availability zones match the specified region
5. Use non-overlapping CIDR blocks across all deployments

### Multi-Region Considerations

- Currently all deployments use `ap-southeast-2` region
- Availability zones must be valid for the specified region (e.g., `ap-southeast-2a`, `ap-southeast-2b`, `ap-southeast-2c`)
- Each deployment can target a different region by changing `aws_region` and `azs` inputs

### Identity Token Architecture

Each deployment should use its own identity token for isolation:
- Identity tokens are defined at the deployment file level
- Reference them in deployment inputs as `identity_token = identity_token.<name>.jwt`
- Each token can authenticate to a different IAM role via the `role_arn` input

## Important Constraints

- **No `terraform init`**: Stacks do not use traditional `terraform init`. Use `terraform stacks init` instead.
- **No `-upgrade` flag**: The `providers-lock` command does not support an upgrade flag. Remove the lock file to upgrade providers.
- **OIDC Required**: This stack requires OIDC trust relationship configured between HCP Terraform and AWS IAM.
- **HCP Terraform Only**: Stacks are designed for HCP Terraform and won't work with local Terraform execution.
- **Provider Configuration**: The AWS provider is configured in `providers.tfcomponent.hcl` using OIDC, not through environment variables or static credentials.

## File Editing Guidelines

- When modifying deployment regions, always update both `aws_region` and `azs` inputs together
- When changing provider versions in `providers.tfcomponent.hcl`, always run `terraform stacks providers-lock` afterward
- Identity token names should be descriptive (e.g., `aws_development`, `aws_staging`) not generic
- Each deployment's `role_arn` should point to an IAM role specific to that deployment/environment
