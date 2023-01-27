# terraform-spotinst-ocean-gcp-k8s
Terraform module for Spotinst provider resource spotinst_ocean_gke_import

## Prerequisites

Installation of the Ocean controller is required by this resource. You can accomplish this by using the [spotinst/ocean-controller](https://registry.terraform.io/modules/spotinst/ocean-controller/spotinst) module. The kubernetes provider will need to be initilaized before calling the ocean-controller module as follows:

```hcl
module "ocean-gcp-k8s" {
  source  = "spotinst/ocean-gcp-k8s"
  ...
}

# Data Resources for kubernetes provider
#initialize the kubernetes provider with access to the specific cluster
provider "kubernetes" {
  host  = "https://${data.google_container_cluster.gke.endpoint}"
  token = data.google_client_config.default.access_token
  cluster_ca_certificate = base64decode(data.google_container_cluster.gke.master_auth[0].cluster_ca_certificate)
}

### data resources ###
data "google_client_config" "default" {}

#Retrieve cluster info to get instance group URLS
data "google_container_cluster" "gke" {
  name     = var.cluster_name
  location = var.location
}
##################

module "ocean-controller" {
  source = "spotinst/ocean-controller/spotinst"

  # Credentials.
  spotinst_account    = var.spotinst_account
  spotinst_token      = var.spotinst_token

  # Configuration.
  cluster_identifier  = module.ocean-gcp-k8s.ocean_controller_id
  tolerations = []
}
```
~> You must configure the same `cluster_identifier` both for the Ocean controller and for the `spotinst_ocean_gke_import` resource.

## Usage
```hcl
## (Optional) Add provider for the programmatic user creation
provider "restapi" {
  uri                  = "https://api.spotinst.io"
  write_returns_object = true

  headers = {
    "Authorization": "Bearer ${var.spotinst_token}"
    "Content-Type" = "application/json"
  }
}
# (Optional) Create the programmatic user within Spot and return the token
resource "restapi_object" "programmatic_user" {
  path         = "/setup/user/programmatic"
  create_path  = "/setup/user/programmatic"
  destroy_path = "/setup/user/{id}"
  update_path  = "/setup/user/programmatic/{id}"
  read_path    = "/setup/user/programmatic/{id}"
  id_attribute = "response/items/0/id"
  data         = jsonencode(
    {
      "name": "${var.cluster_name}",
      "description": "Programmatic User for ${var.cluster_name}",
      "accounts": [
        {
          "id": "${var.spotinst_account}",
          "role": "viewer"
        }
      ]
    }
  )
}

#Create Ocean
module "ocean-gcp-k8s" {
  source = "spotinst/ocean-gcp-k8s/spotinst"

  # Credentials.
  cluster_name                      = var.cluster_name
  location                          = var.location
  
}
```

## Providers

| Name | Version   |
|------|-----------|
| spotinst/spotinst | >= 1.96.0 |
| hashicorp/gcp |           |

## Modules
* `ocean-gcp-k8s` - Creates Ocean Cluster 
* `ocean-gcp-k8s-vng` - (Optional) Add custom virtual node groups with custom configs [Doc](https://registry.terraform.io/modules/spotinst/ocean-gcp-k8s-vng/spotinst/latest)
* `ocean-controller` - Create and installs Spot Ocean controller pod [Doc](https://registry.terraform.io/modules/spotinst/ocean-controller/spotinst/latest)


## Documentation

If you're new to [Spot](https://spot.io/) and want to get started, please checkout our [Getting Started](https://docs.spot.io/connect-your-cloud-provider/) guide, available on the [Spot Documentation](https://docs.spot.io/) website.

## Getting Help

We use GitHub issues for tracking bugs and feature requests. Please use these community resources for getting help:

- Ask a question on [Stack Overflow](https://stackoverflow.com/) and tag it with [terraform-spotinst](https://stackoverflow.com/questions/tagged/terraform-spotinst/).
- Join our [Spot](https://spot.io/) community on [Slack](http://slack.spot.io/).
- Open an issue.

## Community

- [Slack](http://slack.spot.io/)
- [Twitter](https://twitter.com/spot_hq/)

## Contributing

Please see the [contribution guidelines](CONTRIBUTING.md).