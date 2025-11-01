output "api_url" {
    description = "The public URL of the deployed RAG API."
    value       = google_cloud_run_v2_service.rag_api.uri
}