// Create a Cosmos DB account
resource "azurerm_cosmosdb_account" "crc_cosmos_DB" {
  name                = "crc-dbaccount-temp" 
  location            = azurerm_resource_group.function_resource_group.location
  resource_group_name = azurerm_resource_group.function_resource_group.name
  offer_type          = "Standard"
  kind                = "GlobalDocumentDB"

  consistency_policy {
    consistency_level = "Session"
  }

  geo_location {
    location          = azurerm_resource_group.function_resource_group.location
    failover_priority = 0
  }
}

// Create a Cosmos DB SQL database
resource "azurerm_cosmosdb_sql_database" "crc_DB" {
  name                = "CRCDB" #this is predefined in the function package in function.json
  resource_group_name = azurerm_resource_group.function_resource_group.name
  account_name        = azurerm_cosmosdb_account.crc_cosmos_DB.name
}

// Create a Cosmos DB SQL container
// This container is used to store the data for the Azure Function.
resource "azurerm_cosmosdb_sql_container" "crc_container" {
  name                = "counter" #this is predefined in the function package in function.json
  resource_group_name = azurerm_resource_group.function_resource_group.name
  account_name        = azurerm_cosmosdb_account.crc_cosmos_DB.name
  database_name       = azurerm_cosmosdb_sql_database.crc_DB.name
  partition_key_paths = ["/id"] #this is predefined in the function package in function.json
  throughput          = 400
}
