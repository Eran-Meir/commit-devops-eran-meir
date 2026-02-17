terraform {
  required_version = ">= 1.0"

  backend "gcs" {
    bucket  = "commit-tf-state-eran-meir"
    prefix  = "terraform/consumer"
  }

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
    # ADDED: This provider allows us to generate self-signed certs
    tls = {
      source  = "hashicorp/tls"
      version = "~> 4.0"
    }
  }
}

provider "google" {
  project = "commit-gcp-psc-eran-meir"
  region  = "me-west1"
}