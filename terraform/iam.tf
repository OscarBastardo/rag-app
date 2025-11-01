# service account for the Cloud Run API
resource "google_service_account" "api_sa" {
    account_id   = "rag-api-sa"
    display_name = "Service Account for the RAG API Cloud Run service"
}

# Permissions for the Cloud Run service account to call Vertex AI
resource "google_project_iam_member" "api_sa_permissions" {
    project = var.gcp_project_id
    role    = "roles/aiplatform.user"
    member  = "serviceAccount:${google_service_account.api_sa.email}"
}
