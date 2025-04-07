resource "azurerm_cdn_frontdoor_firewall_policy" "frontdoor_waf_policy" {
  name                              = "FrontdoorWAFPolicy"
  resource_group_name               = azurerm_resource_group.crc_rg.name
  sku_name                          = azurerm_cdn_frontdoor_profile.frontdoor_profile.sku_name
  enabled                           = true
  mode                              = "Prevention"
  custom_block_response_status_code = 403
  custom_block_response_body        = "PGh0bWw+CjxoZWFkZXI+PHRpdGxlPkhlbGxvPC90aXRsZT48L2hlYWRlcj4KPGJvZHk+CkhlbGxvIHdvcmxkCjwvYm9keT4KPC9odG1sPg=="

  custom_rule {
    name                           = "OnlyAllowUK"
    enabled                        = true
    priority                       = 1
    type                           = "MatchRule"
    action                         = "Allow"

    match_condition {
      match_variable     = "RemoteAddr"
      operator           = "GeoMatch"
      match_values       = ["GB"]
    }
  }
  
  }

resource "azurerm_cdn_frontdoor_security_policy" "frontdoor_waf_policy_association" {
  name                     = "FrontdoorWAFAssociation"
  cdn_frontdoor_profile_id = azurerm_cdn_frontdoor_profile.frontdoor_profile.id

  security_policies {
    firewall {
      cdn_frontdoor_firewall_policy_id = azurerm_cdn_frontdoor_firewall_policy.frontdoor_waf_policy.id

      association {
        domain {
          cdn_frontdoor_domain_id = azurerm_cdn_frontdoor_custom_domain.frontdoor_domain.id
        }
        patterns_to_match = ["/*"]
      }
    }
  }
}

  