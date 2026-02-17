# 1. CLOUD ARMOR POLICY
resource "google_compute_security_policy" "armor_policy" {
  name = "commit-armor-policy"

  # Rule 1: Allow everyone (Default)
  rule {
    action   = "allow"
    priority = "2147483647"
    match {
      versioned_expr = "SRC_IPS_V1"
      config {
        src_ip_ranges = ["*"]
      }
    }
    description = "Default rule, allow all"
  }

  # Example: Block a specific bad IP (Demonstrates WAF capability)
  rule {
    action   = "deny(403)"
    priority = "1000"
    match {
      versioned_expr = "SRC_IPS_V1"
      config {
        src_ip_ranges = ["1.2.3.4/32"]
      }
    }
    description = "Block malicious test IP"
  }
}

# 2. BACKEND SERVICE (Global)
resource "google_compute_backend_service" "external_backend" {
  name                  = "commit-external-backend"
  load_balancing_scheme = "EXTERNAL_MANAGED"
  protocol              = "HTTPS"

  # Attach Cloud Armor
  security_policy = google_compute_security_policy.armor_policy.id

  backend {
    group           = google_compute_region_network_endpoint_group.psc_neg.id
    balancing_mode  = "UTILIZATION"
    capacity_scaler = 1.0
  }
}

# 3. URL MAP (Routing)
resource "google_compute_url_map" "default" {
  name            = "commit-url-map"
  default_service = google_compute_backend_service.external_backend.id
}

# 4. HTTPS PROXY
# Note: For real HTTPS, you need an SSL Certificate.
# For this task, we can use a Google-managed cert or just HTTP to start.
# Let's assume HTTP first to test connection, then upgrade?
# The diagram says "HTTPS". We will use a self-signed cert or Google-managed cert.

# Generating a Google Managed Cert
resource "google_compute_managed_ssl_certificate" "default" {
  name = "commit-cert"

  managed {
    domains = ["commit-demo.endpoints.commit-gcp-psc-eran-meir.cloud.goog"] # Or a real domain
  }
}

# PROXY
resource "google_compute_target_https_proxy" "default" {
  name             = "commit-https-proxy"
  url_map          = google_compute_url_map.default.id
  ssl_certificates = [google_compute_managed_ssl_certificate.default.id]
}

# 5. GLOBAL FORWARDING RULE
resource "google_compute_global_forwarding_rule" "default" {
  name       = "commit-global-forwarding-rule"
  target     = google_compute_target_https_proxy.default.id
  port_range = "443"
  ip_address = google_compute_global_address.external_ip.id
}