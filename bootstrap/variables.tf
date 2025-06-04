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
  default     = "CHANGE_ME"
}

variable "cluster_name" {
  description = "Cluster Name"
  type        = string
  default     = "preview"
}
