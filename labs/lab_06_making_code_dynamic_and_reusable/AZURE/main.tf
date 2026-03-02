# Static configuration with hardcoded values
resource "azurerm_resource_group" "production" {
  name     = "production-resources"
  location = "eastus"

  tags = {
    Environment = "production"
    Project     = "static-infrastructure"
    ManagedBy   = "manual-deployment"
    Region      = "eastus"
  }
}

resource "azurerm_virtual_network" "production" {
  name                = "production-network"
  resource_group_name = azurerm_resource_group.production.name
  location            = azurerm_resource_group.production.location
  address_space       = ["10.0.0.0/16"]

  tags = {
    Environment = "production"
    Project     = "static-infrastructure"
    ManagedBy   = "manual-deployment"
    Region      = "eastus"
  }
}

resource "azurerm_subnet" "private" {
  name                 = "production-subnet"
  resource_group_name  = azurerm_resource_group.production.name
  virtual_network_name = azurerm_virtual_network.production.name
  address_prefixes     = ["10.0.1.0/24"]
}