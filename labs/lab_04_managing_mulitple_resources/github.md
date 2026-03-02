# LAB-04-GH: Managing Multiple Resources and Dependencies

## Overview
In this lab, you will expand your GitHub repository configuration by adding multiple interconnected resources. You'll learn how Terraform manages dependencies between resources and how to structure more complex configurations. We'll create repositories, manage repository configures, and implement branch protection rules, demonstrating how different GitHub resources work together.

[![Lab 04](https://github.com/btkrausen/terraform-testing/actions/workflows/github_lab_validation.yml/badge.svg?branch=main)](https://github.com/btkrausen/terraform-testing/actions/workflows/github_lab_validation.yml)

**Preview Mode**: Use `Cmd/Ctrl + Shift + V` in VSCode to see a nicely formatted version of this lab!

## Prerequisites
- Terraform installed
- GitHub account with appropriate permissions
- GitHub organization admin access
- Completion of [LAB-03-GH(https://github.com/btkrausen/terraform-codespaces/blob/main/labs/lab_03_working_with_variables_and_dependencies/github.md)] with existing repository configuration

## Estimated Time
30 minutes

## Lab Steps

**Note**: To fully appreciate this lab and understand how the dependencies work, I recommend typing out the code rather just than copying and pasting.

### 1. Add New Variable Definitions

Add the following to your existing `variables.tf`:

```hcl
# Development Repo Variables
variable "dev_repository_name" {
  description = "Name of the Dev GitHub repository"
  type        = string
  default     = "development-repo"
}

variable "dev_repo_issues" {
  description = "Dev repo issues settings"
  type        = bool
  default     = true
}

variable "dev_discussions" {
  description = "Dev repo discussions settings"
  type        = bool
  default     = true
}

variable "dev_wiki" {
  description = "Dev repo wiki settings"
  type        = bool
  default     = true
}
```

### 2. Configure Team Repository Access

Add new configurations for the new development repository in `main.tf`:

```hcl
# Create development repository
resource "github_repository" "development" {
  name        = var.dev_repository_name
  description = "Primary Dev Repo for new apps"
  visibility  = "public"

  auto_init = true

  has_issues      = var.dev_repo_issues
  has_discussions = var.dev_discussions
  has_wiki        = var.dev_wiki

  allow_merge_commit = true
  allow_squash_merge = true
  allow_rebase_merge = true

  topics = ["terraform", "infrastructure-as-code"]
}
```

### 3. Create Development Configuration Options

Add new configurations for related settings for the development repository in `main.tf`:

```hcl
resource "github_branch_protection" "development" {
  repository_id = github_repository.development.node_id
  pattern       = "main"
}

resource "github_branch" "development" {
  repository = github_repository.development.name
  branch     = "main"
}

resource "github_branch_default" "development" {
  repository = github_repository.development.name
  branch     = github_branch.development.branch
}
```

### 4. Add a Repository File (.gitignore)

Create a CODEOWNERS file in the repository:

```hcl
# Repository Files
resource "github_repository_file" "development" {
  repository          = github_repository.development.name
  branch              = github_branch.development.branch
  file                = ".gitignore"
  content             = "**/*.tfstate"
  commit_message      = "Managed by Terraform"
  commit_author       = "Terraform User"
  commit_email        = "terraform@course.com"
  overwrite_on_create = true
}
```

> Note the explicit dependency on the branch protection rule to ensure the file can be created after the branch is protected.

### 5. Add New Outputs

Add the following output block to your `outputs.tf` file to see information about the newly created repository:

```hcl
output "development_repo" {
  description = "The name of the development repo"
  value       = github_repository.development.name
}
```

### 6. Update terraform.tfvars

Add the team values to your existing `terraform.tfvars`:

```hcl
# Development Repo Configurations
dev_repository_name = "development-repo"
dev_repo_issues     = true
dev_wiki            = true
dev_discussions     = false
```

### 7. Apply the Configuration

Run the following commands:
```bash
terraform fmt
terraform validate
terraform plan
terraform apply
```

Review the proposed changes and type `yes` when prompted to confirm.

## Understanding Resource Dependencies

Notice how Terraform automatically determines the order of resource creation:
1. Teams must be created before repository permissions can be granted
2. The repository must exist before branch protection rules can be applied
3. Branch protection must be in place before the CODEOWNERS file can be added

This is handled through both implicit dependencies (where Terraform determines relationships based on resource references) and explicit dependencies (using depends_on).

## Verification Steps

In the GitHub web interface:
1. Navigate to your repository's settings
2. Verify the teams exist
3. Check the branch protection rules
4. Confirm the `.gitignore` file exists and is properly configured

## Success Criteria
Your lab is successful if:
- All resources are created successfully
- Resource dependencies are properly maintained
- Teams have the correct permissions
- Branch protection rules are properly configured
- The CODEOWNERS file is created and references the correct team

## Additional Exercises
1. Add more team members to the teams
2. Create additional branch protection rules for other branches
3. Add more repository files using Terraform
4. Modify team permissions and observe the changes

## Common Issues and Solutions

If you see errors:
- Verify GitHub organization permissions
- Ensure team names are unique within your organization
- Check that branch names match exactly
- Verify your GitHub token has sufficient permissions

## Next Steps
In the next lab, we will learn about state management. Keep your Terraform configuration files intact, as we will continue to expand upon them.