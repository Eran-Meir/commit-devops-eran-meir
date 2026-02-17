resource "google_compute_global_address" "external_ip" {
  name = "commit-external-ip"
}

resource "google_compute_region_network_endpoint_group" "psc_neg" {
  name                  = "commit-psc-neg"
  region                = "me-west1"
  network_endpoint_type = "PRIVATE_SERVICE_CONNECT"

  # 'target_service_attachment' to 'psc_target_service'
  psc_target_service    = "projects/commit-gcp-psc-eran-meir/regions/me-west1/serviceAttachments/commit-service-attachment"

  network = google_compute_network.consumer_vpc.id

  # Tell it which subnet to use
  subnetwork = google_compute_subnetwork.consumer_subnet.id
}