// Action Group for the CRC Function App

resource "azurerm_monitor_action_group" "crc_action_group" {

  name                = "crcactiongroup"
  resource_group_name = azurerm_resource_group.function_resource_group.name
  short_name          = "ccrcactngrp"

    email_receiver {
        name          = "crcalertemailreceiver"
        email_address = var.crc_alert_email
    }

    sms_receiver {
        name         = "oncallmsg"
        country_code = var.crc_alert_country_code
        phone_number = var.crc_alert_phone_number
    }

    webhook_receiver { //PagerDuty Webhook Receiver
        name                    = "crcpagerdutywebhookreceiver"
        service_uri             = var.crc_pagerduty_webhook_url
        use_common_alert_schema = true
    }
}

// Alert Rule for CRC Function App
resource "azurerm_monitor_scheduled_query_rules_alert_v2" "crc_failure_alert_rule" {
  name                = "crcfailurealertrule"
  resource_group_name = azurerm_resource_group.function_resource_group.name
  location            = azurerm_resource_group.function_resource_group.location
  evaluation_frequency = "PT15M"
  window_duration      = "PT15M"
  scopes               = [azurerm_application_insights.crc_function_application_insights.id] // This is where alrt rule associated with the Application Insights resource
  severity             = 1
  criteria {
    query                   = <<-QUERY
      requests
        | where success == false                         
        | where timestamp > ago(15m) 
        | summarize failedCount = sum(itemCount), impactedUsers = dcount(user_Id) by operation_Name
        | order by failedCount desc
      QUERY
    time_aggregation_method = "Total"
    threshold               = 3
    operator                = "GreaterThanOrEqual"
    metric_measure_column = "failedCount"
  }

  action {
    action_groups = [azurerm_monitor_action_group.crc_action_group.id] //This is where the alert rule is associated with the action group
  }

}