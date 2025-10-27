# Component Configuration Block Reference

Complete reference for all blocks available in Terraform Stack component configuration files (`.tfcomponent.hcl`).

## Table of Contents

1. [Variable Block](#variable-block)
2. [Required Providers Block](#required-providers-block)
3. [Provider Block](#provider-block)
4. [Component Block](#component-block)
5. [Output Block](#output-block)
6. [Locals Block](#locals-block)
7. [Removed Block](#removed-block)

## Variable Block

Declares input variables for Stack configuration.

### Syntax

```hcl
variable "variable_name" {
  type        = <type>
  description = "<description>"
  default     = <value>
  sensitive   = <bool>
  nullable    = <bool>
  ephemeral   = <bool>
}
```

### Arguments

- **type** (required): Data type (string, number, bool, list, map, object, set, tuple, any)
- **description** (optional): Variable description
- **default** (optional): Default value
- **sensitive** (optional, default false): Mark as sensitive to redact from logs
- **nullable** (optional, default true): Whether null is allowed
- **ephemeral** (optional, default false): Do not persist to state file

### Differences from Traditional Terraform

- **type** is required (not optional)
- **validation** argument is not supported

### Examples

```hcl
variable "aws_region" {
  type        = string
  description = "AWS region for infrastructure"
  default     = "us-west-1"
}

variable "instance_count" {
  type        = number
  description = "Number of instances"
  nullable    = false
}

variable "identity_token" {
  type        = string
  description = "OIDC identity token"
  ephemeral   = true
}

variable "tags" {
  type = map(string)
  default = {
    Environment = "dev"
    ManagedBy   = "Terraform"
  }
}

variable "subnet_config" {
  type = object({
    cidr_block           = string
    availability_zone    = string
    map_public_ip        = bool
  })
}
```

## Required Providers Block

Declares provider dependencies.

### Syntax

```hcl
required_providers {
  <provider_name> = {
    source  = "<source>"
    version = "<version_constraint>"
  }
}
```

### Arguments

- **source** (required): Provider source address (e.g., "hashicorp/aws")
- **version** (optional): Version constraint (e.g., "~> 5.0")

### Examples

```hcl
required_providers {
  aws = {
    source  = "hashicorp/aws"
    version = "~> 5.7.0"
  }
  
  random = {
    source  = "hashicorp/random"
    version = "~> 3.5.0"
  }
  
  azurerm = {
    source  = "hashicorp/azurerm"
    version = ">= 3.0"
  }
}
```

## Provider Block

Configures provider instances.

### Syntax

```hcl
provider "<provider_type>" "<alias>" {
  for_each = <map_or_set>  # Optional
  
  config {
    <provider_arguments>
  }
}
```

### Arguments

- **provider_type** (label 1, required): Provider type (e.g., "aws", "azurerm")
- **alias** (label 2, required): Unique identifier for this provider configuration
- **for_each** (optional): Create multiple provider instances from a map or set
- **config** (required): Nested block containing provider-specific configuration

### Key Differences from Traditional Terraform

1. Alias is defined in block header, not as an argument
2. Configuration goes in a nested `config` block
3. Supports `for_each` meta-argument
4. Provider configurations are treated as first-class values

### Examples

**Single Provider:**

```hcl
provider "aws" "main" {
  config {
    region = var.aws_region
    
    default_tags {
      tags = var.common_tags
    }
  }
}
```

**Provider with OIDC Authentication:**

```hcl
provider "aws" "authenticated" {
  config {
    region = var.aws_region
    
    assume_role_with_web_identity {
      role_arn           = var.role_arn
      web_identity_token = var.identity_token
    }
  }
}
```

**Multiple Providers with for_each:**

```hcl
provider "aws" "regional" {
  for_each = toset(var.regions)
  
  config {
    region = each.value
    
    assume_role_with_web_identity {
      role_arn           = var.role_arn
      web_identity_token = var.identity_token
    }
  }
}
```

**Multiple Cloud Accounts:**

```hcl
provider "aws" "accounts" {
  for_each = var.aws_accounts
  
  config {
    region = var.default_region
    
    assume_role {
      role_arn = "arn:aws:iam::${each.value.account_id}:role/${var.role_name}"
    }
  }
}
```

## Component Block

Defines infrastructure components to include in the Stack.

### Syntax

```hcl
component "<component_name>" {
  for_each = <map_or_set>  # Optional
  
  source = "<module_source>"
  
  inputs = {
    <input_name> = <value>
  }
  
  providers = {
    <provider_local_name> = provider.<type>.<alias>[<key>]
  }
}
```

### Arguments

- **component_name** (label, required): Unique identifier for this component
- **for_each** (optional): Create multiple component instances
- **source** (required): Module source (see [Source Argument](#source-argument) below)
- **version** (optional): Version constraint for registry-based sources only
- **inputs** (required): Map of input variables for the module
- **providers** (required): Map of provider configurations

### Source Argument

The `source` argument accepts the same module sources as traditional Terraform configurations.

**Local File Path:**
```hcl
source = "./modules/vpc"
source = "../shared-modules/networking"
```

**Public Terraform Registry:**
```hcl
source = "terraform-aws-modules/vpc/aws"
source = "hashicorp/consul/aws"
```
Format: `<NAMESPACE>/<NAME>/<PROVIDER>`

**Private HCP Terraform Registry:**
```hcl
source = "app.terraform.io/my-org/vpc/aws"
source = "app.terraform.io/example-corp/networking/azurerm"
```
Format: `<HOSTNAME>/<ORGANIZATION>/<MODULE_NAME>/<PROVIDER_NAME>`

- **HCP Terraform (SaaS)**: Use hostname `app.terraform.io`
- **Terraform Enterprise**: Use your instance hostname (e.g., `terraform.mycompany.com`)
- **Generic hostname**: Use `localterraform.com` for deployments spanning multiple Terraform Enterprise instances

**Git Repository:**
```hcl
source = "git::https://github.com/org/repo.git//modules/vpc?ref=v1.0.0"
source = "git::ssh://git@github.com/org/repo.git//modules/vpc?ref=main"
```

**HTTP/HTTPS Archive:**
```hcl
source = "https://example.com/modules/vpc-module.tar.gz"
```

### Version Argument

The `version` argument is supported only for registry-based sources (public and private registries). Local file paths and Git sources do not support the `version` argument.

```hcl
component "vpc" {
  source  = "app.terraform.io/my-org/vpc/aws"
  version = "~> 2.0"  # Semantic versioning constraint

  inputs = {
    cidr_block = var.vpc_cidr
  }

  providers = {
    aws = provider.aws.main
  }
}
```

**Note**: Modules sourced from local file paths always share the same version as their caller and cannot have independent version constraints.

### Component References

Access component outputs using: `component.<name>.<output>`

For components with `for_each`: `component.<name>[<key>].<output>`

### Examples

**Basic Component (Local Module):**

```hcl
component "vpc" {
  source = "./modules/vpc"

  inputs = {
    cidr_block  = var.vpc_cidr
    name_prefix = var.name_prefix
  }

  providers = {
    aws = provider.aws.main
  }
}
```

**Component from Public Registry:**

```hcl
component "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 5.0"

  inputs = {
    cidr            = var.vpc_cidr
    azs             = var.availability_zones
    private_subnets = var.private_subnet_cidrs
    public_subnets  = var.public_subnet_cidrs
  }

  providers = {
    aws = provider.aws.main
  }
}
```

**Component from Private Registry:**

```hcl
component "vpc" {
  source  = "app.terraform.io/my-org/vpc/aws"
  version = "2.1.0"

  inputs = {
    cidr_block  = var.vpc_cidr
    name_prefix = var.name_prefix
    environment = var.environment
  }

  providers = {
    aws = provider.aws.main
  }
}
```

**Component with Dependencies:**

```hcl
component "database" {
  source = "./modules/rds"
  
  inputs = {
    vpc_id             = component.vpc.vpc_id
    subnet_ids         = component.vpc.private_subnet_ids
    security_group_ids = [component.security.database_sg_id]
    engine_version     = var.db_engine_version
  }
  
  providers = {
    aws = provider.aws.main
  }
}
```

**Component with for_each (Multi-Region):**

```hcl
component "regional_s3" {
  for_each = toset(var.regions)
  
  source = "./modules/s3"
  
  inputs = {
    region      = each.value
    bucket_name = "${var.app_name}-${each.value}"
    tags        = local.common_tags
  }
  
  providers = {
    aws = provider.aws.regional[each.value]
  }
}
```

**Component with Multiple Providers:**

```hcl
component "cross_region_replication" {
  source = "./modules/s3-replication"
  
  inputs = {
    source_bucket = var.source_bucket
    dest_bucket   = var.dest_bucket
  }
  
  providers = {
    aws.source = provider.aws.us_east
    aws.dest   = provider.aws.eu_west
  }
}
```

**Component with for_each over Map:**

```hcl
component "applications" {
  for_each = var.applications
  
  source = "./modules/application"
  
  inputs = {
    app_name        = each.key
    instance_type   = each.value.instance_type
    instance_count  = each.value.count
    vpc_id          = component.vpc.vpc_id
  }
  
  providers = {
    aws = provider.aws.main
  }
}
```

## Output Block

Exposes values from Stack configuration.

### Syntax

```hcl
output "<output_name>" {
  type        = <type>
  description = "<description>"
  value       = <expression>
  sensitive   = <bool>
  ephemeral   = <bool>
}
```

### Arguments

- **output_name** (label, required): Unique identifier for this output
- **type** (required): Data type of the output
- **description** (optional): Output description
- **value** (required): Expression to output
- **sensitive** (optional, default false): Mark as sensitive
- **ephemeral** (optional, default false): Ephemeral value

### Differences from Traditional Terraform

- **type** is required
- **precondition** block is not supported

### Examples

```hcl
output "vpc_id" {
  type        = string
  description = "VPC ID"
  value       = component.vpc.vpc_id
}

output "database_endpoint" {
  type        = string
  description = "Database endpoint"
  value       = component.database.endpoint
  sensitive   = true
}

output "regional_endpoints" {
  type        = map(string)
  description = "API endpoints by region"
  value       = {
    for region, comp in component.api_gateway : region => comp.endpoint_url
  }
}

output "instance_details" {
  type = object({
    id         = string
    public_ip  = string
    private_ip = string
  })
  description = "EC2 instance details"
  value = {
    id         = component.compute.instance_id
    public_ip  = component.compute.public_ip
    private_ip = component.compute.private_ip
  }
}
```

## Locals Block

Defines local values for reuse within the Stack configuration.

### Syntax

```hcl
locals {
  <name> = <expression>
}
```

### Examples

```hcl
locals {
  common_tags = {
    Environment = var.environment
    ManagedBy   = "Terraform Stacks"
    Project     = var.project_name
    CostCenter  = var.cost_center
  }
  
  name_prefix = "${var.project_name}-${var.environment}"
  
  region_config = {
    for region in var.regions : region => {
      name_suffix    = region
      instance_count = var.environment == "prod" ? 3 : 1
    }
  }
  
  availability_zones = [
    for az in var.availability_zones : az
    if can(regex("^${var.aws_region}", az))
  ]
}
```

## Removed Block

Declares components to be removed from the Stack.

### Syntax

```hcl
removed {
  from   = component.<component_name>
  source = "<original_module_source>"
  
  providers = {
    <provider_name> = provider.<type>.<alias>
  }
}
```

### Arguments

- **from** (required): Reference to the component being removed
- **source** (required): Original module source
- **providers** (required): Provider configurations needed for removal

### Important Notes

- Required for safe component removal
- Must include all providers the component used
- Do not remove providers before removing components that use them

### Examples

```hcl
removed {
  from   = component.old_component
  source = "./modules/deprecated-module"
  
  providers = {
    aws = provider.aws.main
  }
}

removed {
  from   = component.legacy_regional
  source = "registry.terraform.io/example/legacy/aws"
  
  providers = {
    aws    = provider.aws.main
    random = provider.random.main
  }
}
```

## Provider References in Component Blocks

### Single Provider

```hcl
providers = {
  aws = provider.aws.main
}
```

### Multiple Providers

```hcl
providers = {
  aws    = provider.aws.main
  random = provider.random.main
  tls    = provider.tls.main
}
```

### Provider from for_each

```hcl
providers = {
  aws = provider.aws.regional[each.value]
}
```

### Aliased Providers in Module

If module requires specific provider aliases:

```hcl
providers = {
  aws.source = provider.aws.us_east
  aws.dest   = provider.aws.eu_west
}
```
