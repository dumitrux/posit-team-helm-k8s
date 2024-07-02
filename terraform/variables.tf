variable "environment" {
  default     = "test"
  description = "The name of the environment in which resources will be deployed"
  type        = string
}

variable "location" {
  default     = "uksouth"
  description = "The short-format Azure region into which resources will be deployed"
  type        = string
}

variable "resource_group_name" {
  description = "The name of the resource group in which resources will be deployed"
  type        = string
}

variable "resource_suffix" {
  description = "The resource suffix to append to resources"
  type        = string

  validation {
    condition     = can(regex("^[a-z\\d]+(-[a-z\\d]+)*$", var.resource_suffix))
    error_message = "Resource names should use only lowercase characters, numbers, and hyphens."
  }
}

variable "role_assignments" {
  default     = {}
  description = <<-EOT
  An object used to define role assignments for resources, in the format:
  ```
  {
    aks = {
      service_principal_aks_cluster_admin = {
        principal_id         = "0000000000-0000-0000-0000-000000000001"
        role_definition_name = "Azure Kubernetes Service RBAC Cluster Admin"
      }
    }
    key_vault = {
      service_principal_key_vault_administrator = {
        principal_id                 = "0000000000-0000-0000-0000-000000000001"
        principal_type               = "ServicePrincipal"
        role_definition_name         = "Key Vault Administrator"
        skip_service_principal_check = true
      }
    }
  }
  ```
  EOT
  type = object({
    aks = optional(map(object({
      principal_id                 = string
      role_definition_name         = string
      description                  = optional(string)
      principal_type               = optional(string, "User")
      skip_service_principal_check = optional(bool, false)
    })), {}),
    key_vault = optional(map(object({
      principal_id                 = string
      role_definition_name         = string
      description                  = optional(string)
      principal_type               = optional(string, "User")
      skip_service_principal_check = optional(bool, false)
    })), {})
  })
}

variable "tags" {
  default     = {}
  description = "A collection of tags to assign to taggable resources"
  type        = map(string)
}
