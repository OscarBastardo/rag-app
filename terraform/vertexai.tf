resource "google_vertex_ai_index" "rag_index" {
    display_name    = "rag-document-index"
    description     = "Vector index for the RAG application documents"
    region          = var.gcp_region

    metadata {
        contents_delta_uri = "gs://${google_storage_bucket.source_docs.name}/vector-index/"

        config {
            # the embedding model 'tex-embedding-3-small' produces vectors of 768 dimensions
            dimensions = 768

            # the number of approximate neighbors to consider during search
            approximate_neighbors_count = 10

            # using a standard algorithm for fast, approximate nearest neighbor search
            algorithm_config {
              tree_ah_config {
                leaf_node_embedding_count = 1000
              }
            }
        }
    }

    # allow the Cloud Function to add new embeddings in near real-time
    index_update_method = "STREAM_UPDATE"

    depends_on = [google_project_service.apis]
}

resource "google_vertex_ai_index_endpoint" "rag_index_endpoint" {
    display_name    = "rag-index-endpoint"
    description     = "Endpoint for serving the RAG document index"
    region          = var.gcp_region

    # make endpoint publicly accessible, secured by IAM
    public_endpoint_enabled = true

    depends_on = [google_project_service.apis]
}