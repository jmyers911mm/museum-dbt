variable "environment" {
  type        = string
  description = "Deployment environment (dev, staging, prod)"
  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "Environment must be dev, staging, or prod."
  }
}

variable "location" {
  type        = string
  default     = "eastus"
  description = "Azure region for all resources"
}

variable "subscription_id" {
  type        = string
  description = "Azure subscription ID"
  sensitive   = true
}

variable "tenant_id" {
  type        = string
  description = "Azure AD tenant ID"
  sensitive   = true
}

variable "snowflake_account" {
  type        = string
  default     = "om01578"
  description = "Snowflake account identifier"
}

variable "snowflake_user" {
  type        = string
  description = "Snowflake service account username for Terraform"
  sensitive   = true
}

variable "key_vault_name" {
  type        = string
  description = "Globally unique name for the Key Vault instance"
}

variable "adf_service_principal_object_id" {
  type        = string
  description = "Object ID of the Snowflake Data Loading Service principal"
}

variable "dbt_service_principal_object_id" {
  type        = string
  description = "Object ID of the dbt runtime service principal"
}

variable "snowflake_warehouse_size" {
  type        = string
  default     = "MEDIUM"
  description = "Snowflake warehouse size (XSMALL, SMALL, MEDIUM, LARGE, XLARGE)"
  validation {
    condition     = contains(["XSMALL", "SMALL", "MEDIUM", "LARGE", "XLARGE"], var.snowflake_warehouse_size)
    error_message = "Must be a valid Snowflake warehouse size."
  }
}

variable "snowflake_warehouse_auto_suspend" {
  type        = number
  default     = 60
  description = "Seconds of inactivity before warehouse auto-suspends"
}

variable "teams_webhook_url" {
  type        = string
  description = "Microsoft Teams webhook URL for alert notifications (retrieved from Key Vault at runtime)"
  sensitive   = true
}

variable "cu_warning_threshold" {
  type        = number
  default     = 80
  description = "Percentage of credit consumption that triggers warning alert"
}

variable "cu_critical_threshold" {
  type        = number
  default     = 95
  description = "Percentage of credit consumption that triggers critical alert"
}

variable "static_web_app_sku" {
  type        = string
  default     = "Free"
  description = "Static Web App SKU tier (Free or Standard)"
}

variable "devops_organization_url" {
  type        = string
  description = "Azure DevOps organization URL"
}

variable "devops_project_name" {
  type        = string
  description = "Azure DevOps project name"
}

variable "dbt_repo_name" {
  type        = string
  default     = "museum-dbt"
  description = "Name of the dbt project repository in Azure DevOps"
}

variable "tags" {
  type = map(string)
  default = {
    project   = "ns11mm-data-platform"
    managedBy = "terraform-iac"
  }
  description = "Default tags applied to all Azure resources"
}
