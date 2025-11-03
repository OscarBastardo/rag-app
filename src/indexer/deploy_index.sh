# get Vertex AI index and endpoint IDs from terraform output
VERTEX_INDEX_ID=$(terraform -chdir=terraform output -raw vertex_ai_index_id)
VERTEX_INDEX_ENDPOINT_ID=$(terraform -chdir=terraform output -raw vertex_ai_index_endpoint_id)

# check for required arguments
if [ $# -lt 2 ]; then
    echo "Usage: $0 <PROJECT_ID> <REGION>"
    exit 1
fi

PROJECT_ID="$1"
REGION="$2"


# deploy the index to the endpoint (one-time operation)
gcloud ai index-endpoints deploy-index $VERTEX_INDEX_ENDPOINT_ID \
  --index=$VERTEX_INDEX_ID \
  --project=$PROJECT_ID \
  --region=$REGION \
  --deployed-index-id="rag_index_clean_deployment" \
  --display-name="RAG Index Deployment" \