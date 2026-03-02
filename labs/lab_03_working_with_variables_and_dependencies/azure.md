# LAB-03-AZ: Working with Variables and Outputs

## Overview
In this lab, you will enhance your existing Azure configuration by implementing variables and outputs. You'll learn how variables work, how different variable definitions take precedence, and how to use output values to display resource information. We'll build this incrementally to understand how each change affects our configuration.

[![Lab 03](https://github.com/btkrausen/terraform-testing/actions/workflows/azure_lab_validation.yml/badge.svg?branch=main)](https://github.com/btkrausen/terraform-testing/actions/workflows/azure_lab_validation.yml)

**Preview Mode**: Use `Cmd/Ctrl + Shift + V` in VSCode to see a nicely formatted version of this lab!

## Prerequisites
- Terraform installed
- Azure account with appropriate permissions
- Completion of [LAB-02-AZ](https://github.com/btkrausen/terraform-codespaces/blob/main/labs/lab_02_create_your_first_resource/azure.md) with existing Resource Group and VNet configuration

## Estimated Time
20 minutes

## Lab Steps

### 1. Review Current Configuration

First, let's review our current main.tf file from the previous lab:

```hcl
resource "azurerm_resource_group" "main" {
  name     = "terraform-course"
  location = "eastus"

  tags = {
    Name        = "terraform-course"
    Environment = "learning-terraform"
    Managed_By  = "Terraform"
  }
}

resource "azurerm_virtual_network" "main" {
  name                = "terraform-network"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  address_space       = ["192.168.0.0/16"]

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
variable "vnet_address_space" {
  description = "Address space for Virtual Network"
  type        = list(string)
  default     = ["192.168.0.0/16"]
}

variable "environment" {
  description = "Environment name for tagging"
  type        = string
  default     = "learning-terraform"
}

variable "location" {
  description = "Azure region for resources"
  type        = string
  default     = "eastus"
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
resource "azurerm_resource_group" "main" {
  name     = "terraform-course"
  location = var.location # <-- update value here

  tags = {
    Name        = "terraform-course"
    Environment = var.environment # <-- update value here
    Managed_By  = "Terraform"
  }
}

resource "azurerm_virtual_network" "main" {
  name                = "terraform-network"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  address_space       = var.vnet_address_space # <-- update value here

  tags = {
    Name        = "terraform-course"
    Environment = var.environment # <-- update value here
    Managed_By  = "Terraform"
  }
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
vnet_address_space = ["10.0.0.0/16"]
environment        = "development"
```

Run another plan:
```bash
terraform plan
```

Now you should see that Terraform plans to destroy and recreate the resources because:
- The Virtual Network address space will change from 192.168.0.0/16 to 10.0.0.0/16
- The Environment tag will change from "learning-terraform" to "development"

Apply the changes:
```bash
terraform apply
```

Review the proposed changes and type `yes` when prompted to confirm.

### 6. Add Output Definitions

Create a new file named `outputs.tf` and add the following output blocks:

```hcl
output "resource_group_id" {
  description = "ID of the created Resource Group"
  value       = azurerm_resource_group.main.id
}

output "vnet_id" {
  description = "ID of the created Virtual Network"
  value       = azurerm_virtual_network.main.id
}

output "vnet_address_space" {
  description = "Address space of the Virtual Network"
  value       = azurerm_virtual_network.main.address_space
}
```

Run terraform apply to register the outputs:
```bash
terraform apply
```

You should now see the output values displayed after the apply completes.

### 7. Experiment with Variable Precedence

Create a new file named `testing.tfvars`:
```hcl
vnet_address_space = ["172.16.0.0/16"]
environment        = "testing"
```

Try running a plan with this new variable file to see how to specify a specific variables file:
```bash
terraform plan -var-file="testing.tfvars"
```

You'll see that these values would override both the defaults and the values in `terraform.tfvars`.

### 8. Delete the Testing File

Delete the file `testing.tfvars`.

Run a `terraform plan` to validate that no changes are needed since our real-world infrastructure matches our Terraform configuration.

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
2. Create additional output values for other resource attributes
3. Experiment with changing values in different variable files

## Common Issues and Solutions

If you see unexpected changes:
- Review the variable precedence order
- Check which variable files are being used
- Verify the current state of your resources

## Next Steps
In the next lab, we will expand our infrastructure by adding multiple resources that depend on each other. Keep your Terraform configuration files intact, as we will continue to expand upon them.