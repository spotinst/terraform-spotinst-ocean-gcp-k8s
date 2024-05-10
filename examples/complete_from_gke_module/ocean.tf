### Spot Ocean cluster creation ###
module "ocean-gcp-k8s" {
  source     = "spotinst/ocean-gcp-k8s/spotinst"

  cluster_name                      = var.cluster_name
  location                          = var.region
  use_as_template_only              = true
  shutdown_hours = {
    is_enabled = true
    time_windows = [ # Must be in GMT
      "Fri:23:30-Mon:13:30", # Weekends
      "Mon:23:30-Tue:13:30", # Weekday evenings
      "Tue:23:30-Wed:13:30",
      "Wed:23:30-Thu:13:30",
      "Thu:23:30-Fri:13:30",
    ]
  }
  tasks = [
    {
      is_enabled = true
      cron_expression =  "0 1 * * *"
      task_type = "clusterRoll"
      cluster_roll = [{
        batch_min_healthy_percentage = 100
        batch_size_percentage = 20
        comment =  "This is why I deployed my cluster."
        respect_pdb = true
      }]
    }
  ]
  
  depends_on = [google_container_cluster.primary]
}

### Deploy Ocean Controller pod into cluster ###
module "ocean-controller" {
  source     = "spotinst/ocean-controller/spotinst"
  depends_on = [module.ocean-gcp-k8s]

  # Credentials.
  spotinst_account = var.spotinst_account
  spotinst_token   = var.spotinst_token

  tolerations = []

  # Configuration.
  cluster_identifier = module.ocean-gcp-k8s.ocean_controller_id
}


locals {
  gke_node_pools_2_import = ["node-pool-for-import-1", "node-pool-for-import-2"] # List of GKE node pool names for import
}

### Example of creating a new VNG from an existing GKE node pools via module ###
module "ocean-gcp-k8s-vng" {
    source = "spotinst/ocean-gcp-k8s-vng/spotinst"

    for_each = toset(local.gke_node_pools_2_import)
    node_pool_name = each.key

    ocean_id            = module.ocean-gcp-k8s.ocean_id
    name                = each.key
    min_instance_count  = 1
    tags = {tag-added-after-import = ""}
    root_volume_type = "pd-standard"

    depends_on = [module.ocean-gcp-k8s,google_container_node_pool.node-pool-for-import-1,google_container_node_pool.node-pool-for-import-2]
}