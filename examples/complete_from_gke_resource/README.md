<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 0.13.1 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_gcp"></a> [gcp](#provider\_gcp) | n/a |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_ocean-gcp-k8s"></a> [ocean-gcp-k8s](#module\_ocean-gcp-k8s) | spotinst/ocean-gcp-k8s/spotinst | n/a |
| <a name="module_ocean-controller"></a> [ocean-controller](#module\_ocean-controller) | spotinst/ocean-controller/spotinst | n/a |

## Resources

| Name | Type |
|------|------|
| [google_container_cluster](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/container_cluster) | data source |
| [google_container_node_pool](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/container_node_pool) | data source |
| [google_compute_network](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_network) | data source |
| [google_compute_subnetwork](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_subnetwork) | data source |

## Inputs

No inputs.

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_ocean_id"></a> [ocean\_id](#output\_ocean\_id) | Ocean ID |
| <a name="ocean_controller_id"></a> [ocean\_controller\_id](#output\_worker\_instance\_profile\_arn) | Ocean Controller ID |
<!-- END_TF_DOCS -->