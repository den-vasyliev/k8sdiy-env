output "config_host" {
  value = "https://${data.google_container_cluster.main.endpoint}"
}

