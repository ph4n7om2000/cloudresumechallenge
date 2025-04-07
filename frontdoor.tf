// Create a Front Door profile
resource "azurerm_cdn_frontdoor_profile" "frontdoor_profile" {
  name                = "crc-frontdoor-profile"
  resource_group_name = azurerm_resource_group.crc_rg.name
  sku_name            = "Standard_AzureFrontDoor"

}

// Create a Front Door endpoint
resource "azurerm_cdn_frontdoor_endpoint" "fd_endpoint" {
  name                     = "crc-frontdoor-endpoint"
  cdn_frontdoor_profile_id = azurerm_cdn_frontdoor_profile.frontdoor_profile.id
}

// Create a Front Door rule set
resource "azurerm_cdn_frontdoor_rule_set" "rule_set" {
  name                     = "crcfrontdoorruleset"
  cdn_frontdoor_profile_id = azurerm_cdn_frontdoor_profile.frontdoor_profile.id
}

// Create a Front Door rule
resource "azurerm_cdn_frontdoor_origin_group" "origin_group" {
  name                     = "crc-frontdoor-origin-group"
  cdn_frontdoor_profile_id = azurerm_cdn_frontdoor_profile.frontdoor_profile.id
  load_balancing {

  }
 
}

// Create a Front Door origin
//This origin is used to point the Front Door to the static website hosted in the Azure Storage Account.
resource "azurerm_cdn_frontdoor_origin" "origin_host" {
  depends_on                      = [ azurerm_storage_blob.crc_website_blob_container ]
  name                            = "crc-frontdoor-origin-host"
  cdn_frontdoor_origin_group_id   = azurerm_cdn_frontdoor_origin_group.origin_group.id
  enabled                         = true
  origin_host_header              = azurerm_storage_account.storage_acc.primary_web_host
  host_name                       = azurerm_storage_account.storage_acc.primary_web_host
  certificate_name_check_enabled  = false
}

// Create a Front Door route
// This route is used to route the traffic from the Front Door to the origin group.
resource "azurerm_cdn_frontdoor_route" "default_route" {
  name                          = "crc-frontdoor-default-route"
  cdn_frontdoor_endpoint_id     = azurerm_cdn_frontdoor_endpoint.fd_endpoint.id
  cdn_frontdoor_origin_group_id = azurerm_cdn_frontdoor_origin_group.origin_group.id
  cdn_frontdoor_origin_ids      = [azurerm_cdn_frontdoor_origin.origin_host.id]
  cdn_frontdoor_rule_set_ids    = [azurerm_cdn_frontdoor_rule_set.rule_set.id]
  enabled                       = true
  forwarding_protocol    = "HttpsOnly"
  https_redirect_enabled = true
  patterns_to_match      = ["/*"]
  supported_protocols    = ["Http", "Https"]

  cdn_frontdoor_custom_domain_ids = [azurerm_cdn_frontdoor_custom_domain.frontdoor_domain.id]
  link_to_default_domain          = false
}

// Create a Front Door custom domain
// This domain is used to point the Front Door to the custom domain.
resource "azurerm_cdn_frontdoor_custom_domain" "frontdoor_domain" {
  name                     = "crc-frontdoor-custom-domain"
  cdn_frontdoor_profile_id = azurerm_cdn_frontdoor_profile.frontdoor_profile.id
  host_name                = var.custom_domain
  
  tls {
    certificate_type    = "ManagedCertificate"
   
    
  }
}

// Create a Front Door custom domain association
// This association is used to associate the custom domain with the Front Door route.
resource "azurerm_cdn_frontdoor_custom_domain_association" "frontdoor_domain_association" {
  cdn_frontdoor_custom_domain_id = azurerm_cdn_frontdoor_custom_domain.frontdoor_domain.id
  cdn_frontdoor_route_ids          = [ azurerm_cdn_frontdoor_route.default_route.id ]
  
}