### Create GKE cluster via resource ###
resource "google_container_cluster" "primary" {
  name     = var.cluster_name
  location = var.region
  project  = var.project_id
  remove_default_node_pool = true
  initial_node_count       = 1
  network    = google_compute_network.vpc.name
  subnetwork = google_compute_subnetwork.subnet.name
}

### Create (2) managed GKE node pools for test importing into Ocean ###
resource "google_container_node_pool" "node-pool-for-import-1" {
  name       = "node-pool-for-import-1"
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

    preemptible  = false
    machine_type = "e2-medium"
    tags         = ["network-tags"]
    metadata = {
      disable-legacy-endpoints = "true"
    }
  }
}

resource "google_container_node_pool" "node-pool-for-import-2" {
  name       = "node-pool-for-import-2"
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

    preemptible  = false
    machine_type = "e2-medium"
    tags         = ["network-tags"]
    metadata = {
      disable-legacy-endpoints = "true"
    }
  }
}

### Create a single GKE managed Node Pool for Ocean controller uptime during shutdown hours ###
resource "google_container_node_pool" "shutdown_node" {
  name       = "ocean-node-for-shutdown-hours"
  location   = var.region
  node_locations = [var.zone]
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

    preemptible  = false
    machine_type = "e2-small"
    tags         = ["ocean--shutdown-hours-node", "${var.project_id}-gke"]
    metadata = {
      disable-legacy-endpoints = "true"
    }
  }
}