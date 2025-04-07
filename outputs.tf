// Function app URL output. This needs to be updated in the HTML file to point to the function app URL.
// This URL will be used to access the function app from the web page
output "function_app_url" {
  value = azurerm_linux_function_app.crc_function_app.default_hostname
  sensitive = false
}

output "completion_message" {
  value = "Terraform execution has completed successfully! Please make sure to edit the .html file and include the correct URL for the function app."
}