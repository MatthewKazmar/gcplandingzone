#Deploy Aviatrix Transit
#https://registry.terraform.io/modules/terraform-aviatrix-modules/mc-transit/aviatrix/latest

module "avx_transit" {
  source  = "terraform-aviatrix-modules/mc-transit/aviatrix"
  version = "2.1.5"

  cloud   = "gcp"
  region  = var.region
  cidr    = cidrsubnet(var.avx_cidr, 4, 0)
  account = var.gcp_account_name
  ha_gw   = false
}