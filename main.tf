### Spot Ocean resource - Create the Ocean Cluster ###
resource "spotinst_ocean_gke_import" "ocean" {
  cluster_name            = var.cluster_name
  controller_cluster_id   = var.controller_cluster_id
  location                = var.location
  desired_capacity        = var.desired_capacity
  min_size                = var.min_size
  max_size                = var.max_size
  whitelist               = var.whitelist
  root_volume_type        = var.root_volume_type

  dynamic "backend_services" {
    for_each = var.backend_service != null ? [var.backend_service] : []
    content {
      service_name    = backend_services.value.service_name
      location_type   = backend_services.value.location_type
      scheme          = backend_services.value.scheme
      named_ports {
        name          = backend_services.value.name
        ports         = backend_services.value.ports
      }
    }
  }

  shielded_instance_config {
    enable_integrity_monitoring           = var.enable_integrity_monitoring
    enable_secure_boot                    = var.enable_secure_boot
  }

  autoscaler {
    is_enabled                            = var.autoscale_is_enabled
    is_auto_config                        = var.autoscale_is_auto_config
    auto_headroom_percentage              = var.auto_headroom_percentage
    cooldown                              = var.autoscale_cooldown
    enable_automatic_and_manual_headroom  = var.enable_automatic_and_manual_headroom
    headroom {
      cpu_per_unit                        = var.cpu_per_unit
      memory_per_unit                     = var.memory_per_unit
      gpu_per_unit                        = var.gpu_per_unit
      num_of_units                        = var.num_of_unit
    }
    down {
      evaluation_periods                  = var.evaluation_periods
      max_scale_down_percentage           = var.max_scale_down_percentage
    }
    dynamic "resource_limits" {
      for_each = (
      var.max_vcpu != null &&
      var.max_memory_gib != null
      ) ? [1] : []
      content {
        max_vcpu       = var.max_vcpu
        max_memory_gib = var.max_memory_gib
      }
    }
  }


  strategy {
    provisioning_model                    = var.provisioning_model
    preemptible_percentage                = var.preemptible_percentage
    draining_timeout                      = var.draining_timeout
  }

  update_policy {
    should_roll                           = var.should_roll
    conditioned_roll                      = var.conditioned_roll
    roll_config {
      batch_size_percentage               = var.batch_size_percentage
      launch_spec_ids                     = var.launch_spec_ids
      batch_min_healthy_percentage        = var.batch_min_healthy_percentage
    }
  }

  lifecycle {
    ignore_changes = [
      desired_capacity
    ]
  }

}

# Create a random string
resource "random_id" "random_string" {
  byte_length = 8
}
locals {
  programmatic_name = format("%s/%s",var.cluster_name,random_id.random_string.id)
}

resource "restapi_object" "programmatic_user" {
  count = var.enable_programmatic_user_creation == true ? 1 : 0
  path         = "/setup/user/programmatic"
  create_path  = "/setup/user/programmatic"
  destroy_path = "/setup/user/{id}"
  update_path  = "/setup/user/programmatic/{id}"
  read_path    = "/setup/user/programmatic/{id}"
  id_attribute = "response/items/0/id"
  data         = jsonencode(
                  {
                    "name": "${local.programmatic_name}",
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



