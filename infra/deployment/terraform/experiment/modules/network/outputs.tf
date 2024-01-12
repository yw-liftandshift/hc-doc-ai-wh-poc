output "network_name" {
  value = google_compute_network.vpc.name
}

output "northamerica_northeast1_subnet_id" {
  value = google_compute_subnetwork.northamerica_northeast1.id
}

output "proxy_only_northamerica_northeast1_subnet_id" {
  value = google_compute_subnetwork.proxy_only_northamerica_northeast1.id
}

output "vpc_access_connector_northamerica_northeast1_id" {
  value = google_vpc_access_connector.northamerica_northeast1.id
}