import os
import logging
from google.cloud import storage

from llama_index.core import Settings
from llama_index.core.schema import TextNode
from llama_index.embeddings.google_genai import GoogleGenAIEmbedding
from llama_index.vector_stores.vertexaivectorsearch import VertexAIVectorStore

# configure logging
logging.basicConfig(level=logging.INFO)

# get configuration from environment variables
GOOGLE_CLOUD_PROJECT = os.getenv("GOOGLE_CLOUD_PROJECT")
GOOGLE_CLOUD_LOCATION = os.getenv("GOOGLE_CLOUD_LOCATION")
VERTEX_INDEX_ENDPOINT_ID = os.getenv("VERTEX_INDEX_ENDPOINT_ID")
VERTEX_INDEX_ID = os.getenv("VERTEX_INDEX_ID")

# configure global LlamaIndex settings
Settings.embed_model = GoogleGenAIEmbedding(model_name="text-embedding-004")


def handler(event, context):
    """
    Cloud Function triggered by a file upload to a GCS bucket.
    """
    bucket_name = event["bucket"]
    file_name = event["name"]

    if not file_name.startswith("documents/"):
        logging.info(f"Ignoring file: {file_name} as it is not in documents/ folder")
        return

    logging.info(f"Function triggered for file: {file_name} in bucket: {bucket_name}")

    try:

        # download the file from GCS
        storage_client = storage.Client()
        bucket = storage_client.bucket(bucket_name)
        blob = bucket.blob(file_name)
        file_contents = blob.download_as_text()
        logging.info(f"Successfully downloaded contents of file: {file_name}")

        # split document into text chunks
        chunks = file_contents.split("\n\n")
        chunks = [chunk for chunk in chunks if chunk.strip()]
        logging.info(f"Split document into {len(chunks)} chunks")

        if not chunks:
            logging.warning(f"No content chunks found in file: {file_name}. Skipping.")

        # create LlamaIndex embeddings
        logging.info(f"Generating embeddings for {len(chunks)} chunks...")
        nodes = []
        for i, chunk in enumerate(chunks):
            node = TextNode(text=chunk)
            node.id_ = f"{file_name}_{i}"
            node.embedding = Settings.embed_model.get_text_embedding(node.get_content())
            nodes.append(node)
        logging.info("Embeddings generated successfully.")

        # connect to the existing Vertex AI Vector Store
        vector_store = VertexAIVectorStore(
            index_id=VERTEX_INDEX_ID,
            endpoint_id=VERTEX_INDEX_ENDPOINT_ID,
            project_id=GOOGLE_CLOUD_PROJECT,
            region=GOOGLE_CLOUD_LOCATION,
        )

        # add the nodes to the vector store
        vector_store.add(nodes)

        logging.info(
            f"Successfully processed and upserted document: {file_name} to Vector Search"
        )

    except Exception as e:
        logging.error(f"Error processing file {file_name}: {e}")
        raise
