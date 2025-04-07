// This file contains sensitive information and should not be shared publicly.
// These variables assign values to the Terraform configuration and are used to set up the infrastructure.

frontend_resource_group_name = "crc-frontend-rg"
backend_resource_group_name = "crc-backend-rg"
location = "UK South"
webpage_storage_account_name = "crcwebpagesa2025"
custom_domain = "cv.nextwithaw.info"
cloudflare_zone_id = "92e20ca0fe446192e7243c5032239b47"
function_storage_account_name = "crcfunctionsa2025"
crc_alert_email = "aroshlakshan@outlook.com"
crc_alert_country_code = "44"
crc_alert_phone_number = "7309413644"
crc_pagerduty_webhook_url = "https://events.eu.pagerduty.com/integration/597859ff2a53410dd170928682ac8756/enqueue"