# LAB-05-AWS: Working with State, Data Sources, and CLI Commands

## Overview
In this lab, you will learn how to work with Terraform state, use data sources to query AWS information, and explore additional Terraform CLI commands. You'll create a test environment configuration, learn how to inspect and manage state, and properly clean up all resources. The lab introduces the concept of using data sources to make your configurations more dynamic and environment-aware.

[![Lab 05](https://github.com/btkrausen/terraform-testing/actions/workflows/aws_lab_validation.yml/badge.svg?branch=main&event=push&job=lab_05)](https://github.com/btkrausen/terraform-testing/actions/workflows/aws_lab_validation.yml)

**Preview Mode**: Use `Cmd/Ctrl + Shift + V` in VSCode to see a nicely formatted version of this lab!

## Prerequisites
- Terraform installed
- AWS account with appropriate permissions
- Completion of [LAB-04-AWS](https://github.com/btkrausen/terraform-codespaces/blob/main/labs/lab_04_managing_mulitple_resources/aws.md) with existing VPC and networking configuration

## Estimated Time
35 minutes

## Lab Steps

### 1. Explore Terraform CLI Commands

Let's start by exploring some useful Terraform CLI commands:

```bash
# View all available Terraform commands
terraform --help

# Get specific help about state commands
terraform state help

# Show current state resources
terraform state list

# Show details about a specific resource
terraform state show aws_vpc.main
```

### 2. Create a Test Environment Directory

Create a new directory for a development environment configuration:

```bash
# Create test directory at the same level as your terraform directory
cd ..
mkdir development
cd development

# Create configuration files
touch main.tf variables.tf providers.tf outputs.tf
```

### 3. Add Data Source Configurations

In the new `development` environment's `main.tf` file, add the following configuration to query AWS information:

```hcl
# Get information about available AZs
data "aws_availability_zones" "available" {
  state = "available"
}

# Get the current region
data "aws_region" "current" {}

# Get the current caller identity
data "aws_caller_identity" "current" {}

# Create a VPC using data source information
resource "aws_vpc" "development" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name        = "development-vpc"
    Environment = "development"
    Region      = data.aws_region.current.region
    Account     = data.aws_caller_identity.current.account_id
    CreatedBy   = "${data.aws_caller_identity.current.account_id}-${data.aws_region.current.name}"
  }
}

# Create a subnet using AZ information
resource "aws_subnet" "development" {
  vpc_id            = aws_vpc.development.id
  cidr_block        = var.subnet_cidr
  availability_zone = data.aws_availability_zones.available.names[0]

  tags = {
    Name        = "development-subnet"
    Environment = "development"
    AZInfo      = "${data.aws_region.current.name}-${data.aws_availability_zones.available.names[0]}"
  }
}
```

### 4. Add Variable Definitions

Create the variables in `variables.tf`:

```hcl
variable "vpc_cidr" {
  description = "CIDR block for development VPC"
  type        = string
  default     = "172.16.0.0/16"
}

variable "subnet_cidr" {
  description = "CIDR block for development subnet"
  type        = string
  default     = "172.16.1.0/24"
}
```

### 5. Add Provider Configuration

Configure the provider in `providers.tf`:

```hcl
terraform {
  required_version = "1.12.2"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
  
  default_tags {
    tags = {
      Project     = "Terraform Testing"
      Managed_By  = "Terraform"
    }
  }
}
```

### 6. Add Outputs

Create outputs in `outputs.tf`:

```hcl
output "account_id" {
  description = "The AWS Account ID"
  value       = data.aws_caller_identity.current.account_id
  sensitive   = true
}

output "region_name" {
  description = "The current AWS region"
  value       = data.aws_region.current.region
}

output "available_azs" {
  description = "List of available AZs"
  value       = data.aws_availability_zones.available.names
}

output "vpc_id" {
  description = "ID of the development VPC"
  value       = aws_vpc.development.id
}

output "combined_info" {
  description = "Combined region and account information"
  value       = "${data.aws_caller_identity.current.account_id}-${data.aws_region.current.region}"
  sensitive   = true
}
```

### 7. Initialize and Apply Test Configuration

Initialize and apply the test configuration:

```bash
terraform fmt
terraform init
terraform plan
terraform apply
```

Review the proposed changes and type `yes` when prompted to confirm.

### 8. Explore State Commands

With resources created, let's explore a few state commands:

```bash
# List all resources in state
terraform state list

# Show details of the VPC
terraform state show aws_vpc.development

# Show all outputs
terraform output

# Notice that sensitive outputs show as (sensitive)
# To view sensitive outputs, use the output command:
terraform output account_id
terraform output combined_info

# Or use the -json flag with terraform output:
terraform output -json account_id
```

Notice how sensitive outputs are handled differently:
- Using `terraform output -json` allows you to view the actual values
- This helps protect sensitive information from being accidentally displayed in logs or terminal output

### 9. Clean Up All Resources

First, clean up the development environment:

```bash
# In development directory
terraform destroy
```

Then, clean up the main environment:

```bash
# Change to main terraform directory
cd ../terraform
terraform destroy
```

Review and confirm the destruction of resources in both environments.

## Understanding Data Sources

Data sources allow Terraform to query information from your AWS account and use it in your configurations. In this lab, we:
- Queried available Availability Zones
- Retrieved current region information
- Got account identity details
- Combined data source information in resource tags
- Protected sensitive information using the sensitive output flag

## Verification Steps

After creating resources:
1. Verify the VPC and subnet are created with correct tags
2. Check that the AZ information is correctly displayed
3. Confirm all outputs show the expected information, with sensitive values properly masked
4. Verify you can view sensitive values using state commands

After cleanup:
1. Verify all resources are destroyed in both environments
2. Check the AWS Console to confirm no resources remain
3. Ensure all state files are clean

## Success Criteria
Your lab is successful if:
- You can use various Terraform CLI commands
- Data sources successfully query AWS information
- Resources are created with dynamic tags using data source information
- You understand how to work with sensitive outputs
- All resources are properly destroyed
- You understand how to manage multiple configurations

## Additional Exercises
1. Query additional AWS data sources
2. Create more complex combined tags
3. Explore other Terraform CLI commands
4. Practice state commands with different resources
5. Add more sensitive outputs and practice viewing them

## Common Issues and Solutions

If you see errors:
- Verify AWS credentials are still valid
- Ensure you're in the correct directory
- Check that all resources are properly referenced
- Verify region and AZ availability
- Confirm proper syntax for viewing sensitive outputs

## Conclusion
This lab demonstrated how to work with multiple configurations, use data sources, manage sensitive outputs, and properly clean up resources. These skills are essential for managing more complex Terraform deployments and maintaining clean AWS environments.