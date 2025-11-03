resource "google_storage_bucket" "source_docs" {
    name     = "${var.gcp_project_id}-rag-source-docs"
    location = var.gcp_region

    # enable for development purposes
    force_destroy = true

    uniform_bucket_level_access = true

    depends_on = [google_project_service.apis]
}
