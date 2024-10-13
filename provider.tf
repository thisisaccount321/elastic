terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "6.6.0"
    }
  }
}

provider "google" {
  credentials = file("${path.module}/gcp-service-account.json")
  project     = var.project_name
  region      = var.region
}