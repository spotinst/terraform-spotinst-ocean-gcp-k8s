### Variables ###
variable "cluster_name" {
  type        = string
  description = "(Required) The GKE cluster name."
}
variable "location" {
  type        = string
  description = "(Required) The zone the master cluster is located in."
}
variable "controller_cluster_id" {
  default     = null
  type        = string
  description = "A unique identifier used for connecting the Ocean SaaS platform and the Kubernetes cluster. Typically, the cluster name is used as its identifier."
}
variable "desired_capacity" {
  default     = 1
  type        = number
  description = "The number of instances to launch and maintain in the cluster."
}
variable "min_size" {
  default     = 0
  type        = number
  description = "The lower limit of instances the cluster can scale down to."
}
variable "max_size" {
  default     = 1000
  type        = number
  description = "The upper limit of instances the cluster can scale up to."
}
variable "whitelist" {
  default     = null
  type        = list(string)
  description = "Instance types allowed in the Ocean cluster."
}
variable "draining_timeout" {
  default     = 120
  type        = number
  description = "The draining timeout (in seconds) before terminating the instance."
}
variable "root_volume_type" {
  default     = "pd-standard"
  type        = string
  description = "The root volume disk type"
}
#################

## backend_service ##
variable "backend_service" {
  type = object({
    service_name  = string
    location_type = string
    scheme        = string
    port_name     = string
    ports         = list(number)
  })
  default     = null
  description = "Configures the backend service configurations"
}

#################

## shielded_instance_config ##
variable "enable_integrity_monitoring" {
  type        = bool
  default     = false
  description = "Enable the integrity monitoring parameter on the GCP instances."
}
variable "enable_secure_boot" {
  type        = bool
  default     = false
  description = "Enable the secure boot parameter on the GCP instances."
}
#################
variable "use_as_template_only" {
  type        = bool
  default     = false
  description = "(Optional, Default: false) launch specification defined on the Ocean object will function only as a template for virtual node groups."
}
###################
## Auto Scaler ##
variable "autoscale_is_enabled" {
  type        = bool
  default     = true
  description = "Enable the Ocean Kubernetes Auto Scaler."
}
variable "autoscale_is_auto_config" {
  type        = bool
  default     = true
  description = "Automatically configure and optimize headroom resources."
}
variable "auto_headroom_percentage" {
  type        = number
  default     = 5
  description = "Set the auto headroom percentage (a number in the range [0, 200]) which controls the percentage of headroom from the cluster."
}
variable "autoscale_cooldown" {
  type        = number
  default     = 300
  description = "Cooldown period between scaling actions."
}
variable "enable_automatic_and_manual_headroom" {
  type        = bool
  default     = false
  description = "enables automatic and manual headroom to work in parallel. When set to false, automatic headroom overrides all other headroom definitions manually configured, whether they are at cluster or VNG level."
}

## autoscale_headroom ##
variable "cpu_per_unit" {
  type        = number
  default     = 0
  description = "Optionally configure the number of CPUs to allocate the headroom. CPUs are denoted in millicores, where 1000 millicores = 1 vCPU."
}
variable "gpu_per_unit" {
  type        = number
  default     = 0
  description = "Optionally configure the number of GPUs to allocate the headroom."
}
variable "memory_per_unit" {
  type        = number
  default     = 0
  description = "Optionally configure the amount of memory (MB) to allocate the headroom."
}
variable "num_of_unit" {
  type        = number
  default     = 0
  description = "The number of units to retain as headroom, where each unit has the defined headroom CPU and memory."
}
## autoscale_down ##
variable "evaluation_periods" {
  type        = number
  default     = 10
  description = "The number of evaluation periods that should accumulate before a scale down action takes place."
}
variable "max_scale_down_percentage" {
  type        = number
  default     = null
  description = "Would represent the maximum % to scale-down. Number between 1-100."
}
## resource_limits ##
variable "max_vcpu" {
  type        = number
  default     = null
  description = "The maximum cpu in vCPU units that can be allocated to the cluster."
}
variable "max_memory_gib" {
  type        = number
  default     = null
  description = "The maximum memory in GiB units that can be allocated to the cluster."
}
##########################

## strategy ##
variable "provisioning_model" {
  type        = string
  default     = "SPOT"
  description = "Define the provisioning model of the launched instances. Valid values: SPOT, PREEMPTIBLE."
}
variable "preemptible_percentage" {
  type        = number
  default     = null
  description = "Defines the desired preemptible percentage for the cluster."
}
variable "should_utilize_commitments" {
  type        = bool
  default     = null
  description = "Enable committed use discounts utilization."
}
##########################

## update_policy ##
variable "should_roll" {
  type        = bool
  default     = false
  description = "Enables the roll."
}
variable "conditioned_roll" {
  type        = bool
  default     = false
  description = "Spot will perform a cluster Roll in accordance with a relevant modification of the cluster’s settings. When set to true , only specific changes in the cluster’s configuration will trigger a cluster roll (such as AMI, Key Pair, user data, instance types, load balancers, etc)"
}
variable "batch_size_percentage" {
  type        = number
  default     = 20
  description = "Sets the percentage of the instances to deploy in each batch."
}
variable "launch_spec_ids" {
  type        = list(string)
  default     = null
  description = "List of Virtual Node Group identifiers to be rolled."
}
variable "batch_min_healthy_percentage" {
  type        = number
  default     = 50
  description = "Indicates the threshold of minimum healthy instances in single batch. If the amount of healthy instances in single batch is under the threshold, the cluster roll will fail. If exists, the parameter value will be in range of 1-100. In case of null as value, the default value in the backend will be 50%. Value of param should represent the number in percentage (%) of the batch."
}
##########################

## shutdown_hours ##
variable "shutdown_hours" {
  type = object({
    is_enabled   = bool
    time_windows = list(string)
  })
  default     = null
  description = "shutdown_hours object"
}
# task scheduling #
variable "tasks" {
  type = list(object({
    is_enabled      = bool
    cron_expression = string
    task_type       = string
    cluster_roll = optional(set(object({
      batch_min_healthy_percentage = optional(number,null)
      batch_size_percentage = optional(number,null)
      comment = optional(string,null)
      respect_pdb = optional(bool,null)
    })), [])
  }))
  default     = null
  description = "task object"
}