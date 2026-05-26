variable "key_vault_name" {
  type        = string
  description = "Globally unique Key Vault name"
}

variable "location" {
  type        = string
  description = "Azure region"
}

variable "tenant_id" {
  type        = string
  description = "Azure AD tenant ID"
}

variable "adf_service_principal_object_id" {
  type        = string
  description = "Object ID of the data loading service principal"
}

variable "dbt_service_principal_object_id" {
  type        = string
  description = "Object ID of the dbt runtime service principal"
}

variable "environment" {
  type        = string
  description = "Deployment environment"
}

variable "tags" {
  type    = map(string)
  default = {}
}

resource "azurerm_resource_group" "keyvault" {
  name     = "rg-ns11mm-keyvault-${var.environment}"
  location = var.location
  tags     = merge(var.tags, { environment = var.environment })
}

resource "azurerm_key_vault" "main" {
  name                       = var.key_vault_name
  location                   = azurerm_resource_group.keyvault.location
  resource_group_name        = azurerm_resource_group.keyvault.name
  tenant_id                  = var.tenant_id
  sku_name                   = "standard"
  soft_delete_retention_days = 90
  purge_protection_enabled   = true

  access_policy {
    tenant_id = var.tenant_id
    object_id = var.adf_service_principal_object_id
    secret_permissions = ["Get", "List"]
  }

  access_policy {
    tenant_id = var.tenant_id
    object_id = var.dbt_service_principal_object_id
    secret_permissions = ["Get", "List"]
  }

  tags = merge(var.tags, { environment = var.environment })
}

output "vault_uri" {
  value = azurerm_key_vault.main.vault_uri
}

output "vault_id" {
  value = azurerm_key_vault.main.id
}

output "vault_name" {
  value = azurerm_key_vault.main.name
}
