// This Terraform code creates a static website on Azure using a storage account. The website serves a single HTML file, `resume.html`, which is uploaded to the `$web` container of the storage account. The code also includes the creation of a resource group and the storage account itself.

// Create frontend resource group
// This is where the static website will be hosted
resource "azurerm_resource_group" "crc_rg" {
  name     = var.frontend_resource_group_name
  location = var.location
}

// Create a storage account for the static website
resource "azurerm_storage_account" "storage_acc" {
  name                     = var.webpage_storage_account_name
  resource_group_name      = azurerm_resource_group.crc_rg.name
  location                 = azurerm_resource_group.crc_rg.location
  account_tier             = "Standard"
  account_replication_type = "GRS"
}

// Create a static website in the storage account
// This is where the HTML file will be served from
resource "azurerm_storage_account_static_website" "crc_website" {
  storage_account_id = azurerm_storage_account.storage_acc.id
  index_document     = "resume.html"
    
}
// Create a storage container for the static website
// This is where the HTML file will be stored
// Make sure content_type is set to text/html for HTML files. 
resource "azurerm_storage_blob" "crc_website_blob_container" {
  name                   = "resume.html"
  storage_account_name   = azurerm_storage_account.storage_acc.name
  storage_container_name = "$web"     
  type                   = "Block"
  source                 = "resume.html" 
  content_type           = "text/html"

  depends_on = [ azurerm_storage_account_static_website.crc_website] // This is to ensure that the blob container $web created before the blob is created

}