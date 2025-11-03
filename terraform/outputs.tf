output "api_url" {
    description = "The public URL of the deployed RAG API."
    value       = google_cloud_run_v2_service.rag_api.uri
}

output "gcs_bucket_name" {
    description = "The name of the GCS bucket for source documents."
    value       = google_storage_bucket.source_docs.name
}

output "vertex_ai_index_id" {
    description = "The full ID of the Vertex AI Vector search index."
    value       = google_vertex_ai_index.rag_index.id
}

output "vertex_ai_index_endpoint_id" {
    description = "The full ID of the Vertex AI Index Endpoint."
    value       = google_vertex_ai_index_endpoint.rag_index_endpoint.id
}