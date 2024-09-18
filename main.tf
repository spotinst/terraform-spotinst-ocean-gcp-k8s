### Spot Ocean resource - Create the Ocean Cluster ###
resource "spotinst_ocean_gke_import" "ocean" {
  cluster_name          = var.cluster_name
  controller_cluster_id = var.controller_cluster_id == null ? var.cluster_name : var.controller_cluster_id
  location              = var.location
  desired_capacity      = var.desired_capacity
  min_size              = var.min_size
  max_size              = var.max_size
  whitelist             = var.whitelist
  root_volume_type      = var.root_volume_type

  dynamic "backend_services" {
    for_each = var.backend_service != null ? [var.backend_service] : []
    content {
      service_name  = backend_services.value.service_name
      location_type = backend_services.value.location_type
      scheme        = backend_services.value.scheme
      named_ports {
        name  = backend_services.value.name
        ports = backend_services.value.ports
      }
    }
  }

  shielded_instance_config {
    enable_integrity_monitoring = var.enable_integrity_monitoring
    enable_secure_boot          = var.enable_secure_boot
  }

  use_as_template_only = var.use_as_template_only

  autoscaler {
    is_enabled                           = var.autoscale_is_enabled
    is_auto_config                       = var.autoscale_is_auto_config
    auto_headroom_percentage             = var.auto_headroom_percentage
    cooldown                             = var.autoscale_cooldown
    enable_automatic_and_manual_headroom = var.enable_automatic_and_manual_headroom
    headroom {
      cpu_per_unit    = var.cpu_per_unit
      memory_per_unit = var.memory_per_unit
      gpu_per_unit    = var.gpu_per_unit
      num_of_units    = var.num_of_unit
    }
    down {
      evaluation_periods        = var.evaluation_periods
      max_scale_down_percentage = var.max_scale_down_percentage
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
    provisioning_model         = var.provisioning_model
    preemptible_percentage     = var.preemptible_percentage
    draining_timeout           = var.draining_timeout
    should_utilize_commitments = var.should_utilize_commitments
  }

  update_policy {
    should_roll      = var.should_roll
    conditioned_roll = var.conditioned_roll
    roll_config {
      batch_size_percentage        = var.batch_size_percentage
      launch_spec_ids              = var.launch_spec_ids
      batch_min_healthy_percentage = var.batch_min_healthy_percentage
    }
  }

  scheduled_task {
    dynamic "shutdown_hours" {
      for_each = var.shutdown_hours != null ? [var.shutdown_hours] : []
      content {
        is_enabled   = shutdown_hours.value.is_enabled
        time_windows = shutdown_hours.value.time_windows
      }
    }
    dynamic "tasks" {
      for_each = var.tasks != null ? var.tasks : []
      content {
        is_enabled      = tasks.value.is_enabled
        cron_expression = tasks.value.cron_expression
        task_type       = tasks.value.task_type
        task_parameters {
          dynamic "cluster_roll" {
            for_each = tasks.value.cluster_roll
            content {
              batch_min_healthy_percentage = cluster_roll.value.batch_min_healthy_percentage
              batch_size_percentage        = cluster_roll.value.batch_size_percentage
              comment                      = cluster_roll.value.comment
              respect_pdb                  = cluster_roll.value.respect_pdb
            }
          }
        }
      }
    }
  }
  lifecycle {
    ignore_changes = [
      desired_capacity
    ]
  }

}



