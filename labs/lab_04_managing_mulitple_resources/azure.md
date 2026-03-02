# LAB-04-AZ: Managing Multiple Resources and Dependencies

## Overview
In this lab, you will expand your Virtual Network configuration by adding multiple interconnected resources. You'll learn how Terraform manages dependencies between resources and how to structure more complex configurations. We'll create subnets, network security groups, and security rules, all of which are free resources in Azure.

 [![Lab 04](https://github.com/btkrausen/terraform-testing/actions/workflows/azure_lab_validation.yml/badge.svg?branch=main)](https://github.com/btkrausen/terraform-testing/actions/workflows/azure_lab_validation.yml)

**Preview Mode**: Use `Cmd/Ctrl + Shift + V` in VSCode to see a nicely formatted version of this lab!

## Prerequisites
- Terraform installed
- Azure account with appropriate permissions
- Completion of [LAB-03-AZ](https://github.com/btkrausen/terraform-codespaces/blob/main/labs/lab_03_working_with_variables_and_dependencies/azure.md) with existing Resource Group and VNet configuration

## Estimated Time
30 minutes

## Lab Steps

### 1. Add New Variable Definitions

Add the following to your existing `variables.tf`:

```hcl
# Subnet Variables
variable "web_subnet_cidr" {
  description = "CIDR block for web subnet"
  type        = string
  default     = "10.0.1.0/24"
}

variable "app_subnet_cidr" {
  description = "CIDR block for app subnet"
  type        = string
  default     = "10.0.2.0/24"
}
```

### 2. Create Subnets

Add the following subnet configurations to `main.tf`. Notice how we're using the resource identifier and references to the Virtual Network that was created in Lab 2:

```hcl
# Create Subnets
resource "azurerm_subnet" "web" {
  name                 = "web-subnet"
  resource_group_name  = azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = [var.web_subnet_cidr]
}

resource "azurerm_subnet" "app" {
  name                 = "app-subnet"
  resource_group_name  = azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = [var.app_subnet_cidr]
}
```

> Notice how we're using both resource referencing (to the Resource Group and VNet resources) and using variables to make these resource blocks dynamic and without hardcoding any important values. By simply changing variable values, these subnets could look completely different, including different IP addresses.

### 3. Create Network Security Groups

Add Network Security Groups for both subnets by adding the following resource blocks to `main.tf`:

```hcl
# Network Security Groups
resource "azurerm_network_security_group" "web" {
  name                = "web-nsg"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name

  tags = {
    Name        = "web-nsg"
    Environment = var.environment
  }
}

resource "azurerm_network_security_group" "app" {
  name                = "app-nsg"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name

  tags = {
    Name        = "app-nsg"
    Environment = var.environment
  }
}
```

### 4. Create NSG Rules

Add security rules to the NSGs:

```hcl
# NSG Rules for Web Subnet
resource "azurerm_network_security_rule" "web_http" {
  name                        = "Allow-HTTP"
  priority                    = 100
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range          = "*"
  destination_port_range     = "80"
  source_address_prefix      = "*"
  destination_address_prefix = "*"
  resource_group_name        = azurerm_resource_group.main.name
  network_security_group_name = azurerm_network_security_group.web.name
}

resource "azurerm_network_security_rule" "web_https" {
  name                        = "Allow-HTTPS"
  priority                    = 110
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range          = "*"
  destination_port_range     = "443"
  source_address_prefix      = "*"
  destination_address_prefix = "*"
  resource_group_name        = azurerm_resource_group.main.name
  network_security_group_name = azurerm_network_security_group.web.name
}

# NSG Rule for App Subnet
resource "azurerm_network_security_rule" "app_internal" {
  name                        = "Allow-Internal"
  priority                    = 100
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range          = "*"
  destination_port_range     = "8080"
  source_address_prefix      = var.web_subnet_cidr
  destination_address_prefix = "*"
  resource_group_name        = azurerm_resource_group.main.name
  network_security_group_name = azurerm_network_security_group.app.name
}
```

### 5. Associate NSGs with Subnets

Create the associations between NSGs and their respective subnets:

```hcl
# NSG Associations
resource "azurerm_subnet_network_security_group_association" "web" {
  subnet_id                 = azurerm_subnet.web.id
  network_security_group_id = azurerm_network_security_group.web.id
}

resource "azurerm_subnet_network_security_group_association" "app" {
  subnet_id                 = azurerm_subnet.app.id
  network_security_group_id = azurerm_network_security_group.app.id
}
```

> Note that Terraform knows that the Subnets and NSGs must be created FIRST before these associations can be created since these resources require the IDs of both resources. This is called an implicit dependency.

### 6. Add New Outputs

Add the following output blocks to your `outputs.tf` file to see information about the newly created subnets:

```hcl
output "web_subnet_id" {
  description = "ID of the web subnet"
  value       = azurerm_subnet.web.id
}

output "app_subnet_id" {
  description = "ID of the app subnet"
  value       = azurerm_subnet.app.id
}

output "web_nsg_id" {
  description = "ID of the web NSG"
  value       = azurerm_network_security_group.web.id
}

output "app_nsg_id" {
  description = "ID of the app NSG"
  value       = azurerm_network_security_group.app.id
}
```

### 7. Update terraform.tfvars

Add the subnet CIDR values to your existing `terraform.tfvars`:

```hcl
# Subnet Variables
web_subnet_cidr = "10.0.1.0/24"
app_subnet_cidr = "10.0.2.0/24"
```

### 8. Apply the Configuration

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
1. The Virtual Network must exist before subnets can be created
2. Subnets and NSGs must exist before their associations can be created
3. NSGs must exist before security rules can be added

This is handled through implicit dependencies, where Terraform reads the resource configurations and determines the relationships based on resource references (like `resource_group_name = azurerm_resource_group.main.name`).

## Verification Steps

In the Azure Portal:
1. Navigate to your Resource Group
2. Verify the subnets exist within your Virtual Network
3. Check the NSG rules and associations
4. Confirm the security rules are properly configured

## Success Criteria
Your lab is successful if:
- All resources are created successfully
- Resource dependencies are properly maintained
- All resources have the correct tags
- The NSGs have the specified security rules
- You can see all resource IDs in the outputs

## Additional Exercises
1. Add more security rules to the NSGs
2. Create additional subnets with different purposes
3. Add more specific tags to different resources

## Common Issues and Solutions

If you see dependency errors:
- Verify resource references are correct
- Ensure resources exist before being referenced
- Check for circular dependencies

## Next Steps
In the next lab, we will learn about state management. Keep your Terraform configuration files intact, as we will continue to expand upon them.