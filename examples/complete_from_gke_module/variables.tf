### Variables ###

variable "spotinst_account" {
  type = string
  default = "insert_spot_acct"
  description = "(Required) The Spot.io account ID."
}

/* admin token */
variable "spotinst_token" {
  type = string
  default = "insert_token"
  description = "(Required) The Spot.io API token."
}

variable "cluster_name" {
  type = string
  default = "test-gcp-cluster"
  description = "(Required) The GKE cluster name."
}

variable "region" {
  type = string
  default = "us-east1"
  description = "(Required) GCP Region for provisioning resources."
}

variable "project_id" {
  type = string
  default = ""
  description = "(Required) GCP project text ID."
}