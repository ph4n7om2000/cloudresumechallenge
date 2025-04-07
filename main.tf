terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      version = "4.22.0"
    }

    cloudflare = {
      source = "cloudflare/cloudflare"
      version = "5.1.0"
    }
  }

   backend "azurerm" {
    resource_group_name  = "configs"
    storage_account_name = "crcterraformtfstate"
    container_name       = "statefiles"
    key                  = "terraform.tfstate"
  }


}

// Define the providers and their required variables
// These variables will be passed from the .tfvars file
provider "azurerm" {
  features {}
}

provider "cloudflare" {

}
