terraform {
  required_version = ">= 1.9.0"

  required_providers {
    flux = {
      source  = "fluxcd/flux"
      version = ">= 1.5"
    }
    github = {
      source  = "integrations/github"
      version = ">= 6.1"
    }
    kind = {
      source  = "tehcyx/kind"
      version = ">= 0.8"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "2.17.0"
    }
  }
}
provider "flux" {
  kubernetes = {
    host                   = kind_cluster.this.endpoint
    client_certificate     = kind_cluster.this.client_certificate
    client_key             = kind_cluster.this.client_key
    cluster_ca_certificate = kind_cluster.this.cluster_ca_certificate
  }
  git = {
    url = "https://github.com/${var.github_org}/${var.github_repository}.git"
    http = {
      username = "git" # This can be any string when using a personal access token
      password = var.github_token
    }
  }
}

provider "github" {
  owner = var.github_org
  token = var.github_token
}

provider "kind" {}

provider "helm" {
  kubernetes {
    host                   = kind_cluster.this.endpoint
    client_certificate     = kind_cluster.this.client_certificate
    client_key             = kind_cluster.this.client_key
    cluster_ca_certificate = kind_cluster.this.cluster_ca_certificate
  }
}
