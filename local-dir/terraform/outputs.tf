output "key_vault_uri" {
  value       = module.key_vault.vault_uri
  description = "Key Vault URI for secret retrieval"
}

output "key_vault_id" {
  value       = module.key_vault.vault_id
  description = "Key Vault resource ID"
}

output "snowflake_warehouse_name" {
  value       = module.snowflake_warehouse.warehouse_name
  description = "Name of the provisioned Snowflake warehouse"
}

output "static_web_app_hostname" {
  value       = module.static_web_app.default_hostname
  description = "Default hostname for the dbt docs Static Web App"
}

output "static_web_app_id" {
  value       = module.static_web_app.static_site_id
  description = "Resource ID of the Static Web App"
}
