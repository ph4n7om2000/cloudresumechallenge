// Create a CNAME record for the custom domain in Cloudflare

resource "cloudflare_dns_record" "cname_record" {
    zone_id = var.cloudflare_zone_id
    comment = "CNAME record for CRC"
    name = var.custom_domain
    content =  azurerm_cdn_frontdoor_endpoint.fd_endpoint.host_name // Gets the Front Door endpoint hostname. This value can also be taken from var.custom_domain
    proxied = false
    ttl = 3600
    type = "CNAME"

}

// Create a TXT record for domain verification in Cloudflare
// This record is used to verify the ownership of the custom domain with Azure Front Door.
resource "cloudflare_dns_record" "frontdoor_txt_record" {
    depends_on = [ azurerm_cdn_frontdoor_custom_domain.frontdoor_domain ]  
    zone_id = var.cloudflare_zone_id
    comment = "Domain verification record for CRC"
    content = azurerm_cdn_frontdoor_custom_domain.frontdoor_domain.validation_token
    name = join("", ["_dnsauth.", var.custom_domain])
    proxied = false
    ttl = 3600
    type = "TXT"
}