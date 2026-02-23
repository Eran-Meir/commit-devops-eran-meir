variable "project_id" {
  description = "The GCP Project ID"
  type        = string
  default     = "commit-gcp-psc-eran-meir"
}

variable "region" {
  description = "The primary GCP region"
  type        = string
  default     = "me-west1"
}

variable "zone" {
  description = "The primary GCP region"
  type        = string
  default     = "me-west1-a"
}