terraform {
  required_providers {
    spotinst = {
      source = "spotinst/spotinst"
    }
    restapi = {
      source = "mastercard/restapi"
    }
  }
}

provider "google" {
  # Configuration options
  project = "sales-labs"
  region = "us-west2"
}
provider "spotinst" {
  account = var.spotinst_account
  token   = var.spotinst_token
}
#initialize the kubernetes provider with access to the specific cluster
provider "kubernetes" {
  host  = "https://${data.google_container_cluster.gke.endpoint}"
  token = data.google_client_config.default.access_token
  cluster_ca_certificate = base64decode(data.google_container_cluster.gke.master_auth[0].cluster_ca_certificate)
}

### data resources ###
data "google_client_config" "default" {}

#Retrieve cluster info to get certificate
data "google_container_cluster" "gke" {
  name     = var.cluster_name
  location = var.location
}
#Data source to pull most recent COS image URI
data "google_compute_image" "COS" {
  family  = "cos-stable"
  project = "gke-node-images"
}


### Spot Ocean resource - Create the Ocean Cluster ###
module "ocean-gcp-k8s" {
  source = "../"

  cluster_name                      = var.cluster_name
  location                          = var.location
  spotinst_account                  = var.spotinst_account
  spotinst_token                    = var.spotinst_token
  enable_programmatic_user_creation = true
  enable_integrity_monitoring       = true
  enable_secure_boot                = false
}

### Deploy Ocean Controller Pod into Cluster ###
module "ocean-controller" {
  source = "spotinst/ocean-controller/spotinst"
  depends_on = [module.ocean-gcp-k8s]

  # Credentials.
  spotinst_account    = var.spotinst_account
  spotinst_token      = module.ocean-gcp-k8s.programmatic_user_token

  # Configuration.
  cluster_identifier  = module.ocean-gcp-k8s.ocean_cluster_id
}

output "ocean_id" {
  value = module.ocean-gcp-k8s.ocean_id
}

