terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 4.0"
    }
    spotinst = {
      source  = "spotinst/spotinst"
      version = "~> 1.117.0" 
    }
  }
}

provider "spotinst" {
  account = var.spotinst_account
  token   = var.spotinst_token
}

provider "google" {
  project     = var.project_id
  region      = var.region
  credentials = file("your_gcp_service_account_key.json")
}

provider "kubernetes" {
  host  = "https://${google_container_cluster.primary.endpoint}"
  token = data.google_client_config.default.access_token
  cluster_ca_certificate = base64decode(google_container_cluster.primary.master_auth[0].cluster_ca_certificate)
}