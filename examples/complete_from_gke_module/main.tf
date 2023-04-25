# GKE cluster
resource "google_container_cluster" "primary" {
  name     = var.cluster_name
  location = var.region
  project  = var.project_id
  remove_default_node_pool = true
  initial_node_count       = 1
  network    = google_compute_network.vpc.name
  subnetwork = google_compute_subnetwork.subnet.name
}

# Managed Node Pool
resource "google_container_node_pool" "primary_nodes" {
  name       = google_container_cluster.primary.name
  location   = var.region
  cluster    = google_container_cluster.primary.name
  node_count = 1
  project    = var.project_id

  node_config {
    oauth_scopes = [
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring",
    ]

    labels = {
      env = var.project_id
    }

    preemptible  = true
    machine_type = "n1-standard-1"
    tags         = ["gke-node", "${var.project_id}-gke"]
    metadata = {
      disable-legacy-endpoints = "true"
    }
  }
}

### Spot Ocean 
module "ocean-gcp-k8s" {
  source = "spotinst/ocean-gcp-k8s/spotinst"

  cluster_name                      = var.cluster_name
  location                          = var.region
  use_as_template_only              = true
  
  depends_on = [google_container_cluster.primary,google_container_node_pool.primary_nodes]
}

### Deploy Ocean Controller Pod into Cluster ###
module "ocean-controller" {
  source     = "spotinst/ocean-controller/spotinst"
  depends_on = [module.ocean-gcp-k8s]

  # Credentials.
  spotinst_account = var.spotinst_account
  spotinst_token   = var.spotinst_token

  # Configuration.
  cluster_identifier = module.ocean-gcp-k8s.ocean_controller_id
  tolerations = []
}

module "ocean-gcp-k8s-vng" {
    source = "spotinst/ocean-gcp-k8s-vng/spotinst"
    ocean_id            = module.ocean-gcp-k8s.ocean_id
    node_pool_name      = var.cluster_name
    min_instance_count  = 1
    root_volume_type = "pd-ssd"
    depends_on = [google_compute_subnetwork.subnet]
  }