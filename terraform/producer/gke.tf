resource "google_container_cluster" "primary" {
  name     = "commit-cluster-producer"
  location = "me-west1-a"  # Zonal cluster is cheaper than Regional

  # Turn off the safety lock
  deletion_protection = false

  # We want a clean network, so we delete the default node pool immediately
  remove_default_node_pool = true
  initial_node_count       = 1

  network    = google_compute_network.producer_vpc.id
  subnetwork = google_compute_subnetwork.gke_subnet.id

  # VPC-Native Networking (Required for PSC)
  ip_allocation_policy {
    cluster_secondary_range_name  = "pods"
    services_secondary_range_name = "services"
  }

  # Ensure private nodes (Security Best Practice)
  private_cluster_config {
    enable_private_nodes    = true
    enable_private_endpoint = false
    master_ipv4_cidr_block  = "172.16.0.0/28"
  }
}

# The actual worker nodes
resource "google_container_node_pool" "primary_nodes" {
  name       = "commit-node-pool"
  location   = "me-west1-a"
  cluster    = google_container_cluster.primary.name
  node_count = 1  # Minimum nodes to run the app

  node_config {
    preemptible = true  # Spot instances! Saves ~70% cost
    machine_type = "e2-medium"

    # Minimal scopes for security
    oauth_scopes = [
      "https://www.googleapis.com/auth/cloud-platform"
    ]
  }
}

resource "google_artifact_registry_repository" "app_repo" {
  project       = "commit-gcp-psc-eran-meir"
  location      = "me-west1"
  repository_id = "commit-flask-app"
  description   = "Docker repository for Flask application"
  format        = "DOCKER"
}