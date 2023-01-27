terraform {
  required_providers {
    spotinst = {
      source = "spotinst/spotinst"
    }
  }
}

provider "google" {
  # Configuration options
  project = "sales-labs"
  region  = "us-west2"
}
provider "spotinst" {
  account = var.spotinst_account
  token   = var.spotinst_token
}
#initialize the kubernetes provider with access to the specific cluster
provider "kubernetes" {
  host                   = "https://${data.google_container_cluster.gke.endpoint}"
  token                  = data.google_client_config.default.access_token
  cluster_ca_certificate = base64decode(data.google_container_cluster.gke.master_auth[0].cluster_ca_certificate)
}