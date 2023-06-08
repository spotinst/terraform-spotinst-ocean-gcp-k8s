
provider "spotinst" {
  account = var.spotinst_account
  token   = var.spotinst_token
  version = "~> 1.117.0"  
}

provider "google" {
  project     = var.project_id
  region      = var.region
  credentials = file("sales-labs-5513b8063937.json")
}

provider "kubernetes" {
  host  = "https://${google_container_cluster.primary.endpoint}"
  token = data.google_client_config.default.access_token
  cluster_ca_certificate = base64decode(google_container_cluster.primary.master_auth[0].cluster_ca_certificate)
}