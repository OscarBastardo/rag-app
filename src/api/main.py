import os
from fastapi import FastAPI
from pydantic import BaseModel
from llama_index.llms.google_genai import GoogleGenAI
from llama_index.core import Settings, VectorStoreIndex
from llama_index.embeddings.google_genai import GoogleGenAIEmbedding
from llama_index.vector_stores.vertexaivectorsearch import VertexAIVectorStore

"""
Pydantic Models for Request and Response
"""


class QueryRequest(BaseModel):
    question: str


class QueryResponse(BaseModel):
    answer: str


"""
Initialise FastAPI app
"""
app = FastAPI(
    title="RAG API",
    description="An API for a RAG system",
    version="1.0.0",
)

"""
Load Model and Connect to Vertex AI Vector Search at Startup
"""


def initialize_rag_system():
    """
    Initialises the LLM, embedding model and query engine.
    """

    # configure LLM and embedding models
    Settings.llm = GoogleGenAI(model_name="gemini-2.5-flash")
    Settings.embed_model = GoogleGenAIEmbedding(model_name="text-embedding-004")

    # get Vertex AI configuration from environment variables
    index_id = os.getenv("VERTEX_INDEX_ID")
    endpoint_id = os.getenv("VERTEX_INDEX_ENDPOINT_ID")
    project_id = os.getenv("GOOGLE_CLOUD_PROJECT")
    region = os.getenv("GOOGLE_CLOUD_LOCATION")

    if not all([index_id, endpoint_id, project_id, region]):
        raise ValueError(
            "VERTEX_INDEX_ID, VERTEX_INDEX_ENDPOINT_ID, GOOGLE_CLOUD_PROJECT, "
            "and GOOGLE_CLOUD_LOCATION environment variables must be set."
        )

    # connect to the managed Vertex AI vector store
    vector_store = VertexAIVectorStore(
        index_id=index_id,
        endpoint_id=endpoint_id,
        project_id=project_id,
        region=region,
    )

    # create a LlamaIndex index object from the managed vector store
    index = VectorStoreIndex.from_vector_store(vector_store=vector_store)

    # create and return query engine
    return index.as_query_engine(similarity_top_k=3)


query_engine = initialize_rag_system()

"""
Define API Endpoints
"""


@app.get("/")
def read_root():
    """
    Health check endpoint
    """
    return {"status": "RAG API is running"}


@app.post("/query", response_model=QueryResponse)
def query_rag(request: QueryRequest) -> QueryResponse:
    """
    Accept a question, query the RAG system, and return the answer.
    """
    response = query_engine.query(request.question)
    return QueryResponse(answer=str(response))
