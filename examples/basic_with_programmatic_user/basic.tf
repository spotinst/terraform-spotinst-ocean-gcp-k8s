### Spot Ocean resource - Create the Ocean Cluster ###
module "ocean-gcp-k8s" {
  source = "spotinst/ocean-gcp-k8s/spotinst"

  cluster_name                      = var.cluster_name
  location                          = var.location
}

#create programmatic user
resource "restapi_object" "programmatic_user" {
  path         = "/setup/user/programmatic"
  create_path  = "/setup/user/programmatic"
  destroy_path = "/setup/user/{id}"
  update_path  = "/setup/user/programmatic/{id}"
  read_path    = "/setup/user/programmatic/{id}"
  id_attribute = "response/items/0/id"
  data = jsonencode(
    {
      "name" : "${var.cluster_name}",
      "description" : "Programmatic User for ${var.cluster_name}",
      "accounts" : [
        {
          "id" : "${var.spotinst_account}",
          "role" : "viewer"
        }
      ]
    }
  )
}

### Deploy Ocean Controller Pod into Cluster ###
module "ocean-controller" {
  source     = "spotinst/ocean-controller/spotinst"
  depends_on = [module.ocean-gcp-k8s]

  # Credentials.
  spotinst_account = var.spotinst_account
  spotinst_token   = jsondecode(restapi_object.programmatic_user[0].create_response).response.items.0.token

  # Configuration.
  cluster_identifier = module.ocean-gcp-k8s.ocean_controller_id
  tolerations = []
}



