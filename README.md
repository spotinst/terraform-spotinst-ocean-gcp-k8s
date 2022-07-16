# terraform-spotinst-ocean-gcp-k8s
Terraform module for Spotinst provider resource spotinst_ocean_gke_import

## Prerequisites

Installation of the Ocean controller is required by this resource. You can accomplish this by using the [spotinst/ocean-controller](https://registry.terraform.io/modules/spotinst/ocean-controller/spotinst) module. The kubernetes provider will need to be initilaized before calling the ocean-controller module as follows:

```hcl
module "ocean-gcp-k8s" {
  source  = "spotinst/ocean-gcp-k8s"
  ...
}

## Option 1 to initialize kubernetes provider ##
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

## Option 2 to initialize kubernetes provider ##
provider "kubernetes" {
  config_path = "~/.kube/config"
}
##################

module "ocean-controller" {
  source = "spotinst/ocean-controller/spotinst"

  # Credentials.
  spotinst_account    = var.spotinst_account
  spotinst_token      = module.ocean-gcp-k8s.programmatic_user_token

  # Configuration.
  cluster_identifier  = module.ocean-gcp-k8s.ocean_cluster_id
}
```

~> You must configure the same `cluster_identifier` both for the Ocean controller and for the `spotinst_ocean_gke_import` resource.

## Usage
```hcl
module "ocean-gcp-k8s" {
  source = "spotinst/ocean-gcp-k8s/spotinst"

  # Credentials.
  spotinst_token                    = var.spot_token
  spotinst_account                  = var.spot_account
  enable_programmatic_user_creation = true

  cluster_name                      = var.cluster_name
  location                          = var.location
  
}
```

## Providers

| Name | Version |
|------|---------|
| spotinst/spotinst | >= 1.39.0 |
| hashicorp/gcp |  |
| mastercard/restapi |  |

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