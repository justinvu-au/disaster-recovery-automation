terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
  }
  required_version = ">= 1.5.0"

}

provider "azurerm" {
  features {}
  subscription_id = var.subscription_id
}

resource "azurerm_resource_group" "dr_backup" {
  name     = "dr-backup-rg"
  location = var.backup_location

  tags = {
    purpose    = "disaster-recovery"
    managed_by = "terraform"
  }
}

resource "azurerm_storage_account" "dr_backup" {
  name                     = "plstatsdrbackup"
  location                 = azurerm_resource_group.dr_backup.location
  resource_group_name      = azurerm_resource_group.dr_backup.name
  account_tier             = "Standard"
  account_replication_type = "LRS"

  blob_properties {
    versioning_enabled = true
    delete_retention_policy {
      days = 30
    }

    container_delete_retention_policy {
      days = 30
    }
  }

  tags = {
    purpose    = "disaster-recovery"
    managed_by = "terraform"
  }
}

resource "azurerm_storage_container" "tfstate" {
  name                  = "tfstate"
  storage_account_name  = azurerm_storage_account.dr_backup.name
  container_access_type = "private"
}

resource "azurerm_storage_container" "state_backups" {
  name                  = "state-backups"
  storage_account_name  = azurerm_storage_account.dr_backup.name
  container_access_type = "private"
}

resource "azurerm_storage_container" "secrets_backups" {
  name                  = "secrets-backups"
  storage_account_name  = azurerm_storage_account.dr_backup.name
  container_access_type = "private"
}