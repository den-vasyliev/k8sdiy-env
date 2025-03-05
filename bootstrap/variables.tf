variable "kind_enabled" {
  description = "value to enable or disable kind cluster"
  type        = bool
  default     = true
}

variable "GOOGLE_PROJECT" {
  description = "GCP project"
  type        = string
  default     = "k8s-k3s"
}

variable "GOOGLE_REGION" {
  description = "GCP region"
  type        = string
  default     = "us-central1-a"
}

variable "GKE_CLUSTER_NAME" {
  description = "GKE cluster name"
  type        = string
  default     = "preview-0"
}

variable "GKE_POOL_NAME" {
  description = "GKE pool name"
  type        = string
  default     = "flux-preview-pool"
}

variable "GKE_NUM_NODES" {
  description = "GKE number of nodes"
  type        = number
  default     = 1
}

variable "GKE_MACHINE_TYPE" {
  description = "GKE machine type"
  type        = string
  default     = "e2-standard-2"
}
variable "gke_enabled" {
  description = "value to enable or disable gke cluster"
  type        = bool
  default     = false
}
variable "gke_location" {
  description = "GKE location"
  type        = string
  default     = "us-central1-a"

}
variable "gcp_project" {
  description = "GCP project"
  type        = string
  default     = "flux-preview"
}

variable "github_org" {
  description = "GitHub organization"
  type        = string
  default     = "den-vasyliev"
}

variable "github_repository" {
  description = "GitHub repository"
  type        = string
  default     = "flux-preview"
}

variable "github_token" {
  description = "GitHub token"
  sensitive   = true
  type        = string
  default     = null
}
variable "cluster_name" {
  description = "Cluster Name"
  type        = string
  default     = "flux-preview"
}