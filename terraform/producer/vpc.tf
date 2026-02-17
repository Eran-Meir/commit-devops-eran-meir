# The Private Network for Project B
resource "google_compute_network" "producer_vpc" {
  name                    = "commit-vpc-producer"
  auto_create_subnetworks = false
}

# Subnet for GKE Nodes and Pods
resource "google_compute_subnetwork" "gke_subnet" {
  name          = "commit-subnet-gke"
  ip_cidr_range = "10.10.0.0/20"  # Nodes get IPs from here
  region        = "me-west1"
  network       = google_compute_network.producer_vpc.id

  # Secondary ranges for Pods and Services (GPC Native VPC)
  secondary_ip_range {
    range_name    = "pods"
    ip_cidr_range = "10.48.0.0/14"
  }
  secondary_ip_range {
    range_name    = "services"
    ip_cidr_range = "10.52.0.0/20"
  }
}

# Subnet Specially for PSC (The "Trick" Requirement)
# This is where the NAT happens for the Service Attachment
resource "google_compute_subnetwork" "psc_subnet" {
  name          = "commit-subnet-psc-nat"
  ip_cidr_range = "10.2.0.0/28"
  region        = "me-west1"
  network       = google_compute_network.producer_vpc.id
  purpose       = "PRIVATE_SERVICE_CONNECT"
}