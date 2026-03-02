# LAB-05-AZ: Working with State, Data Sources, and CLI Commands

## Overview
In this lab, you will learn how to work with Terraform state, use data sources to query Azure information, and explore additional Terraform CLI commands. You'll create a development environment configuration, learn how to inspect and manage state, and properly clean up all resources. The lab introduces the concept of using data sources to make your configurations more dynamic and environment-aware.

[![Lab 05](https://github.com/btkrausen/terraform-testing/actions/workflows/azure_lab_validation.yml/badge.svg?branch=main)](https://github.com/btkrausen/terraform-testing/actions/workflows/azure_lab_validation.yml)

**Preview Mode**: Use `Cmd/Ctrl + Shift + V` in VSCode to see a nicely formatted version of this lab!

## Prerequisites
- Terraform installed
- Azure account with appropriate permissions
- Completion of [LAB-04-AZ](https://github.com/btkrausen/terraform-codespaces/blob/main/labs/lab_04_managing_mulitple_resources/azure.md) with existing Virtual Network configuration

## Estimated Time
35 minutes

## Lab Steps

### 1. Explore Terraform CLI Commands

Let's start by exploring some useful Terraform CLI commands:

```bash
# View all available Terraform commands
terraform --help

# Get specific help about state commands
terraform state --help

# Show current state resources
terraform state list

# Show details about a specific resource
terraform state show azurerm_virtual_network.main
```

### 2. Create a Development Environment Directory

Create a new directory for a development environment configuration:

```bash
# Create development directory at the same level as your terraform directory
cd ..
mkdir development
cd development

# Create configuration files
touch main.tf variables.tf providers.tf outputs.tf
```

### 3. Add Data Source Configurations

In the new `development` environment's `main.tf`, add the following configuration to query Azure information:

```hcl
# Get information about available locations
data "azurerm_subscription" "current" {}

data "azurerm_client_config" "current" {}

# Get location information
data "azurerm_location" "current" {
  location = "eastus"
}

# Create Resource Group using data source information
resource "azurerm_resource_group" "development" {
  name     = "development-resources"
  location = data.azurerm_location.current.display_name

  tags = {
    Environment = "development"
    Subscription = data.azurerm_subscription.current.display_name
    CreatedBy    = data.azurerm_client_config.current.object_id
  }
}

# Create Virtual Network using data source information
resource "azurerm_virtual_network" "development" {
  name                = "development-network"
  resource_group_name = azurerm_resource_group.development.name
  location            = azurerm_resource_group.development.location
  address_space       = [var.vnet_cidr]

  tags = {
    Environment  = "development"
    Location     = data.azurerm_location.current.display_name
    CreatedBy    = "${data.azurerm_subscription.current.subscription_id}-${data.azurerm_location.current.display_name}"
  }
}
```

### 4. Add Variable Definitions

Create the variables in `variables.tf`:

```hcl
variable "vnet_cidr" {
  description = "CIDR block for development VNet"
  type        = string
  default     = "172.16.0.0/16"
}
```

### 5. Add Provider Configuration

Configure the provider in `providers.tf`:

```hcl
terraform {
  required_version = "1.12.2"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }
}

provider "azurerm" {
  features {}
}
```

### 6. Add Outputs

Create outputs in `outputs.tf`:

```hcl
output "subscription_id" {
  description = "The Azure Subscription ID"
  value       = data.azurerm_subscription.current.subscription_id
  sensitive   = true
}

output "tenant_id" {
  description = "The Azure Tenant ID"
  value       = data.azurerm_client_config.current.tenant_id
  sensitive   = true
}

output "location_info" {
  description = "Information about the current location"
  value       = data.azurerm_location.current.display_name
}

output "resource_group_id" {
  description = "ID of the development resource group"
  value       = azurerm_resource_group.development.id
}
```

### 7. Initialize and Apply Test Configuration

Initialize and apply the test configuration:

```bash
terraform init
terraform plan
terraform apply
```

### 8. Explore State Commands

With resources created, explore state commands:

```bash
# List all resources in state
terraform state list

# Show details of the Virtual Network
terraform state show azurerm_virtual_network.development

# Show all outputs
terraform output

# Notice that sensitive outputs show as (sensitive)
# To view sensitive outputs, use the state show command:
terraform output subscription_id
terraform output tenant_id
```

Notice how sensitive outputs are handled differently:
- Regular `terraform output` will show "(sensitive)" for these values
- Using `terraform output <output-name>` allows you to view the actual values
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
cd ..
terraform destroy
```

Review and confirm the destruction of resources in both environments.

## Understanding Data Sources

Data sources allow Terraform to query information from your Azure subscription and use it in your configurations. In this lab, we:
- Retrieved subscription information
- Got current client configuration details
- Queried location information
- Combined data source information in resource tags
- Protected sensitive information using the sensitive output flag

## Verification Steps

After creating resources:
1. Verify the Resource Group and Virtual Network are created with correct tags
2. Check that the location information is correctly displayed
3. Confirm all outputs show the expected information, with sensitive values properly masked
4. Verify you can view sensitive values using state commands

After cleanup:
1. Verify all resources are destroyed in both environments
2. Check the Azure Portal to confirm no resources remain
3. Ensure all state files are clean

## Success Criteria
Your lab is successful if:
- You can use various Terraform CLI commands
- Data sources successfully query Azure information
- Resources are created with dynamic tags using data source information
- You understand how to work with sensitive outputs
- All resources are properly destroyed
- You understand how to manage multiple configurations

## Additional Exercises
1. Query additional Azure data sources
2. Create more complex combined tags
3. Explore other Terraform CLI commands
4. Practice state commands with different resources
5. Add more sensitive outputs and practice viewing them

## Common Issues and Solutions

If you see errors:
- Verify Azure credentials are still valid
- Ensure you're in the correct directory
- Check that all resources are properly referenced
- Verify location availability
- Confirm proper syntax for viewing sensitive outputs

## Conclusion
This lab demonstrated how to work with multiple configurations, use data sources, manage sensitive outputs, and properly clean up resources. These skills are essential for managing more complex Terraform deployments and maintaining clean Azure environments.