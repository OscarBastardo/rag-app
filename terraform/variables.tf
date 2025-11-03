variable "gcp_project_id" {
    type        = string
    description = "The GCP project ID to deploy resources to."
}

variable "gcp_region" {
    type        = string
    description = "The GCP region to deploy resources in."
}

variable "repo_name" {
    type        = string
    description = "The name of the repository for the Artifact Registry."
    default     = "rag-api-repo"
}