resource "google_compute_subnetwork" "vpc_access_connector_northamerica_northeast1" {
  name          = "${google_compute_network.vpc.name}-vpc-conn-na-ne1"
  ip_cidr_range = "10.162.2.0/28"
  region        = "northamerica-northeast1"
  network       = google_compute_network.vpc.id
}

resource "google_vpc_access_connector" "northamerica_northeast1" {
  name   = "vpc-conn-na-ne1"
  region = "northamerica-northeast1"
  subnet {
    name = google_compute_subnetwork.vpc_access_connector_northamerica_northeast1.name
  }

  depends_on = [
    google_service_networking_connection.vpc_private_vpc_connection
  ]
}