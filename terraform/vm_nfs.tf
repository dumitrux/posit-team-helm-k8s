# [Public IP Address](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/public_ip)
resource "azurerm_public_ip" "nfs" {
  name                = "pip-nfs-${var.resource_suffix}"
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = local.tags

  allocation_method = "Static"
  sku               = "Standard"
}

# [Network Interface](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_interface)
resource "azurerm_network_interface" "nfs" {
  name                = "nic-nfs-${var.resource_suffix}"
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = local.tags

  ip_configuration {
    name                          = "public"
    public_ip_address_id          = azurerm_public_ip.nfs.id
    subnet_id                     = azurerm_subnet.workload.id
    private_ip_address_allocation = "Dynamic"
  }
}

# [Linux Virtual Machine](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/linux_virtual_machine)
resource "azurerm_linux_virtual_machine" "nfs" {
  name                = "vm-nfs-workbench-${var.resource_suffix}"
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = local.tags

  admin_username                  = "adminuser"
  admin_password                  = random_password.vm.result
  disable_password_authentication = false
  network_interface_ids           = [azurerm_network_interface.nfs.id]
  size                            = "Standard_B2s"

  # computer_name = "nfs-posit"

  identity {
    type = "SystemAssigned"
  }

  os_disk {
    caching              = "ReadWrite"
    disk_size_gb         = 256
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
  }
}
