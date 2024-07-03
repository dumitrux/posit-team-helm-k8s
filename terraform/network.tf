# [HTTP Data Source](https://registry.terraform.io/providers/hashicorp/http/latest/docs/data-sources/http)
data "http" "myip" {
  url = "https://api.ipify.org/"
}

# [Virtual Network](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_network)
resource "azurerm_virtual_network" "vnet" {
  name                = "vnet-${var.resource_suffix}"
  address_space       = ["10.0.0.0/14"]
  location            = azurerm_resource_group.posit.location
  resource_group_name = azurerm_resource_group.posit.name
  tags                = local.tags
}

# [Virtual Network Subnet](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/subnet)
resource "azurerm_subnet" "aks" {
  name                 = "AKSSubnet"
  resource_group_name  = azurerm_resource_group.posit.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.0.0/16"]

  service_endpoints = ["Microsoft.Storage"]
}

resource "azurerm_subnet" "workload" {
  name                 = "WorkloadSubnet"
  resource_group_name  = azurerm_resource_group.posit.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.1.0.0/25"]

  service_endpoints = ["Microsoft.Storage"]
}

# [Network Security Group](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_security_group)
resource "azurerm_network_security_group" "workload" {
  name                = "nsg-workload-${var.resource_suffix}"
  location            = var.location
  resource_group_name = azurerm_resource_group.posit.name
  tags                = local.tags
}

resource "azurerm_network_security_group" "aks" {
  name                = "nsg-aks-${var.resource_suffix}"
  location            = var.location
  resource_group_name = azurerm_resource_group.posit.name
  tags                = local.tags
}

# [Associate Network Security Group with Subnet](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/subnet_network_security_group_association)
resource "azurerm_subnet_network_security_group_association" "workload" {
  subnet_id                 = azurerm_subnet.workload.id
  network_security_group_id = azurerm_network_security_group.workload.id
}

resource "azurerm_subnet_network_security_group_association" "aks" {
  subnet_id                 = azurerm_subnet.aks.id
  network_security_group_id = azurerm_network_security_group.aks.id
}

# [Network Security Rule](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_security_rule)
resource "azurerm_network_security_rule" "allow22" {
  resource_group_name         = azurerm_resource_group.posit.name
  network_security_group_name = azurerm_network_security_group.workload.name

  name                       = "SSH"
  priority                   = 105
  direction                  = "Inbound"
  access                     = "Allow"
  protocol                   = "Tcp"
  source_port_range          = "*"
  source_address_prefix      = "${chomp(data.http.myip.response_body)}/32"
  destination_port_range     = "22"
  destination_address_prefix = "*"
}

resource "azurerm_network_security_rule" "allow_http" {
  resource_group_name         = azurerm_resource_group.posit.name
  network_security_group_name = azurerm_network_security_group.aks.name

  name                       = "SSH"
  priority                   = 105
  direction                  = "Inbound"
  access                     = "Allow"
  protocol                   = "Tcp"
  source_port_range          = "*"
  source_address_prefix      = "*"
  destination_port_ranges    = ["80", "443"]
  destination_address_prefix = "*"
}
