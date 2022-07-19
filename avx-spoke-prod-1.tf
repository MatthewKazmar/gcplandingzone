#Create Aviatrix Spoke
#https://registry.terraform.io/modules/terraform-aviatrix-modules/mc-spoke/aviatrix/latest

module "avx_spoke_prod_1_vpc" {
  source = "terraform-google-modules/network/google"
  #version = "~> 4.0"

  project_id   = local.gcp_project_id
  network_name = "avx-spoke-prod-1-vpc"
  routing_mode = "GLOBAL"

  subnets = [
    {
      subnet_name   = "avx-spoke-prod-1-gw"
      subnet_ip     = cidrsubnet(var.avx_cidr, 4, 1)
      subnet_region = var.region
    },
    {
      subnet_name   = "avx-spoke-prod-1-vm"
      subnet_ip     = var.avx_spoke_prod_1_cidr
      subnet_region = var.region
    }
  ]
}

module "avx_spoke_prod_1_gw" {
  source  = "terraform-aviatrix-modules/mc-spoke/aviatrix"
  version = "1.2.4"

  cloud            = "gcp"
  name             = "avx-spoke-prod-1"
  region           = var.region
  account          = var.gcp_account_name
  transit_gw       = module.avx_transit.transit_gateway.gw_name
  attached         = true
  ha_gw            = false
  vpc_id           = module.avx_spoke_prod_1_vpc.network_name
  gw_subnet        = module.avx_spoke_prod_1_vpc.subnets_ips[0]
  use_existing_vpc = true

  depends_on = [
    module.avx_transit, module.avx_spoke_prod_1_vpc
  ]
}

#Enable SSH via Cloud IAP
resource "google_compute_firewall" "avx_spoke_prod_1_sshiap" {
  count   = 1
  name    = "avx-spoke-prod-1-sshiap"
  network = module.avx_spoke_prod_1_vpc.network_name

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = ["35.235.240.0/20"]

  target_tags = ["sshiap"]

  depends_on = [
    module.avx_spoke_prod_1_vpc
  ]

}

#InterVPC communication
resource "google_compute_firewall" "avx_spoke_prod_1_intervpc" {
  count   = 1
  name    = "avx-spoke-prod-1-intervpc"
  network = module.avx_spoke_dev_1_vpc.network_name

  allow {
    protocol = "all"
  }

  source_ranges = ["10.100.0.0/16"]

  depends_on = [
    module.avx_spoke_prod_1_vpc
  ]

}

#Deploy test VM
resource "google_compute_instance" "avx_spoke_prod_1_testvm" {

  name         = "avx-spoke-prod-1-testvm"
  machine_type = "e2-micro"
  zone         = "${var.region}-c"
  tags         = ["sshiap"]

  boot_disk {
    initialize_params {
      image = "ubuntu-os-cloud/ubuntu-2204-lts"
    }
  }

  network_interface {
    subnetwork = module.avx_spoke_prod_1_vpc.subnets_ids[1]
    access_config {} #generates ephemeral IP
  }

  depends_on = [
    module.avx_spoke_prod_1_vpc
  ]
}