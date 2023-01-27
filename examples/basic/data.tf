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