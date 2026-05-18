variable "environment" {
  type        = string
  description = "Deployment environment"
}

variable "warehouse_size" {
  type        = string
  default     = "MEDIUM"
  description = "Snowflake warehouse size"
}

variable "auto_suspend" {
  type        = number
  default     = 60
  description = "Auto-suspend after N seconds of inactivity"
}

variable "tags" {
  type    = map(string)
  default = {}
}

locals {
  warehouse_configs = {
    dev = {
      name = "DBT_DEV_WH"
      size = "XSMALL"
    }
    staging = {
      name = "DBT_STAGING_WH"
      size = var.warehouse_size
    }
    prod = {
      name = "DBT_PROD_WH"
      size = var.warehouse_size
    }
  }
  config = local.warehouse_configs[var.environment]
}

resource "snowflake_warehouse" "dbt" {
  name           = local.config.name
  warehouse_size = local.config.size
  auto_suspend   = var.auto_suspend
  auto_resume    = true
  initially_suspended = true

  comment = "Managed by Terraform — ${var.environment} environment"
}

resource "snowflake_resource_monitor" "dbt" {
  name         = "${local.config.name}_MONITOR"
  credit_quota = var.environment == "prod" ? 50 : (var.environment == "staging" ? 20 : 5)

  frequency       = "MONTHLY"
  start_timestamp = "IMMEDIATELY"

  notify_triggers            = [80]
  suspend_triggers           = [95]
  suspend_immediate_triggers = [100]

  warehouses = [snowflake_warehouse.dbt.name]
}

output "warehouse_name" {
  value = snowflake_warehouse.dbt.name
}

output "warehouse_size" {
  value = snowflake_warehouse.dbt.warehouse_size
}

output "monitor_name" {
  value = snowflake_resource_monitor.dbt.name
}
