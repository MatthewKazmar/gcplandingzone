#Variables

variable "region" { default = "us-central1" }
variable "gcp_account_name" { type = string } #account name in Aviatrix
variable "avx_cidr" { default = "10.100.0.0/24" }
variable "avx_spoke_prod_1_cidr" { default = "10.100.1.0/24" }
variable "avx_spoke_dev_1_cidr" { default = "10.100.2.0/24" }
variable "avx_spoke_prod_2_cidr" { default = "10.100.3.0/24" }

locals {
  gcp_project_id = data.aviatrix_account.gcp.gcloud_project_id
}