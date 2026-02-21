# resource "google_monitoring_dashboard" "edge_dashboard" {
#   dashboard_json = file("${path.module}/dashboard_vpc_a_edge.json")
#   project        = "commit-gcp-psc-eran-meir"
# }