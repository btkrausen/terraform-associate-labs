# LAB-06-GH: Refactoring Terraform Configurations: Making Code Dynamic and Reusable

## Overview
In this lab, you will examine an existing Terraform configuration with hardcoded values and refactor it to be more dynamic and reusable. You'll implement variables, data sources, and string interpolation to create a more flexible infrastructure definition. The lab uses GitHub free-tier features to ensure no costs are incurred.

[![Lab 06](https://github.com/btkrausen/terraform-testing/actions/workflows/github_lab_validation.yml/badge.svg?branch=main)](https://github.com/btkrausen/terraform-testing/actions/workflows/github_lab_validation.yml)

**Preview Mode**: Use `Cmd/Ctrl + Shift + V` in VSCode to see a nicely formatted version of this lab!

## Prerequisites
- Terraform installed
- GitHub account
- GitHub Personal Access Token (PAT) with appropriate permissions
- Basic understanding of Terraform and GitHub concepts

Note: GitHub credentials are required for this lab.

## How to Use This Hands-On Lab

1. **Create a Codespace** from this repo (click the button below).  
2. Once the Codespace is running, open the integrated terminal.
3. Follow the instructions in each **lab** to complete the exercises.

[![Open in GitHub Codespaces](https://github.com/codespaces/badge.svg)](https://codespaces.new/btkrausen/terraform-codespaces)

## Estimated Time
45 minutes

## Existing Configuration Files

The lab directory contains the following files with hardcoded values that we'll refactor:

 - `main.tf`
 - `providers.tf`

Examine these files and notice:
- Hardcoded repository name and settings
- Static team name and permissions
- Manual environment naming in topics
- Fixed repository features
- Static team access configuration

## Lab Steps

### 1. Configure GitHub Credentials

Set up your GitHub Personal Access Token:

```bash
export GITHUB_TOKEN="your_personal_access_token"
```

### 2. Create Variables File

Add the following variable declarations to the `variables.tf` file to define variables that will replace hardcoded values:

```hcl
variable "environment" {
  description = "Environment name for resource naming"
  type        = string
  default     = "production"
}

variable "app_name" {
  description = "Application name for repository"
  type        = string
  default     = "application"
}

variable "team_name" {
  description = "Base name for the team"
  type        = string
  default     = "developers"
}

variable "repository_features" {
  description = "Enabled features for repository"
  type        = object({
    has_issues      = bool
    has_wiki        = bool
    has_discussions = bool
  })
  default = {
    has_issues      = true
    has_wiki        = true
    has_discussions = true
  }
}
```

### 3. Add Data Sources

Update `main.tf` to include data sources at the top of the file:

```hcl
# Get information about the current user
data "github_user" "current" {
  username = ""
}
```

### 4. Refactor Resources

Replace the existing resources in `main.tf` with this dynamic configuration:

```hcl
resource "github_repository" "production" {
  name        = "${var.environment}-${var.app_name}"     # <-- update value here
  description = "${title(var.environment)} environment repository managed by ${data.github_user.current.login}" # <-- update value here
  visibility  = "public"

  has_issues      = var.repository_features.has_issues        # <-- update value here
  has_wiki        = var.repository_features.has_wiki          # <-- update value here
  has_discussions = var.repository_features.has_discussions   # <-- update value here

  allow_merge_commit = true
  allow_rebase_merge = true
  allow_squash_merge = true

  topics = [
    var.environment,     # <-- update value here
    var.app_name,        # <-- update value here
    "terraform-managed",
  ]
}
```

### 5. Create Outputs File

Create `outputs.tf` to display resource information:

```hcl
output "repository_url" {
  description = "URL of the created repository"
  value       = github_repository.production.html_url
}

output "creator_info" {
  description = "Information about who created the resources"
  value       = data.github_user.current.login
}
```

### 6. Create Environment Configuration

Create `terraform.tfvars` to define environment-specific values:

```hcl
environment = "development"
app_name    = "terraform-demo"
repository_features = {
  has_issues      = true
  has_wiki        = false
  has_discussions = true
}
```

### 7. Apply and Verify

Initialize and apply the configuration:

```bash
terraform init
terraform plan
terraform apply
```

### 8. Test Configuration Flexibility

Create a file called `staging.tfvars`:

```hcl
environment = "staging"
app_name    = "terraform-demo"
repository_features = {
  has_issues      = true
  has_wiki        = true
  has_discussions = false
}
```

Apply the new configuration:
```bash
terraform plan -var-file="staging.tfvars"
terraform apply -var-file="staging.tfvars"
```

Notice how:
- A new repository is created with a different name
- Team names reflect the new environment
- Different repository features are enabled/disabled
- Topics are automatically updated

## Understanding the Changes

Let's examine how the refactoring improves the configuration:

1. Variable Usage:
   - Repository names are now configurable
   - Team names can be changed
   - Features can be toggled per environment
   - Resources follow consistent naming patterns

2. Data Sources:
   - User information is dynamically included
   - Organization details are automatically added
   - Resource descriptions include creator information

3. String Interpolation:
   - Resource names combine multiple variables
   - Descriptions are dynamically generated
   - Topics include organization information

## Verification Steps

1. Check the GitHub web interface to verify:
   - Repositories are created with dynamic names
   - Teams have correct permissions
   - Features are properly configured
   - Topics are correctly set

2. Test the variable system:
   - Modify values in terraform.tfvars
   - Observe how changes affect the resources

## Clean Up

Remove all created resources:

```bash
terraform destroy
```

## Additional Exercises
1. Create additional variable files for different environments
2. Add more repository features as variables
3. Implement conditional team creation
4. Add variable validation rules

## Common Issues and Solutions

If you encounter errors:
- Verify GitHub token permissions
- Ensure organization name is correct
- Check that repository names are unique
- Verify team names don't conflict with existing teams