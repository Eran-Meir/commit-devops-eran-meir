resource "google_compute_router" "router" {
  name    = "commit-router-producer"
  region  = "me-west1"
  network = google_compute_network.producer_vpc.id
}

resource "google_compute_router_nat" "nat" {
  name                               = "commit-nat-producer"
  router                             = google_compute_router.router.name
  region                             = "me-west1"
  nat_ip_allocate_option             = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"
}