#Providers config

terraform {
  required_providers {
    aviatrix = {
      source = "AviatrixSystems/aviatrix"
      #version = "2.22.1"
    }
    google = {
      source = "hashicorp/google"
    }
  }
}

provider "aviatrix" {}

provider "google" {
  project = var.gcp_account_name
}

data "aviatrix_account" "gcp" {
  account_name = var.gcp_account_name
}