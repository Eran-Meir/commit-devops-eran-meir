resource "google_compute_global_address" "external_ip" {
  name = "commit-external-ip"
}

# The PSC NEG (Network Endpoint Group)
# This points to the Service Attachment in Project B
resource "google_compute_region_network_endpoint_group" "psc_neg" {
  name                  = "commit-psc-neg"
  region                = "me-west1"
  network_endpoint_type = "PRIVATE_SERVICE_CONNECT"

  # IMPORTANT: We need the URI of the Service Attachment we built in Project B.
  # Since they are separate states, we can hardcode the URI pattern
  # OR use a terraform_remote_state data source.
  # Pattern: projects/{project}/regions/{region}/serviceAttachments/{name}
  target_service_attachment = "projects/commit-gcp-psc-eran-meir/regions/me-west1/serviceAttachments/commit-service-attachment"

  network = google_compute_network.consumer_vpc.id
}