terraform {
  required_version = ">= 1.0"

  backend "gcs" {
    bucket  = "commit-tf-state-eran-meir"  # Your new bucket
    prefix  = "terraform/producer"         # Keeps this state separate
  }

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.24"
    }
  }
}

provider "google" {
  project = "commit-gcp-psc-eran-meir"
  region  = "me-west1"
}