# ==========================================
# Construct KinD cluster
# ==========================================
resource "kind_cluster" "this" {
  name           = var.cluster_name
  wait_for_ready = true
}

# ==========================================
# Initialise a Github project
# ==========================================
resource "github_repository" "this" {
  count = 0
  name        = var.github_repository
  description = var.github_repository
  visibility  = "private"
  auto_init   = true # This is extremely important as flux_bootstrap_git will not work without a repository that has been initialised

  # Enable vulnerability alerts
  vulnerability_alerts = true
}

# ==========================================
# Bootstrap Flux Operator
# ==========================================
resource "helm_release" "flux_operator" {
  depends_on       = [kind_cluster.this]
  name             = "flux-operator"
  namespace        = "flux-system"
  repository       = "oci://ghcr.io/controlplaneio-fluxcd/charts"
  chart            = "flux-operator"
  create_namespace = true
}

# ==========================================
# Bootstrap Flux Instance
# ==========================================
resource "helm_release" "flux_instance" {
  depends_on = [helm_release.flux_operator]

  name       = "flux"
  namespace  = "flux-system"
  repository = "oci://ghcr.io/controlplaneio-fluxcd/charts"
  chart      = "flux-instance"
}

# ==========================================
# Bootstrap Envoy Gateway
# ==========================================
resource "helm_release" "envoy_gateway" {
  depends_on       = [kind_cluster.this]
  name             = "eg"
  namespace        = "envoy-gateway-system"
  repository       = "oci://docker.io/envoyproxy"
  chart            = "gateway-helm"
  create_namespace = true
}

# ==========================================
# Bootstrap Kbot Application
# ==========================================
resource "helm_release" "kbot_app" {
  depends_on = [helm_release.envoy_gateway]
  name       = "kbot"
  namespace  = "default"
  repository = "oci://ghcr.io/den-vasyliev/charts"
  chart      = "helm"
  version    = "2.1.0"
  set {
      name  = "gateway.hostname"
      value = "quietly-just-ferret.ngrok-free.app"
    }
  set [{
      name  = "gateway.path"
      value = "/prod"
    }]
  
}
