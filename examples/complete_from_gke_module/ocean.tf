### Spot Ocean cluster creation ###
module "ocean-gcp-k8s" {
  source     = "spotinst/ocean-gcp-k8s/spotinst"

  cluster_name                      = var.cluster_name
  location                          = var.region
  use_as_template_only              = true
  
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