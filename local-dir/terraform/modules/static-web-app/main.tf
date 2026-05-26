variable "location" {
  type        = string
  default     = "eastus2"
  description = "Static Web Apps have limited region availability"
}

variable "environment" {
  type        = string
  description = "Deployment environment"
}

variable "sku" {
  type        = string
  default     = "Free"
  description = "Free tier sufficient for internal dbt docs"
}

variable "tags" {
  type    = map(string)
  default = {}
}

resource "azurerm_resource_group" "docs" {
  name     = "rg-ns11mm-docs-${var.environment}"
  location = var.location
  tags     = merge(var.tags, { environment = var.environment })
}

resource "azurerm_static_web_app" "dbt_docs" {
  name                = "swa-ns11mm-dbt-docs-${var.environment}"
  resource_group_name = azurerm_resource_group.docs.name
  location            = azurerm_resource_group.docs.location
  sku_tier            = var.sku
  sku_size            = var.sku

  tags = merge(var.tags, {
    environment = var.environment
    purpose     = "dbt-docs"
  })
}

output "default_hostname" {
  value = azurerm_static_web_app.dbt_docs.default_host_name
}

output "static_site_id" {
  value = azurerm_static_web_app.dbt_docs.id
}

output "api_key" {
  value     = azurerm_static_web_app.dbt_docs.api_key
  sensitive = true
}
