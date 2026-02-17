resource "google_compute_network" "consumer_vpc" {
  name                    = "commit-vpc-consumer"
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "consumer_subnet" {
  name          = "commit-subnet-consumer"
  ip_cidr_range = "10.20.0.0/24"
  region        = "me-west1"
  network       = google_compute_network.consumer_vpc.id
}

# TRICK #2: The Proxy-Only Subnet
# Required for Envoy-based Load Balancers (like the Global External HTTPS LB)
resource "google_compute_subnetwork" "proxy_subnet" {
  name          = "commit-subnet-proxy"
  ip_cidr_range = "10.129.0.0/23" # Must be /23 or larger
  region        = "me-west1"
  network       = google_compute_network.consumer_vpc.id
  purpose       = "REGIONAL_MANAGED_PROXY"
  role          = "ACTIVE"
}