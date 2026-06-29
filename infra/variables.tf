variable "subscription_id" {
  description = "Azure subscription ID"
  type        = string
}

variable "backup_location" {
  description = "Azure region for backup storage"
  type        = string
  default     = "australiasoutheast"
}