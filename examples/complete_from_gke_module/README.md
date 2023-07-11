<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 0.13.1 |
| <a name="requirement_spotinst"></a> [spotinst](#requirement\_spotinst) | ~> 1.117.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_google"></a> [google](#provider\_google) | 4.67.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_ocean-controller"></a> [ocean-controller](#module\_ocean-controller) | spotinst/ocean-controller/spotinst | n/a |
| <a name="module_ocean-gcp-k8s"></a> [ocean-gcp-k8s](#module\_ocean-gcp-k8s) | ../../ | n/a |
| <a name="module_ocean-gcp-k8s-vng"></a> [ocean-gcp-k8s-vng](#module\_ocean-gcp-k8s-vng) | ../../../terraform-spotinst-ocean-gcp-k8s-vng | n/a |

## Resources

| Name | Type |
|------|------|
| [google_compute_network.vpc](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_network) | resource |
| [google_compute_subnetwork.subnet](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_subnetwork) | resource |
| [google_container_cluster.primary](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/container_cluster) | resource |
| [google_container_node_pool.node-pool-for-import-1](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/container_node_pool) | resource |
| [google_container_node_pool.node-pool-for-import-2](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/container_node_pool) | resource |
| [google_container_node_pool.shutdown_node](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/container_node_pool) | resource |
| [google_client_config.default](https://registry.terraform.io/providers/hashicorp/google/latest/docs/data-sources/client_config) | data source |
| [google_compute_image.COS](https://registry.terraform.io/providers/hashicorp/google/latest/docs/data-sources/compute_image) | data source |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_ocean_controller_id"></a> [ocean\_controller\_id](#output\_ocean\_controller\_id) | n/a |
| <a name="output_ocean_id"></a> [ocean\_id](#output\_ocean\_id) | # Outputs ## |
<!-- END_TF_DOCS -->