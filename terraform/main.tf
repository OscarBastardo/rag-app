terraform {
    required_providers {
      google = {
        source  = "hashicorp/google"
        version = "~> 5.0"
      }
    }
}

provider "google" {
    project = var.gcp_project_id
    region  = var.gcp_region
}

resource "google_project_service" "apis" {
    for_each = toset([
        "run.googleapis.com",
        "artifactregistry.googleapis.com",
        "aiplatform.googleapis.com",
        "iam.googleapis.com",
    ])
    service = each.key
    disable_on_destroy = false
}