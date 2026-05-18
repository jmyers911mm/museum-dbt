module "key_vault" {
  source = "./modules/key-vault"

  key_vault_name                  = var.key_vault_name
  location                        = var.location
  tenant_id                       = var.tenant_id
  adf_service_principal_object_id = var.adf_service_principal_object_id
  dbt_service_principal_object_id = var.dbt_service_principal_object_id
  environment                     = var.environment
  tags                            = var.tags
}

module "snowflake_warehouse" {
  source = "./modules/snowflake-warehouse"

  environment    = var.environment
  warehouse_size = var.snowflake_warehouse_size
  auto_suspend   = var.snowflake_warehouse_auto_suspend
  tags           = var.tags
}

module "static_web_app" {
  source = "./modules/static-web-app"

  location    = var.location
  environment = var.environment
  sku         = var.static_web_app_sku
  tags        = var.tags

  depends_on = [module.key_vault]
}

module "monitor_alerts" {
  source = "./modules/monitor-alerts"

  location               = var.location
  environment            = var.environment
  teams_webhook_url      = var.teams_webhook_url
  cu_warning_threshold   = var.cu_warning_threshold
  cu_critical_threshold  = var.cu_critical_threshold
  tags                   = var.tags

  depends_on = [module.key_vault, module.snowflake_warehouse]
}
