
variable "frontend_resource_group_name" {
    type        = string
    
}

variable "location" {
    type        = string
}

variable "webpage_storage_account_name" {
    type        = string
  
}

variable "custom_domain" {
    type        = string
  
}

variable "cloudflare_zone_id" {
    type        = string
  
}

variable "backend_resource_group_name" {
    type        = string
    
}

variable "function_storage_account_name" {
    type        = string
  
}

variable "crc_alert_email" {
    type        = string
  
}

variable "crc_alert_country_code" {
    type        = string
  
}

variable "crc_alert_phone_number" {
    type        = string
  
}

variable "crc_pagerduty_webhook_url" {
    type        = string
  
}