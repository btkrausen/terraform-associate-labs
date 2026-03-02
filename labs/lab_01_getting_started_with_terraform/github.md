# LAB-01-GH: Getting Started with Terraform Configuration with GitHub

## Overview
In this lab, you will create your first Terraform configuration for GitHub by setting up the required file structure and implementing the GitHub provider configuration. You'll learn how to format, validate, and initialize a Terraform working directory.

[![Lab 01](https://github.com/btkrausen/terraform-testing/actions/workflows/github_lab_validation.yml/badge.svg?branch=main)](https://github.com/btkrausen/terraform-testing/actions/workflows/github_lab_validation.yml)

**Preview Mode**: Use `Cmd/Ctrl + Shift + V` in VSCode to see a nicely formatted version of this lab!

## Prerequisites
- Terraform installed
- VS Code or preferred code editor installed

Note: GitHub credentials are not required for this lab as we will only be configuring the provider without creating any resources.

## How to Use This Hands-On Lab

1. **Create a Codespace** from this repo (click the button below).  
2. Once the Codespace is running, open the integrated terminal.
3. Follow the instructions in each **lab** to complete the exercises.

[![Open in GitHub Codespaces](https://github.com/codespaces/badge.svg)](https://codespaces.new/btkrausen/terraform-codespaces)

## Estimated Time
15 minutes

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
```bash
labs/
└── terraform/
    ├── main.tf
    ├── providers.tf
    └── variables.tf
```

This directory will be your working environment for the upcoming labs as we build our infrastructure incrementally.

### 3. Configure the GitHub Provider

Open `providers.tf` and add the following configuration:

```hcl
terraform {
  required_version = "1.12.2"  # Replace with your installed version
  required_providers {
    github = {
      source  = "integrations/github"
      version = "~> 6.5.0"
    }
  }
}

provider "github" {}
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

Expected Output:
```bash
# terraform init
Initializing the backend...
Initializing provider plugins...
- Finding integrations/github versions matching "~> 6.5.0"...
- Installing integrations/github v6.5.0...
- Installed integrations/github v6.5.0 (signed by a HashiCorp partner, key ID 38027F80D7FD5FB2)
Partner and community providers are signed by their developers.
If you'd like to know more about provider signing, you can read about it here:
https://www.terraform.io/docs/cli/plugins/signing.html
Terraform has created a lock file .terraform.lock.hcl to record the provider
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
required_version = ">= 99.0.0"  # An intentionally high version
```

2. Run the terraform initialization command:

```bash
terraform init
```

You should see an error message similar to:
```
Error: Unsupported Terraform Core version

This configuration requires Terraform version >= 99.0.0, but the current version
is x.x.x. Please upgrade Terraform to a supported version.
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
```
labs/
└── terraform/
    ├── main.tf
    ├── providers.tf
    ├── variables.tf
    ├── .terraform.lock.hcl
    └── .terraform/
```

2. Verify the following:
   - The `.terraform` directory exists after initialization
   - The `.terraform.lock.hcl` file has been created
   - GitHub provider is listed in the lock file
   - No error messages are present from the validate command
   - All files are properly formatted

## Clean Up

No clean up is required for this lab as no GitHub resources were created. 

## Success Criteria
- You have created the required file structure
- All Terraform commands (fmt, validate, init) execute successfully
- You observed and understood the version constraint error
- You successfully fixed the version constraint
- The GitHub provider is properly initialized
- The `.terraform.lock.hcl` file is created