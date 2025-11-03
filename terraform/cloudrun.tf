# 1. create the repository to hold the Docker image
resource "google_artifact_registry_repository" "api_repo" {
    repository_id = var.repo_name
    format        = "DOCKER"
    location      = var.gcp_region
    description   = "Docker repository for the RAG API."
    depends_on    = [google_project_service.apis]
}

# 2. create the Cloud Run service
resource "google_cloud_run_v2_service" "rag_api" {
    name      = "rag-api-service"
    location  = var.gcp_region

    template {
        service_account = google_service_account.api_sa.email
        containers {
            image = "${var.gcp_region}-docker.pkg.dev/${var.gcp_project_id}/${var.repo_name}/rag-api:v1"
            ports {
                container_port = 8000
            }
            env {
                name = "GOOGLE_GENAI_USE_VERTEXAI"
                value = "true"
            }
            env {
                name  = "GOOGLE_CLOUD_PROJECT"
                value = var.gcp_project_id
            }
            env {
                name  = "GOOGLE_CLOUD_LOCATION"
                value = var.gcp_region
            }
            env {
                name  = "VERTEX_INDEX_ID"
                value = google_vertex_ai_index.rag_index.id
            }
            env {
                name  = "VERTEX_INDEX_ENDPOINT_ID"
                value = google_vertex_ai_index_endpoint.rag_index_endpoint.id
            }
        }
    }
    depends_on = [google_artifact_registry_repository.api_repo]
}
