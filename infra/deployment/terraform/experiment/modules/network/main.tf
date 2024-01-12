resource "google_compute_network" "vpc" {
  name                    = "hpfb-backlog-poc-vpc-1"
  auto_create_subnetworks = false
  routing_mode            = "REGIONAL"
}

resource "google_compute_subnetwork" "northamerica_northeast1" {
  name          = "${google_compute_network.vpc.name}-na-ne1-subnet"
  ip_cidr_range = "10.162.4.0/23"
  region        = "northamerica-northeast1"
  network       = google_compute_network.vpc.id
}

resource "google_compute_subnetwork" "proxy_only_northamerica_northeast1" {
  name          = "${google_compute_network.vpc.name}-proxy-na-ne1-subnet"
  ip_cidr_range = "10.162.0.0/23"
  region        = "northamerica-northeast1"
  network       = google_compute_network.vpc.id
  purpose       = "REGIONAL_MANAGED_PROXY"
  role          = "ACTIVE"
}

resource "google_compute_router" "northamerica_northeast1" {
  name    = "${google_compute_network.vpc.name}-na-ne1-router"
  network = google_compute_network.vpc.name
  region  = "northamerica-northeast1"
}

resource "google_compute_address" "northamerica_northeast1_router" {
  name   = "${google_compute_router.northamerica_northeast1.name}-ip-addr"
  region = "northamerica-northeast1"
}

resource "google_compute_router_nat" "northamerica_northeast1" {
  name   = "${google_compute_router.northamerica_northeast1.name}-static-nat"
  router = google_compute_router.northamerica_northeast1.name
  region = "northamerica-northeast1"

  nat_ip_allocate_option = "MANUAL_ONLY"
  nat_ips                = [google_compute_address.northamerica_northeast1_router.self_link]

  source_subnetwork_ip_ranges_to_nat = "LIST_OF_SUBNETWORKS"
  subnetwork {
    name                    = google_compute_subnetwork.northamerica_northeast1.id
    source_ip_ranges_to_nat = ["ALL_IP_RANGES"]
  }
  subnetwork {
    name                    = google_compute_subnetwork.vpc_access_connector_northamerica_northeast1.id
    source_ip_ranges_to_nat = ["ALL_IP_RANGES"]
  }
}

# 
resource "google_compute_global_address" "vpc_private_ip_address" {
  name          = "vpc-peering-private-ip-address"
  purpose       = "VPC_PEERING"
  address_type  = "INTERNAL"
  prefix_length = 16
  network       = google_compute_network.vpc.id
}

resource "google_service_networking_connection" "vpc_private_vpc_connection" {
  network                 = google_compute_network.vpc.id
  service                 = "servicenetworking.googleapis.com"
  reserved_peering_ranges = [google_compute_global_address.vpc_private_ip_address.name]
}