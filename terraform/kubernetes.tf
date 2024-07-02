# [Kubernetes Cluster](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/kubernetes_cluster)
resource "azurerm_kubernetes_cluster" "aks" {
  name                = "aks-${var.resource_suffix}"
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = local.tags

  dns_prefix = "aks"

  azure_active_directory_role_based_access_control {
    managed            = true
    azure_rbac_enabled = true
  }

  default_node_pool {
    temporary_name_for_rotation = "tmp"
    name                        = "system"
    vm_size                     = "Standard_DS2_v2"

    only_critical_addons_enabled = true
    type                         = "VirtualMachineScaleSets"

    # Scale configuration
    enable_auto_scaling = true
    min_count           = 1
    max_count           = 2
    node_count          = 1
    scale_down_mode     = "Delete"

    upgrade_settings {
      max_surge = "33%"
    }

    # Network configuration
    enable_node_public_ip = false
    vnet_subnet_id        = azurerm_subnet.aks.id

    # Pod configuration
    max_pods = 50

    # OS configuration
    os_disk_size_gb = 80
    os_disk_type    = "Ephemeral"
    os_sku          = "Ubuntu"
  }

  identity {
    type = "SystemAssigned"
  }

  network_profile {
    network_plugin = "azure"

    load_balancer_sku   = "standard"
    network_mode        = "transparent"
    network_plugin_mode = "overlay"
    network_policy      = "azure"
    outbound_type       = "loadBalancer"
    dns_service_ip      = "10.2.0.10"
    service_cidr        = "10.2.0.0/16"
  }
}

# [Kubernetes Cluster Node Pool](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/kubernetes_cluster_node_pool)
resource "azurerm_kubernetes_cluster_node_pool" "workload" {
  name                  = "workload"
  kubernetes_cluster_id = azurerm_kubernetes_cluster.aks.id
  tags                  = local.tags

  vm_size = "Standard_DS3_v2"

  mode = "User"

  # Scale configuration
  enable_auto_scaling = true
  min_count           = 2
  max_count           = 5
  node_count          = 2
  scale_down_mode     = "Delete"

  upgrade_settings {
    max_surge = "33%"
  }

  # Network configuration
  enable_node_public_ip = false
  vnet_subnet_id        = azurerm_subnet.aks.id

  # Pod configuration
  max_pods = 50

  # OS configuration
  os_disk_size_gb = 120
  os_disk_type    = "Ephemeral"
  os_sku          = "Ubuntu"
}
