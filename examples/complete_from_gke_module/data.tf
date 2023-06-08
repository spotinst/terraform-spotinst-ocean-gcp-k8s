### data resources ###
data "google_client_config" "default" {}

data "google_compute_image" "COS" {
  family  = "cos-stable"
  project = "gke-node-images"
}