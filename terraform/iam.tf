# service account for the Cloud Run API
resource "google_service_account" "api_sa" {
    account_id   = "rag-api-sa"
    display_name = "Service Account for the RAG API Cloud Run service"
}

# permissions for the Cloud Run service account to call Vertex AI
resource "google_project_iam_member" "api_sa_permissions" {
    project = var.gcp_project_id
    role    = "roles/aiplatform.user"
    member  = "serviceAccount:${google_service_account.api_sa.email}"
}

# service account for the indexing Cloud Function
resource "google_service_account" "function_sa" {
    account_id   = "rag-function-sa"
    display_name = "Service Account for the RAG Indexing Cloud Function"
}

# permissions for the Cloud Function service account to write to Vertex AI Index
resource "google_project_iam_member" "function_sa_permissions" {
    for_each = toset([
        "roles/storage.objectViewer",
        "roles/aiplatform.user",
        "roles/eventarc.eventReceiver"
    ])
    project = var.gcp_project_id
    role    = each.key
    member  = "serviceAccount:${google_service_account.function_sa.email}"
}

# permissions for the Compute Engine default service account to use Cloud Build
resource "google_project_iam_member" "compute_sa_permissions" {
    project = var.gcp_project_id
    role    = "roles/cloudbuild.builds.builder"
    member  = "serviceAccount:${data.google_project.project.number}-compute@developer.gserviceaccount.com"
}

# grant the Storage service agent access to Pub/Sub topics
resource "google_project_iam_member" "storage_service_agent_pubsub" {
    project = var.gcp_project_id
    role    = "roles/pubsub.publisher"
    member  = "serviceAccount:service-${data.google_project.project.number}@gs-project-accounts.iam.gserviceaccount.com"
}