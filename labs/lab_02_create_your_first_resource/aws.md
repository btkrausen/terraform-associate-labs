# LAB-02-AWS: Creating Your First AWS Resource

## Overview
In this lab, you will create your first AWS resource using Terraform: a Virtual Private Cloud (VPC). We will build upon the configuration files created in LAB-01, adding resource configuration and implementing the full Terraform workflow. The lab introduces environment variables for AWS credentials, resource blocks, and the essential Terraform commands for resource management.

[![Lab 02](https://github.com/btkrausen/terraform-testing/actions/workflows/aws_lab_validation.yml/badge.svg?branch=main&event=push&job=lab_02)](https://github.com/btkrausen/terraform-testing/actions/workflows/aws_lab_validation.yml)

**Preview Mode**: Use `Cmd/Ctrl + Shift + V` in VSCode to see a nicely formatted version of this lab!

## Prerequisites
- Terraform installed
- AWS CLI installed
- AWS account with appropriate permissions
- Completion of [LAB-01-AWS](https://github.com/btkrausen/terraform-codespaces/blob/main/labs/lab_01_getting_started_with_terraform/aws.md)

## Estimated Time
20 minutes

## Lab Steps

### 1. Navigate to Your Configuration Directory

Ensure you're in the terraform directory created in LAB-01:

```bash
pwd
/workspaces/terraform-codespaces/labs/terraform
```
If you're in a different directory, change to the Terraform working directory:
```bash
cd labs/terraform
```

### 2. Configure AWS Credentials

Set your AWS credentials as environment variables:

```bash
export AWS_ACCESS_KEY_ID="your_access_key"
export AWS_SECRET_ACCESS_KEY="your_secret_key"
```

### 3. Add VPC Resource Configuration

Open `main.tf` and add the following VPC configuration (purposely not written in HCL canonical style):

```hcl
# Create the primary VPC for workloads
resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support = true

  tags = {
    Name = "terraform-course"
    Environment = "Lab"
    Managed_By = "Terraform"
  }
  }
```

### 4. Format and Validate

Format your configuration to rewrite it to follow HCL style:
```bash
terraform fmt
```

Validate the syntax:
```bash
terraform validate
```

### 5. Review the Plan

Generate and review the execution plan:
```bash
terraform plan
```

The plan output will show that Terraform intends to create a new VPC with:
- CIDR block of 10.0.0.0/16
- DNS features enabled
- Three tags: Name, Environment, and Managed_By

### 6. Apply the Configuration

Apply the configuration to create the VPC:
```bash
terraform apply
```

Review the proposed changes and type `yes` when prompted to confirm.

### 7. Verify the Resource

Verify the VPC creation using the AWS CLI:
```bash
aws ec2 describe-vpcs --filters "Name=tag:Name,Values=terraform-course" --region=us-east-1 # Update your region, if different
```

### 8. Update the VPC Resource

In the `main.tf` file, and update the  VPC configuration:

```hcl
# Create the primary VPC for workloads
resource "aws_vpc" "main" {
  cidr_block           = "192.168.0.0/16" # <-- change IP Address
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "terraform-course"
    Environment = "Lab"
    Managed_By = "Terraform"
  }
}
```

### 9. Run a Terraform Plan to Perform a Dry Run

Generate and review the execution plan:
```bash
terraform plan
```

Since the IP address of a VPC cannot be changed, the plan output will show that Terraform intends to replace the VPC:
- the VPC with a CIDR block of `10.0.0.0/16` will be destroyed
- a VPC with a CIDR block of `192.168.0.0/16` will be created

Expected Output:

```bash
aws_vpc.main: Refreshing state... [id=vpc-xxxxx]

Terraform used the selected providers to generate the following execution plan. Resource actions are indicated with the following symbols:
-/+ destroy and then create replacement

Terraform will perform the following actions:

  # aws_vpc.main must be replaced
  ```

### 10. Apply the Configuration

Apply the configuration to create the VPC:
```bash
terraform apply
```

Review the proposed changes and type `yes` when prompted to confirm.

### 11. Update the Tags on the VPC

In the `main.tf` file, and update the VPC configuration:

```hcl
# Create the primary VPC for workloads
resource "aws_vpc" "main" {
  cidr_block           = "192.168.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "terraform-course"
    Environment = "learning-terraform"  # <-- change tag here
    Managed_By = "Terraform"
  }
}
```

### 12. Run a Terraform Plan to Perform a Dry Run

Generate and review the execution plan:
```bash
terraform plan
```

Since the tags of a VPC can be changed, the plan output will show that Terraform will make an update in-place:
- the tags of the VPC will be updated

Expected Output:

```
aws_vpc.main: Refreshing state... [id=vpc-xxxxxx]

Terraform used the selected providers to generate the following execution plan. Resource actions are indicated with the following symbols:
  ~ update in-place

Terraform will perform the following actions:

  # aws_vpc.main will be updated in-place
  ```

### 13. Apply the Configuration


Apply the configuration to create the VPC:
```bash
terraform apply
```

Review the proposed changes and type `yes` when prompted to confirm.

## Verification Steps

Confirm that:
1. The VPC exists in your AWS account with:
   - CIDR block: `192.168.0.0/16`
   - DNS hostnames enabled
   - DNS support enabled
   - All specified tags present
2. A terraform.tfstate file exists in your directory
3. All Terraform commands completed successfully

## Success Criteria
Your lab is successful if:
- AWS credentials are properly configured using environment variables
- The VPC is successfully created with all specified configurations
- All Terraform commands execute without errors
- The terraform.tfstate file accurately reflects your infrastructure
- The resource is successfully destroyed during cleanup

## Additional Exercises
1. Try changing the VPC tags and observe how Terraform handles the modification
2. Experiment with different CIDR blocks (ensuring they are valid)
3. Review the terraform.tfstate file to understand how Terraform tracks resource state

## Common Issues and Solutions

If you encounter credential errors:
- Double-check your environment variable values
- Ensure there are no extra spaces or special characters
- Verify your AWS user has appropriate permissions

If you see CIDR block conflicts:
- Ensure your chosen CIDR block doesn't overlap with existing VPCs
- Verify the CIDR block follows proper formatting (e.g., 10.0.0.0/16)

## Next Steps
In the next lab, we will build upon this VPC by adding additional networking components. Keep your Terraform configuration files intact, as we will continue to expand upon them.