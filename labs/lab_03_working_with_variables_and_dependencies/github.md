# LAB-03-GH: Working with Variables and Outputs

## Overview
In this lab, you will enhance your existing GitHub repository configuration by implementing variables and outputs. You'll learn how variables work, how different variable definitions take precedence, and how to use output values to display resource information. We'll build this incrementally to understand how each change affects our configuration.

[![Lab 03](https://github.com/btkrausen/terraform-testing/actions/workflows/github_lab_validation.yml/badge.svg?branch=main)](https://github.com/btkrausen/terraform-testing/actions/workflows/github_lab_validation.yml)

**Preview Mode**: Use `Cmd/Ctrl + Shift + V` in VSCode to see a nicely formatted version of this lab!

## Prerequisites
- Terraform installed
- GitHub account with appropriate permissions
- Completion of [LAB-02-GH](https://github.com/btkrausen/terraform-codespaces/blob/main/labs/lab_02_create_your_first_resource/github.md) with existing repository configuration

## Estimated Time
20 minutes

## Lab Steps

### 1. Review Current Configuration

First, let's review our current `main.tf` file from the previous lab:

```hcl
# Create the repository
resource "github_repository" "example" {
  name        = "terraform-example"
  description = "Updated repository description"
  visibility  = "public"

  auto_init = true

  has_issues      = true
  has_discussions = true
  has_wiki        = false

  allow_merge_commit = true
  allow_squash_merge = true
  allow_rebase_merge = true

  topics = ["terraform", "infrastructure-as-code", "learning"]
}

# Create branch protection rule
resource "github_branch_protection" "main" {
  repository_id = github_repository.example.node_id
  pattern       = "main"

  required_pull_request_reviews {
    required_approving_review_count = 2
  }
}
```

### 2. Add Variable Definitions

Add the following variable definitions to the `variables.tf` file:

```hcl
variable "repository_name" {
  description = "Name of the GitHub repository"
  type        = string
  default     = "terraform-example"
}

variable "repository_visibility" {
  description = "Visibility of the repository"
  type        = string
  default     = "public"
}

variable "environment" {
  description = "Environment tag for the repository"
  type        = string
  default     = "learning-terraform"
}

variable "repository_features" {
  description = "Enabled features for the repository"
  type        = object({
    has_issues      = bool
    has_discussions = bool
    has_wiki        = bool
  })
  default = {
    has_issues      = true
    has_discussions = true
    has_wiki        = false
  }
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
resource "github_repository" "main" {
  name        = var.repository_name # <-- update value here
  description = "Repository managed by Terraform"
  visibility  = var.repository_visibility # <-- update value here

  auto_init = true

  has_issues      = var.repository_features.has_issues # <-- update value here
  has_discussions = var.repository_features.has_discussions # <-- update value here
  has_wiki        = var.repository_features.has_wiki # <-- update value here

  allow_merge_commit = true
  allow_squash_merge = true
  allow_rebase_merge = true

  topics = [
    "terraform",
    var.environment,
    "infrastructure-as-code"
  ]
}
```

Run a plan to see how these variables affect our configuration:
```bash
terraform plan
```

> You should see no changes planned because our variable values match our current configuration. We just simply moved them from hardcoded values to being declared in our variable definition.

### 4. Create terraform.tfvars

Now let's create `terraform.tfvars`:

```bash
touch terraform.tfvars
```
You can also just right-click the terraform directory on the left and select **New file**

Add the following variable values to the `terraform.tfvars` file to override our defaults with new values:
```hcl
repository_name     = "terraform-development"
repository_visibility = "public"
environment        = "development"
repository_features = {
  has_issues      = true
  has_discussions = false
  has_wiki        = false
}
```

Run another plan:
```bash
terraform plan
```

Now you should see that Terraform plans to destroy and recreate the repository because:
- The repository name will change
- The environment tag will change
- Some features will be disabled

Apply the changes:
```bash
terraform apply -auto-approve
```

### 5. Add Output Definitions

Create a new file named `outputs.tf` and add the following output blocks:

```hcl
output "repository_id" {
  description = "ID of the created repository"
  value       = github_repository.example.repo_id
}

output "repository_html_url" {
  description = "URL of the created repository"
  value       = github_repository.example.html_url
}

output "repository_git_clone_url" {
  description = "Git clone URL of the repository"
  value       = github_repository.example.git_clone_url
}

output "repository_visibility" {
  description = "Visibility of the repository"
  value       = github_repository.example.visibility
}
```

Run `terraform apply` to register the outputs:
```bash
terraform apply
```

You should now see the output values displayed after the apply completes.

### 6. Experiment with Variable Precedence

Create a new file named `testing.tfvars`:
```hcl
repository_name       = "terraform-testing"
repository_visibility = "private"
environment           = "testing"
repository_features = {
  has_issues      = false
  has_discussions = false
  has_wiki        = false
}
```

Try running a plan with this new variable file to see how to specify a specific variables file:
```bash
terraform plan -var-file="testing.tfvars"
```

You'll see that these values would override both the defaults and the values in `terraform.tfvars`.

### 7. Delete the Testing File

Delete the file `testing.tfvars`.

Run a `terraform plan` to validate that no changes are needed since our real-world infrastructure matches our Terraform configuration.

## Verification Steps

After each step, verify:
1. The plan output matches expectations
2. You understand which variable values take precedence
3. The resource attributes reflect the correct values
4. The repository features are properly configured
5. The outputs display the correct information

## Success Criteria
Your lab is successful if you understand:
- How variable definitions work
- How terraform.tfvars overrides default values
- How to use different variable types (strings, objects)
- How to use output values
- The order of variable precedence in Terraform

## Additional Exercises
1. Try using command-line variables: terraform plan -var="environment=production"
2. Create additional output values for other repository attributes
3. Experiment with changing values in different variable files

## Common Issues and Solutions

If you see unexpected changes:
- Review the variable precedence order
- Check which variable files are being used
- Verify the current state of your repository
- Ensure you have appropriate GitHub permissions

## Next Steps
In the next lab, we will expand our infrastructure by adding multiple resources that depend on each other. Keep your Terraform configuration files intact, as we will continue to expand upon them.