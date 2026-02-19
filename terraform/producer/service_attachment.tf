# 1. RESERVE THE STATIC IP
# This allows us to know the IP address before the app is even deployed.
resource "google_compute_address" "ilb_ip" {
  name         = "commit-ilb-ip"
  subnetwork   = google_compute_subnetwork.gke_subnet.id
  address_type = "INTERNAL"
  region       = "me-west1"
}

# 2. DEFINE THE HEALTH CHECK
# The Load Balancer needs to know if your Nginx Pods are alive.
resource "google_compute_region_health_check" "producer_hc" {
  name   = "commit-producer-hc"
  region = "me-west1"

  tcp_health_check {
    port = 443  # We will configure Nginx to listen here
  }
}

# 3. CREATE THE BACKEND SERVICE
# This defines "Where do I send the traffic?" -> To the GKE Nodes.
resource "google_compute_region_backend_service" "producer_backend" {
  name                  = "commit-producer-backend"
  region                = "me-west1"
  protocol              = "TCP"
  load_balancing_scheme = "INTERNAL"
  health_checks         = [google_compute_region_health_check.producer_hc.id]

  backend {
    # Point Backend Service to Instance Group instead of Manager
    group          = replace(google_container_node_pool.primary_nodes.instance_group_urls[0], "instanceGroupManagers", "instanceGroups")
    balancing_mode = "CONNECTION"
  }
}

# 4. CREATE THE FORWARDING RULE (THE LOAD BALANCER)
# This is the actual entry point that the Service Attachment connects to.
resource "google_compute_forwarding_rule" "producer_forwarding_rule" {
  name   = "commit-producer-forwarding-rule"
  description = "Allow Global Access enabled"
  region = "me-west1"

  load_balancing_scheme = "INTERNAL"
  backend_service       = google_compute_region_backend_service.producer_backend.id
  network               = google_compute_network.producer_vpc.id
  subnetwork            = google_compute_subnetwork.gke_subnet.id
  ip_address            = google_compute_address.ilb_ip.id
  ports = ["443"]
  allow_global_access   = true
}

# 5. CREATE THE SERVICE ATTACHMENT (THE BRIDGE)
# This is the resource that allows Project A to connect to us via Private Service Connect.
resource "google_compute_service_attachment" "producer_service_attachment" {
  name        = "commit-service-attachment"
  region      = "me-west1"
  description = "PSC Service Attachment for Comm-IT Assignment"

  # Establish the link to the Forwarding Rule we just created
  target_service = google_compute_forwarding_rule.producer_forwarding_rule.id

  # Connection preference: AUTO (Accept everyone) or MANUAL (Accept specific projects)
  connection_preference = "ACCEPT_AUTOMATIC"

  # The explicit PSC subnet we created in vpc.tf is used here for NAT
  nat_subnets           = [google_compute_subnetwork.psc_subnet.id]

  # Explicitly disable Proxy Protocol
  enable_proxy_protocol = false
}