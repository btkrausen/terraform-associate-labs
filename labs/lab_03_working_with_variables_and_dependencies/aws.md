# LAB-03-AWS: Working with Variables and Outputs

## Overview
In this lab, you will enhance your existing VPC configuration by implementing variables and outputs. You'll learn how variables work, how different variable definitions take precedence, and how to use output values to display resource information. We'll build this incrementally to understand how each change affects our configuration.

[![Lab 03](https://github.com/btkrausen/terraform-testing/actions/workflows/aws_lab_validation.yml/badge.svg?branch=main&event=push&job=lab_03)](https://github.com/btkrausen/terraform-testing/actions/workflows/aws_lab_validation.yml)

**Preview Mode**: Use `Cmd/Ctrl + Shift + V` in VSCode to see a nicely formatted version of this lab!

## Prerequisites
- Terraform installed
- AWS account with appropriate permissions
- Completion of [LAB-02-AWS](https://github.com/btkrausen/terraform-codespaces/blob/main/labs/lab_01_getting_started_with_terraform/aws.md) with existing VPC configuration

## Estimated Time
20 minutes

## Lab Steps

### 1. Review Current Configuration

First, let's review our current main.tf file from the previous lab:

```hcl
resource "aws_vpc" "main" {
  cidr_block           = "192.168.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name        = "terraform-course"
    Environment = "learning-terraform"
    Managed_By  = "Terraform"
  }
}
```

### 2. Add Variable Definitions

Create or update `variables.tf` with the following content:

```hcl
variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
  default     = "192.168.0.0/16"
}

variable "environment" {
  description = "Environment name for tagging"
  type        = string
  default     = "learning-terraform"
}
```

Run a plan to see the current state:
```bash
terraform plan
```

> You should see no changes planned because we haven't implemented the variables yet.

### 3. Update Main Configuration to Use Variables

Now modify `main.tf` to use the new variables:

```hcl
resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr # <-- update value here
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name        = "terraform-course"
    Environment = var.environment     # <-- update value here
    Managed_By  = "Terraform"
  }
}
```

Run a plan to see how these variables affect our configuration:
```bash
terraform plan
```

> You should see no changes planned because our variable values match our current configuration. But at least now some values are set using variables instead of being hardcoded.

### 4. Create terraform.tfvars

Now let's create `terraform.tfvars`:

```bash
touch terraform.tfvars
```
You can also just right-click the terraform directory on the left and select **New file**

Add the following variable values to the `terraform.tfvars` file to override our defaults with new values:
```hcl
vpc_cidr    = "10.0.0.0/16" 
environment = "development"
```

Run another plan:
```bash
terraform plan
```

Now you should see that Terraform plans to destroy and recreate the VPC because:
- The CIDR block will change from 192.168.0.0/16 to 10.0.0.0/16
- The Environment tag will change from "learning-terraform" to "development"

### 5. Update Provider with Default Tags

Update providers.tf to include default tags:

```hcl
terraform {
  required_version = "1.12.2"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
  
  default_tags {
    tags = {
      Managed_By = "Terraform"
      Project    = "Terraform Training"
    }
  }
}
```

Remove the `Managed_By` tag from the VPC resource since we moved it to provider level by updating `main.tf`:

```hcl
resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name        = "terraform-course"
    Environment = var.environment
  }
}
```

Run another plan:
```bash
terraform plan
```

Apply the changes:
```bash
terraform apply
```

Review the proposed changes and type `yes` when prompted to confirm.

> Notice how Terraform applies the default tags as part of the provider for every resource using that provider, but it also adds the tags added to the specific resource as well. This is a great way to easily standardize tags for ALL resources in your environment.

### 6. Add Output Definitions

Create a new file named `outputs.tf` and add the following output blocks:

```hcl
output "vpc_id" {
  description = "ID of the created VPC"
  value       = aws_vpc.main.id
}

output "vpc_arn" {
  description = "ARN of the created VPC"
  value       = aws_vpc.main.arn
}

output "vpc_cidr" {
  description = "CIDR block of the created VPC"
  value       = aws_vpc.main.cidr_block
}
```

Run terraform apply to register the outputs:
```bash
terraform apply
```

You should now see the output values displayed right in the terminal after the apply completes.

```bash
Apply complete! Resources: 0 added, 0 changed, 0 destroyed.

Outputs:

vpc_arn = "arn:aws:ec2:us-east-1:1234567890:vpc/vpc-xxxxxxxxxxx"
vpc_cidr = "10.0.0.0/16"
vpc_id = "vpc-xxxxxxxxxxx"
```

### 7. Experiment with Variable Precedence

Create a new file named `testing.tfvars` and add the following values:
```hcl
vpc_cidr    = "172.16.0.0/16"
environment = "testing"
```

Try applying with this new variable file:
```bash
terraform plan -var-file="testing.tfvars"
```

You'll see that these values would override both the defaults and the values in `terraform.tfvars`. As a result, the VPC will be replaced since the IP address in the `testing.tfvars` is overriding all other values. Don't worry about applying this configuration, but you can now see how to apply specific variable files to a Terraform plan and apply.

### 7. Delete the Testing File

Delete the file `testing.tfvars`.

Run a `terraform plan` to validate that no changes are needed since our real-world infrastructure matches out Terraform configuration.

```bash
➜  terraform git:(main) ✗ terraform plan 
aws_vpc.main: Refreshing state... [id=vpc-xxxxxxxxxxx]

No changes. Your infrastructure matches the configuration.

Terraform has compared your real infrastructure against your configuration and found no differences, so no changes are needed.
```

## Verification Steps

After each step, verify:
1. The plan output matches expectations
2. You understand which variable values take precedence
3. The resource attributes reflect the correct values
4. The tags are properly applied
5. The outputs display the correct information

## Success Criteria
Your lab is successful if you understand:
- How variable definitions work
- How terraform.tfvars overrides default values
- How provider-level default tags are applied
- How to use output values
- The order of variable precedence in Terraform

## Additional Exercises
1. Try using command-line variables: terraform plan -var="environment=production"
2. Create additional output values for other VPC attributes
3. Experiment with changing values in different variable files

## Common Issues and Solutions

If you see unexpected changes:
- Review the variable precedence order
- Check which variable files are being used
- Verify the current state of your VPC

## Next Steps
In the next lab, we will expand our infrastructure by adding multiple resources that depend on each other. Keep your Terraform configuration files intact, as we will continue to expand upon them.