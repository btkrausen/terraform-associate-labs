# LAB-01-AWS: Getting Started with Terraform Configuration with AWS

## Overview
In this lab, you will create your first Terraform configuration for AWS by setting up the required file structure and implementing the AWS provider configuration. You'll learn how to format, validate, and initialize a Terraform working directory.

[![Lab 01](https://github.com/btkrausen/terraform-testing/actions/workflows/aws_lab_validation.yml/badge.svg?branch=main&event=push&job=lab_01)](https://github.com/btkrausen/terraform-testing/actions/workflows/aws_lab_validation.yml)

**Preview Mode**: Use `Cmd/Ctrl + Shift + V` in VSCode to see a nicely formatted version of this lab!

## Prerequisites
- Terraform installed
- VS Code or preferred code editor installed

Note: AWS credentials are not required for this lab as we will only be configuring the provider without creating any resources.

## How to Use This Hands-On Lab

1. **Create a Codespace** from this repo (click the button below).  
2. Once the Codespace is running, open the integrated terminal.
3. Follow the instructions in each **lab** to complete the exercises.

[![Open in GitHub Codespaces](https://github.com/codespaces/badge.svg)](https://codespaces.new/btkrausen/terraform-codespaces)

## Estimated Time
15 minutes

## Testing
![testing](https://img.shields.io/badge/Passing-Terraform_1.12.2-purple)

## Lab Steps

### 1. Check Terraform Version

Determine your installed Terraform version:

```bash
terraform version
```

Note this version number as you'll need it for the provider configuration.

### 2. Create the Project Structure

Create a labs directory and a terraform directory within it that will serve as your workspace for these initial labs:

```bash
mkdir -p labs/terraform
cd labs/terraform
```

Create the initial configuration files in this directory:

```bash
touch main.tf variables.tf providers.tf
```
You can also just create these in VSCode by right-clicking the directory.

Your directory structure should look like this:
```
labs/
└── terraform/
    ├── main.tf
    ├── providers.tf
    └── variables.tf
```

This directory will be your working environment for the upcoming labs as we build our infrastructure incrementally.


### 3. Configure the AWS Provider

Open `providers.tf` and add the following configuration:

```hcl
terraform {
  required_version = "1.12.2"  # Replace with your installed version
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}
```

### 4. Format the Configuration

Run the following command to ensure consistent formatting:

```bash
terraform fmt
```

Expected output: If any files were formatted, their names will be listed. If no formatting was needed, there will be no output.

### 5. Initialize the Working Directory
 Initialize the working directory to prep the environment and download the provider:

 ```bash
 terraform init
 ```

Expected output:
```bash
Initializing the backend...
Initializing provider plugins...
- Finding hashicorp/aws versions matching "~> 5.0"...
- Installing hashicorp/aws v5.87.0...
- Installed hashicorp/aws v5.87.0 (signed by HashiCorp)
Terraform has created a lock file .terraform.lock.hcl to record the provider
selections it made above. Include this file in your version control repository
so that Terraform can guarantee to make the same selections by default when
you run "terraform init" in the future.


Terraform has been successfully initialized!
```

### 6. Validate the Configuration

Run the validation command to check for syntax errors:

```bash
terraform validate
```

Expected output:
```
Success! The configuration is valid.
```

### 7. Test Version Constraints

Let's experiment with version constraints:

1. Modify the `required_version` in your provider configuration:

```hcl
required_version = "1.12.2"  # An intentionally high version
```

2. Run the terraform initialization command:

```bash
terraform init
```

You should see an error message similar to:
```
Initializing the backend...
╷
│ Error: Unsupported Terraform Core version
│ 
│   on providers.tf line 2, in terraform:
│    2:   required_version = ">= 99.0.0" # Replace with your installed version
```

3. Change the version requirement back to your current version:

```hcl
required_version = "1.12.2"  # Replace with your actual version
```

4. Run terraform init again:

```bash
terraform init
```

Expected output: You should now see success messages indicating proper initialization.

## Verification Steps

After completing the lab, verify your work:

1. Your directory structure should look like this:
```bash
labs/
└── terraform/
    ├── .terraform/
    ├── .terraform.lock.hcl
    ├── main.tf
    ├── providers.tf
    └── variables.tf
```

2. Verify the following:
   - The `.terraform` directory exists after initialization
   - The `.terraform.lock.hcl` file has been created
   - AWS provider is listed in the lock file
   - No error messages are present from the validate command
   - All files are properly formatted

## Clean Up

No clean up is required for this lab as no AWS resources were created. 

## Success Criteria
- You have created the required file structure
- All Terraform commands (fmt, validate, init) execute successfully
- You observed and understood the version constraint error
- You successfully fixed the version constraint
- The AWS provider is properly initialized
- The `.terraform.lock.hcl` file is created