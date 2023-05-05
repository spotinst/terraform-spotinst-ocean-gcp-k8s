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

### Create a managed GKE Node Pool for test importing into Ocean ###
resource "google_container_node_pool" "primary_nodes" {
  name       = "node-pool-for-import"
  location   = var.region
  cluster    = google_container_cluster.primary.name
  node_count = 0
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
    tags         = ["tag-to-import"]
    metadata = {
      disable-legacy-endpoints = "true"
    }
  }
}

### Create a single managed GKE Node Pool for Ocean controller pod run during shutdown hours ###
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

### Spot Ocean ###
module "ocean-gcp-k8s" {
  source = "spotinst/ocean-gcp-k8s/spotinst"

  cluster_name                      = var.cluster_name
  location                          = var.region
  use_as_template_only              = true
  
  depends_on = [google_container_cluster.primary,google_container_node_pool.primary_nodes]
}

### Deploy Ocean Controller pod into cluster ###
module "ocean-controller" {
  source     = "spotinst/ocean-controller/spotinst"
  depends_on = [module.ocean-gcp-k8s]

  # Credentials.
  spotinst_account = var.spotinst_account
  spotinst_token   = var.spotinst_token

  # Configuration.
  cluster_identifier = module.ocean-gcp-k8s.ocean_controller_id
}

### Example of creating a new VNG from an existing GKE node pool via resource ###
resource "spotinst_ocean_gke_launch_spec" "vng_from_import" {
  ocean_id     = module.ocean-gcp-k8s.ocean_id
  node_pool_name  = "node-pool-for-import"
  name = "ocean-resource-imported-vng"
  source_image = data.google_compute_image.COS.self_link
  restrict_scale_down = false
  root_volume_size = 10
  root_volume_type = "pd-standard"
  instance_types = ["e2-medium"]

  shielded_instance_config {
    enable_secure_boot = false
    enable_integrity_monitoring = true
  }

  metadata {
    key   = "gci-update-strategy"
    value = "update_disabled"
  }

  labels {
    key   = "labelKey"
    value = "labelVal"
  }

  autoscale_headrooms_automatic {
    auto_headroom_percentage = 5
  }

  autoscale_headrooms {
    num_of_units = 5
    cpu_per_unit = 1000
    gpu_per_unit = 0
    memory_per_unit = 2048
  }

  strategy {
    preemptible_percentage = 30
  }

  scheduling_task {
    is_enabled = true
    cron_expression = "0 1 * * *"
    task_type = "manualHeadroomUpdate"
    task_headroom {
        num_of_units    = 5
        cpu_per_unit     = 1000
        gpu_per_unit    = 0
        memory_per_unit = 2048
    }
  }
  
  network_interfaces {
    network = google_compute_network.vpc.name
    project_id = var.project_id
    access_configs {
      name = "external-nat-vng"
      type     = "ONE_TO_ONE_NAT"
    }
    alias_ip_ranges {
      ip_cidr_range         = "/24"
      subnetwork_range_name = google_compute_subnetwork.subnet.name
    }
  }
  depends_on = [module.ocean-gcp-k8s,google_compute_subnetwork.subnet]
}

