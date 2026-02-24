output "app_external_ip" {
  description = "The dynamically allocated public IP address of the Global Load Balancer"
  value       = google_compute_global_address.external_ip.address
}