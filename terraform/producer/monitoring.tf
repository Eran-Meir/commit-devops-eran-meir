# resource "google_monitoring_dashboard" "compute_dashboard" {
#   dashboard_json = file("${path.module}/dashboard_vpc_b_compute.json")
#   project        = "commit-gcp-psc-eran-meir"
# }