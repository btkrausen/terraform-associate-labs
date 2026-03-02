# LAB-02-AZ: Creating Your First Azure Resource

## Overview
In this lab, you will create your first Azure resources using Terraform: a Resource Group and Virtual Network. We will build upon the configuration files created in LAB-01, adding resource configuration and implementing the full Terraform workflow. The lab introduces environment variables for Azure credentials, resource blocks, and the essential Terraform commands for resource management.

[![Lab 02](https://github.com/btkrausen/terraform-testing/actions/workflows/azure_lab_validation.yml/badge.svg?branch=main)](https://github.com/btkrausen/terraform-testing/actions/workflows/azure_lab_validation.yml)

**Preview Mode**: Use `Cmd/Ctrl + Shift + V` in VSCode to see a nicely formatted version of this lab!

## Prerequisites
- Terraform installed
- Azure CLI installed
- Azure account with appropriate permissions
- Completion of [LAB-01-AZ](https://github.com/btkrausen/terraform-codespaces/blob/main/labs/lab_01_getting_started_with_terraform/azure.md)

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

### 2. Configure Azure Credentials

First, authenticate with Azure:

```bash
az login
```

If you haven't authenticated before, this will open a web browser for you to sign in. After signing in, you should see your subscription information displayed in the terminal. Set your ARM_SUBSCRIPTION_ID environment variable:

```bash
export ARM_SUBSCRIPTION_ID=12345abdce
```

### 3. Add Resource Configuration

Open `main.tf` and add the following configuration (purposely not written in HCL canonical style):

```hcl
# Create the resource group
resource "azurerm_resource_group" "main" {
  name = "terraform-course"
  location = "eastus"

  tags = {
    Name        = "terraform-course"
    Environment = "Lab"
    Managed_By = "Terraform"
  }
}

# Create the virtual network
resource "azurerm_virtual_network" "main" {
  name = "terraform-network"
  resource_group_name = azurerm_resource_group.main.name
  location = azurerm_resource_group.main.location
  address_space = ["10.0.0.0/16"]

  tags = {
    Name        = "terraform-course"
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

The plan output will show that Terraform intends to create:
- A new resource group in East US
- A virtual network with address space `10.0.0.0/16`
- Both resources will have the specified tags

### 6. Apply the Configuration

Apply the configuration to create the resources:
```bash
terraform apply
```

Review the proposed changes and type `yes` when prompted to confirm.

### 7. Verify the Resources

Let's verify our resources in the Azure Portal:

1. Open your web browser and navigate to the Azure Portal (https://portal.azure.com)
2. In the search bar at the top, type `Resource groups` and select it from the results
3. You should see your `terraform-course` resource group listed
4. Click on the resource group to view its details
5. In the resource group overview, you should see:
   - The `terraform-network` virtual network listed as a resource
   - The tags you specified displayed in the Tags section
6. Click on the virtual network to examine its properties:
   - Verify the address space is set to `10.0.0.0/16`
   - Check that the location is set to `East US`
   - Confirm the tags are properly applied

### 8. Update the Virtual Network

In the `main.tf` file, update the virtual network configuration:

```hcl
resource "azurerm_virtual_network" "main" {
  name                = "terraform-network"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  address_space       = ["192.168.0.0/16"]  # <-- change IP Address

  tags = {
    Name        = "terraform-course"
    Environment = "Lab"
    Managed_By  = "Terraform"
  }
}
```

### 9. Run a Terraform Plan to Perform a Dry Run

Generate and review the execution plan:
```bash
terraform plan
```

The plan output will show that Terraform will update the virtual network in-place:
- The address space will be updated to `192.168.0.0/16`

### 10. Apply the Configuration

Apply the configuration to update the virtual network:
```bash
terraform apply
```

Review the proposed changes and type `yes` when prompted to confirm.

### 11. Update the Tags

In the `main.tf` file, update both resource tags:

```hcl
  tags = {
    Name        = "terraform-course"
    Environment = "learning-terraform"  # <-- change tag here
    Managed_By  = "Terraform"
  }
```

### 12. Run a Terraform Plan to Perform a Dry Run

Generate and review the execution plan:
```bash
terraform plan
```

The plan output will show that Terraform will update both resources in-place:
- The tags will be updated on both resources

### 13. Apply the Configuration

Apply the configuration to update the tags:
```bash
terraform apply
```

Review the proposed changes and type `yes` when prompted to confirm.

## Verification Steps

Confirm that:
1. The resources exist in your Azure subscription with:
   - Resource group named `terraform-course`
   - Virtual network with address space `192.168.0.0/16`
   - All specified tags present
2. A terraform.tfstate file exists in your directory
3. All Terraform commands completed successfully

## Success Criteria
Your lab is successful if:
- Azure credentials are properly configured using environment variables
- The resources are successfully created with all specified configurations
- All Terraform commands execute without errors
- The terraform.tfstate file accurately reflects your infrastructure
- The resources are successfully destroyed during cleanup

## Additional Exercises
1. Try changing the resource group location and observe the implications
2. Experiment with different virtual network address spaces
3. Review the terraform.tfstate file to understand how Terraform tracks resource state

## Common Issues and Solutions

If you encounter credential errors:
- Double-check your environment variable values
- Ensure there are no extra spaces or special characters
- Verify your Azure service principal has appropriate permissions

If you see address space conflicts:
- Ensure your chosen address space doesn't overlap with existing networks
- Verify the address space follows proper formatting (e.g., 192.168.0.0/16)

## Next Steps
In the next lab, we will build upon this virtual network by adding additional networking components. Keep your Terraform configuration files intact, as we will continue to expand upon them.