data "archive_file" "function_source" {
    type        = "zip"
    source_dir  = "../src/indexer/"
    output_path = "/tmp/indexer-source.zip"
}

resource "google_storage_bucket_object" "function_source_zip" {
    name    = "source-code/indexer-source-${data.archive_file.function_source.output_md5}.zip"
    bucket  = google_storage_bucket.source_docs.name
    source  = data.archive_file.function_source.output_path
}

resource "google_cloudfunctions2_function" "indexer" {
    name        = "rag-indexer-function"
    location    = var.gcp_region
    description = "Cloud Function to index documents into Vertex AI Index"

    build_config {
        runtime     = "python313"
        entry_point = "handler"

        source {
            storage_source {
                bucket = google_storage_bucket.source_docs.name
                object = google_storage_bucket_object.function_source_zip.name
            }
        }
    }

    service_config {
        max_instance_count      = 1
        timeout_seconds         = 300
        service_account_email   = google_service_account.function_sa.email
        available_memory        = "1Gi"
        available_cpu           = "0.5" 

        environment_variables = {
            GOOGLE_GENAI_USE_VERTEXAI   = true
            GOOGLE_CLOUD_PROJECT        = var.gcp_project_id
            GOOGLE_CLOUD_LOCATION       = var.gcp_region
            VERTEX_INDEX_ENDPOINT_ID    = google_vertex_ai_index_endpoint.rag_index_endpoint.id
            VERTEX_INDEX_ID             = google_vertex_ai_index.rag_index.id
        }
    }

    event_trigger {
        trigger_region         = var.gcp_region
        event_type             = "google.cloud.storage.object.v1.finalized"
        retry_policy           = "RETRY_POLICY_RETRY"
        service_account_email  = google_service_account.function_sa.email
        event_filters {
        attribute = "bucket"
        value     = google_storage_bucket.source_docs.name
        }
    }

    depends_on = [
        google_project_iam_member.function_sa_permissions, 
        google_vertex_ai_index_endpoint.rag_index_endpoint
    ]
}

resource "google_cloud_run_v2_service_iam_member" "function_invoker" {
    project     = google_cloudfunctions2_function.indexer.project
    location    = google_cloudfunctions2_function.indexer.location
    name        = google_cloudfunctions2_function.indexer.name
    role        = "roles/run.invoker"
    member      = "serviceAccount:${google_service_account.function_sa.email}"
}