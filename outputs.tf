output "ocean_id" {
  value = spotinst_ocean_gke_import.ocean.id
}

output "ocean_cluster_id" {
  value = spotinst_ocean_gke_import.ocean.controller_cluster_id
}

output "programmatic_user_token" {
  value       = jsondecode(restapi_object.programmatic_user[0].create_response).response.items.0.token
  description = "Programmatic user token for use with the Spotinst controller pod"
  sensitive   = true
}