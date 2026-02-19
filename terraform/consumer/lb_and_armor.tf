# 1. SECURITY POLICY (CLOUD ARMOR)
resource "google_compute_security_policy" "armor_policy" {
  name = "commit-armor-policy"

  rule {
    action   = "allow"
    priority = "2147483647"
    match {
      versioned_expr = "SRC_IPS_V1"
      config {
        src_ip_ranges = ["*"]
      }
    }
    description = "Default allow all"
  }
}

# 2. GENERATE SELF-SIGNED CERTIFICATE (The Fix)
# Create a private key
resource "tls_private_key" "default" {
  algorithm = "RSA"
  rsa_bits  = 2048
}

# Create a self-signed certificate valid for the IP
resource "tls_self_signed_cert" "default" {
  private_key_pem = tls_private_key.default.private_key_pem

  subject {
    common_name  = "commit-demo.internal"
    organization = "Comm-IT DevOps Assignment"
  }

  validity_period_hours = 24
  allowed_uses          = ["key_encipherment", "digital_signature", "server_auth"]
}

# Upload the certificate to GCP
resource "google_compute_ssl_certificate" "default" {
  name        = "commit-self-signed-cert"
  private_key = tls_private_key.default.private_key_pem
  certificate = tls_self_signed_cert.default.cert_pem
}

# 3. BACKEND SERVICE (Global)
resource "google_compute_backend_service" "external_backend" {
  name                  = "commit-external-backend"
  load_balancing_scheme = "EXTERNAL_MANAGED"
  protocol              = "HTTP"
  security_policy       = google_compute_security_policy.armor_policy.id

  backend {
    group           = google_compute_region_network_endpoint_group.psc_neg.id
    balancing_mode  = "UTILIZATION"
    capacity_scaler = 1.0
  }
}

# 4. URL MAP
resource "google_compute_url_map" "default" {
  name            = "commit-url-map"
  default_service = google_compute_backend_service.external_backend.id
}

# 5. HTTPS PROXY
resource "google_compute_target_https_proxy" "default" {
  name             = "commit-https-proxy"
  url_map          = google_compute_url_map.default.id
  ssl_certificates = [google_compute_ssl_certificate.default.id]
}

# 6. FORWARDING RULE
resource "google_compute_global_forwarding_rule" "default" {
  name       = "commit-global-forwarding-rule"
  target     = google_compute_target_https_proxy.default.id
  port_range = "443"
  ip_address = google_compute_global_address.external_ip.id
}