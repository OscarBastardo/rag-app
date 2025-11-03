# debug_query.py

import os
import vertexai
from vertexai.language_models import TextEmbeddingModel
from google.cloud import aiplatform

# Configuration
GCP_PROJECT = os.getenv("GCP_PROJECT")
GCP_REGION = os.getenv("GCP_REGION")
ENDPOINT_ID = os.getenv("VERTEX_INDEX_ENDPOINT_ID")
QUESTION = "What is the Shaw-Fujita Drive?"


def main():
    print("--- Initializing Vertex AI ---")
    vertexai.init(project=GCP_PROJECT, location=GCP_REGION)

    print(f"\n--- Generating embedding for question: '{QUESTION}' ---")
    model = TextEmbeddingModel.from_pretrained("text-embedding-004")
    embeddings = model.get_embeddings([QUESTION])
    query_embedding = embeddings[0].values
    print("Embedding generated successfully.")

    print(f"\n--- Querying Vertex AI Endpoint ({ENDPOINT_ID}) ---")
    index_endpoint = aiplatform.MatchingEngineIndexEndpoint(
        index_endpoint_name=ENDPOINT_ID
    )

    # Perform the search. We want the top 3 neighbors.
    response = index_endpoint.find_neighbors(
        deployed_index_id="rag_index_clean_deployment",  # The ID from your gcloud command
        queries=[query_embedding],
        num_neighbors=3,
    )

    print("\n--- RAW RESPONSE FROM ENDPOINT ---")
    print(response)

    if response and response[0]:
        print("\n--- SUCCESS: Found neighbors! ---")
        for neighbor in response[0]:
            print(f"Neighbor ID: {neighbor.id}, Distance: {neighbor.distance:.4f}")
    else:
        print("\n--- FAILURE: Endpoint returned no neighbors. ---")


if __name__ == "__main__":
    # Run `gcloud auth application-default login` before executing this script
    main()
