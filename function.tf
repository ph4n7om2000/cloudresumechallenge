// Create backend resource group for the function app
resource "azurerm_resource_group" "function_resource_group" {
  name = var.backend_resource_group_name
  location = var.location
}

// Create a storage account for the function app
resource "azurerm_storage_account" "function_storage_account" {
  name                     = var.function_storage_account_name
  resource_group_name      = azurerm_resource_group.function_resource_group.name
  location                 = azurerm_resource_group.function_resource_group.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

// Create a storage container for the function app
// This is where the function code will be stored
resource "azurerm_storage_container" "crc_functions" {
  name                  = "crc-function-container"
  storage_account_id    = azurerm_storage_account.function_storage_account.id
  container_access_type = "private"
}

// Create a blob in the storage container for the function code and upload the ZIP file
// Ensure the ZIP file is present in the same directory as this Terraform file
resource "azurerm_storage_blob" "function_code" {
  name                   = "GetResumeCount.zip"
  storage_account_name   = azurerm_storage_account.function_storage_account.name
  storage_container_name = azurerm_storage_container.crc_functions.name
  type                   = "Block"
  source                 = "GetResumeCount.zip" # Ensure the ZIP is present here
}

// Create a SAS token for the storage account blob container
// This token will be used to access the function code in the blob storage
data "azurerm_storage_account_blob_container_sas" "sas_key" {
  connection_string = azurerm_storage_account.function_storage_account.primary_connection_string
  container_name    = azurerm_storage_container.crc_functions.name
  permissions {
    read   = true
    add    = false
    create = false
    delete = false
    list   = false
    write  = false
  }
  start             = timestamp()
  expiry            = timeadd(timestamp(), "8760h") # Valid for 1 year
}

// Create a function app service plan
// This is where the function app will run
resource "azurerm_service_plan" "crc_function_service_plan" {
  name                = "crc-visitor-counter-function-service-plan"
  location            =  azurerm_resource_group.function_resource_group.location
  resource_group_name = azurerm_resource_group.function_resource_group.name
  os_type             = "Linux" // Since the function app code is written on Python 3.10, we need to use Linux OS
  sku_name            = "Y1"
}

// Create application insights for the function app
// This will help in monitoring the function app
resource "azurerm_application_insights" "crc_function_application_insights" {
  name                = "crc-visitor-counter-app-insights"
  location            = azurerm_resource_group.function_resource_group.location
  resource_group_name = azurerm_resource_group.function_resource_group.name
  application_type    = "web"
}

// Create the function app
// This is where the function code will be executed
resource "azurerm_linux_function_app" "crc_function_app" {
    depends_on = [ azurerm_cosmosdb_sql_container.crc_container ]
  name                       = "crc-visitor-counter-function-app"
  location                   = azurerm_resource_group.function_resource_group.location
  resource_group_name        = azurerm_resource_group.function_resource_group.name
  service_plan_id        = azurerm_service_plan.crc_function_service_plan.id
  storage_account_name       = azurerm_storage_account.function_storage_account.name
  storage_account_access_key = azurerm_storage_account.function_storage_account.primary_access_key
  

  
  site_config {
    application_stack {
      python_version = "3.10" // Ensure the Python version is compatible with the code
      
    }
    cors {
      allowed_origins = [ "https://${azurerm_cdn_frontdoor_custom_domain.frontdoor_domain.host_name}"] // Ensure CORS is enabled for the website to call the function app

    }

  }

  app_settings = {
    // This is where the function app settings are defined.
    "WEBSITE_RUN_FROM_PACKAGE" = "https://${azurerm_storage_account.function_storage_account.name}.blob.core.windows.net/${azurerm_storage_container.crc_functions.name}/${azurerm_storage_blob.function_code.name}${data.azurerm_storage_account_blob_container_sas.sas_key.sas}",
    "FUNCTIONS_WORKER_RUNTIME" = "python",
    "APPINSIGHTS_INSTRUMENTATIONKEY" = azurerm_application_insights.crc_function_application_insights.instrumentation_key,
    "FUNCTIONS_EXTENTION_VERSION" = "~4"
    application_insights_connection_string = azurerm_application_insights.crc_function_application_insights.connection_string
    application_insights_key = azurerm_application_insights.crc_function_application_insights.instrumentation_key
    "COSMOS_DB_CONNECTION_STRING"   = azurerm_cosmosdb_account.crc_cosmos_DB.primary_sql_connection_string
    "COSMOS_DB_DATABASE_NAME"       = azurerm_cosmosdb_sql_database.crc_DB.name
    "COSMOS_DB_CONTAINER_NAME"      = azurerm_cosmosdb_sql_container.crc_container.name

  }

}
