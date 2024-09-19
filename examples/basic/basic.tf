### Spot Ocean resource - Create the Ocean Cluster ###
module "ocean-gcp-k8s" {
  source = "spotinst/ocean-gcp-k8s/spotinst"

  cluster_name = var.cluster_name
  location     = var.location
}

### Deploy Ocean Controller Pod into Cluster ###
module "ocean-controller" {
  source     = "spotinst/ocean-controller/spotinst"
  depends_on = [module.ocean-gcp-k8s]

  # Credentials.
  spotinst_account           = var.spotinst_account
  spotinst_token             = var.spotinst_token


  # Configuration.
  cluster_identifier = module.ocean-gcp-k8s.ocean_controller_id
  tolerations        = []
}



