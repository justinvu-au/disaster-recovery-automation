output "storage_account_name" {
  value = azurerm_storage_account.dr_backup.name
}

output "resource_group_name" {
  value = azurerm_resource_group.dr_backup.name
}