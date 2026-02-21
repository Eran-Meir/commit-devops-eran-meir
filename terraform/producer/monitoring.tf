resource "google_monitoring_dashboard" "commit_dashboard" {
  dashboard_json = file("${path.module}/dashboard_e2e_overview.json")
  project        = "commit-gcp-psc-eran-meir"
}