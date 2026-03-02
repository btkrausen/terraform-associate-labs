# LAB-05-GH: State Management, Data Sources, and Advanced CLI

## Overview
In this lab, you will learn how to work with Terraform state, use data sources to query GitHub information, and explore additional Terraform CLI commands. You'll create a production environment configuration, learn how to inspect and manage state, and properly clean up all resources.

[![Lab 05](https://github.com/btkrausen/terraform-testing/actions/workflows/github_lab_validation.yml/badge.svg?branch=main)](https://github.com/btkrausen/terraform-testing/actions/workflows/github_lab_validation.yml)

**Preview Mode**: Use `Cmd/Ctrl + Shift + V` in VSCode to see a nicely formatted version of this lab!

## Prerequisites
- Terraform installed
- GitHub account with appropriate permissions
- Completion of [LAB-04-GH](https://github.com/btkrausen/terraform-codespaces/blob/main/labs/lab_04_managing_mulitple_resources/github.md) with existing repository configuration

## Estimated Time
30 minutes

## Lab Steps

### 1. Understanding Terraform State

Examine your current state with the following commands:

```bash
terraform state list
terraform state show github_repository.example
```

This displays all resources in your state and details about a specific resource.

### 2. Create Data Sources for GitHub Information

Add the top of `main.tf` with the following content:

```hcl
# Get information about the current GitHub user
data "github_user" "current" {
  username = ""
}

# Get information about the example repository
data "github_repository" "existing_example" {
  full_name  = "terraform_user/${github_repository.example.name}"
  depends_on = [github_repository.example]
}
```

### 3. Add Production Repository Variables

Add the following to your `variables.tf` file:

```hcl
# Production Repository Variables
variable "prod_repository_name" {
  description = "Name of the Production GitHub repository"
  type        = string
  default     = "production-repo"
}

variable "prod_branch_protection" {
  description = "Number of required approvals for production branch"
  type        = number
  default     = 2
}
```

### 4. Update terraform.tfvars

Add the production values to your existing `terraform.tfvars`:

```hcl
# Production Repo Configurations
prod_repository_name   = "production-repo"
prod_branch_protection = 3
```

### 5. Create Production Repository Resources

Add the following to your `main.tf` file:

```hcl
# Create production repository
resource "github_repository" "production" {
  name        = var.prod_repository_name
  description = "Production repository managed by Terraform"
  visibility  = "public"
  
  auto_init = true
  
  has_issues      = true
  has_discussions = false
  has_wiki        = false
  
  vulnerability_alerts = true
  
  topics = ["terraform", "production"]
}

# Create stricter branch protection for production
resource "github_branch_protection" "production" {
  repository_id = github_repository.production.node_id
  pattern       = "main"
  
  enforce_admins = true
  
  required_pull_request_reviews {
    required_approving_review_count = var.prod_branch_protection
    dismiss_stale_reviews           = true
    require_code_owner_reviews      = true
  }
  
  require_signed_commits = true
}

# Create a production environment
resource "github_repository_environment" "production" {
  repository  = github_repository.production.name
  environment = "production"
  
  reviewers {
    users = [data.github_user.current.id]
  }
  
  deployment_branch_policy {
    protected_branches     = true
    custom_branch_policies = false
  }
}
```

### 6. Add Repository Files Using Data Sources

Add the following to `main.tf`:

```hcl
# Create a README file that references all repositories
resource "github_repository_file" "production_readme" {
  repository          = github_repository.production.name
  branch              = "main"
  file                = "README.md"
  content             = <<-EOT
    # Production Repository
    
    This repository is managed by Terraform.
    
    ## Related Repositories
    
    - Development: [${github_repository.development.name}](${github_repository.development.html_url})
    - Example: [${github_repository.example.name}](${github_repository.example.html_url})
  EOT
  commit_message      = "Add README via Terraform"
  commit_author       = "Terraform User"
  commit_email        = "terraform@course.com"
  overwrite_on_create = true
}
```

### 7. Add Outputs for Data Sources

Add the following to your `outputs.tf` file:

```hcl
# Data source outputs
output "current_user" {
  description = "Current GitHub user name"
  value       = data.github_user.current.name
}

# Production repository outputs
output "production_repo_url" {
  description = "URL of the production repository"
  value       = github_repository.production.html_url
}

output "production_environment" {
  description = "Production environment name"
  value       = github_repository_environment.production.environment
}
```

### 8. Apply the Configuration and Explore State

Run the following commands:

```bash
terraform fmt
terraform validate
terraform plan
terraform apply
```

### 9. Advanced State Commands

Try these state management commands:

```bash
# List all resources in the state
terraform state list

# Show details of a specific resource
terraform state show github_repository.production

# Create a state backup
terraform state pull > terraform.tfstate.backup

# Perform a targeted apply
terraform apply -target=github_repository_file.production_readme
```

### 10. Clean Up Resources

To remove specific resources:

```bash
# Only destroy the repository file
terraform destroy -target=github_repository_file.production_readme
```

For complete cleanup after completing Labs 1-5:

```bash
terraform destroy
```

## Verification Steps

In the GitHub web interface:
1. Verify the production repository was created
2. Check the README file contains references to other repositories
3. Examine the production environment settings

## Success Criteria
Your lab is successful if:
- All resources are created successfully
- Data sources correctly retrieve GitHub information
- Production environment is properly configured
- State commands work as expected

## Additional Exercises
1. Import an existing repository using `terraform import`
2. Create a workspace for different environments
3. Use the `terraform output` command to extract specific values

## Common Issues and Solutions

- Ensure your GitHub token has sufficient permissions
- Check if referenced resources exist before using them in data sources
- If hitting API rate limits, space out your commands

## Next Steps
In the next part of your Terraform journey, consider exploring remote state backends, modules, and integrating Terraform with CI/CD pipelines.