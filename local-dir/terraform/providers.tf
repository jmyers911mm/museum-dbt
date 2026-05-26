terraform {
  required_version = ">= 1.5.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.80"
    }
    snowflake = {
      source  = "Snowflake-Labs/snowflake"
      version = "~> 0.87"
    }
  }

  backend "azurerm" {
    resource_group_name  = "rg-ns11mm-terraform"
    storage_account_name = "stns11mmtfstate"
    container_name       = "tfstate"
    key                  = "ns11mm-data-platform.tfstate"
  }
}

provider "azurerm" {
  features {
    key_vault {
      purge_soft_delete_on_destroy = false
    }
  }
  subscription_id = var.subscription_id
  tenant_id       = var.tenant_id
}

provider "snowflake" {
  account  = var.snowflake_account
  username = var.snowflake_user
  role     = "ACCOUNTADMIN"
}
