variable "location" {
  type        = string
  description = "Azure region"
}

variable "environment" {
  type        = string
  description = "Deployment environment"
}

variable "teams_webhook_url" {
  type        = string
  sensitive   = true
  description = "Teams webhook for alert notifications"
}

variable "cu_warning_threshold" {
  type        = number
  default     = 80
  description = "Credit consumption warning percentage"
}

variable "cu_critical_threshold" {
  type        = number
  default     = 95
  description = "Credit consumption critical percentage"
}

variable "tags" {
  type    = map(string)
  default = {}
}

resource "azurerm_resource_group" "monitoring" {
  name     = "rg-ns11mm-monitoring-${var.environment}"
  location = var.location
  tags     = merge(var.tags, { environment = var.environment })
}

resource "azurerm_monitor_action_group" "teams" {
  name                = "ag-ns11mm-teams-${var.environment}"
  resource_group_name = azurerm_resource_group.monitoring.name
  short_name          = "ns11mm"

  webhook_receiver {
    name                    = "teams-data-channel"
    service_uri             = var.teams_webhook_url
    use_common_alert_schema = true
  }

  tags = merge(var.tags, { environment = var.environment })
}

resource "azurerm_monitor_metric_alert" "credit_warning" {
  name                = "alert-snowflake-credit-warning-${var.environment}"
  resource_group_name = azurerm_resource_group.monitoring.name
  description         = "Snowflake credit consumption exceeded ${var.cu_warning_threshold}% of budget"
  severity            = 2
  frequency           = "PT5M"
  window_size         = "PT15M"
  enabled             = var.environment == "prod" ? true : false

  criteria {
    metric_namespace = "Snowflake"
    metric_name      = "CreditConsumptionPercent"
    aggregation      = "Average"
    operator         = "GreaterThan"
    threshold        = var.cu_warning_threshold
  }

  action {
    action_group_id = azurerm_monitor_action_group.teams.id
  }

  tags = merge(var.tags, { environment = var.environment })
}

resource "azurerm_monitor_metric_alert" "credit_critical" {
  name                = "alert-snowflake-credit-critical-${var.environment}"
  resource_group_name = azurerm_resource_group.monitoring.name
  description         = "CRITICAL: Snowflake credit consumption exceeded ${var.cu_critical_threshold}%"
  severity            = 0
  frequency           = "PT1M"
  window_size         = "PT5M"
  enabled             = var.environment == "prod" ? true : false

  criteria {
    metric_namespace = "Snowflake"
    metric_name      = "CreditConsumptionPercent"
    aggregation      = "Average"
    operator         = "GreaterThan"
    threshold        = var.cu_critical_threshold
  }

  action {
    action_group_id = azurerm_monitor_action_group.teams.id
  }

  tags = merge(var.tags, { environment = var.environment })
}

output "action_group_id" {
  value = azurerm_monitor_action_group.teams.id
}
