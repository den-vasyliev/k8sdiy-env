# ==========================================
# Construct GKE cluster
# ==========================================
provider "google" {
  # Configuration options
  project = var.GOOGLE_PROJECT
  region  = var.GOOGLE_REGION
}

resource "google_container_cluster" "this" {
  count    = var.kind_enabled ? 0 : 1
  name     = var.GKE_CLUSTER_NAME
  location = var.GOOGLE_REGION

  initial_node_count       = 2
  remove_default_node_pool = true

  workload_identity_config {
    workload_pool = "${var.GOOGLE_PROJECT}.svc.id.goog"
  }
  node_config {
    workload_metadata_config {
      mode = "GKE_METADATA"
    }
  }
}

resource "google_container_node_pool" "this" {
  count      = var.kind_enabled ? 0 : 1
  name       = var.GKE_POOL_NAME
  project    = google_container_cluster.this[0].project
  cluster    = google_container_cluster.this[0].name
  location   = google_container_cluster.this[0].location
  node_count = var.GKE_NUM_NODES

  node_config {
    preemptible  = false
    machine_type = var.GKE_MACHINE_TYPE
    disk_type    = "pd-standard"
  }
}

module "gke_auth" {
  depends_on = [
    google_container_cluster.this
  ]
  source       = "terraform-google-modules/kubernetes-engine/google//modules/auth"
  version      = ">= 24.0.0"
  project_id   = var.GOOGLE_PROJECT
  cluster_name = google_container_cluster.this[0].name
  location     = var.GOOGLE_REGION
}

data "google_client_config" "current" {}

data "google_container_cluster" "main" {
  name     = google_container_cluster.this[0].name
  location = var.GOOGLE_REGION
}
