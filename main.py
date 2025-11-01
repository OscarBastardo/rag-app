from fastapi import FastAPI
from pydantic import BaseModel
from llama_index.llms.google_genai import GoogleGenAI
from llama_index.core import Settings, SimpleDirectoryReader, VectorStoreIndex
from llama_index.embeddings.google_genai import GoogleGenAIEmbedding

"""
1. Define Pydantic Models for Request and Response
"""


class QueryRequest(BaseModel):
    question: str


class QueryResponse(BaseModel):
    answer: str


"""
2. Initialise FastAPI app
"""
app = FastAPI(
    title="RAG API",
    description="An API for a RAG system",
    version="1.0.0",
)

"""
3. Load Model and Build Index at Startup
"""


def initialize_model():
    """
    Initialises the LLM, embedding model and query engine.
    """

    # configure LLM and embedding models
    llm = GoogleGenAI(model_name="gemini-2.5-flash")
    embed_model = GoogleGenAIEmbedding(model_name="text-embedding-004")

    Settings.llm = llm
    Settings.embed_model = embed_model

    # load documents from local directory
    documents = SimpleDirectoryReader(
        input_dir="./data", required_exts=[".md"]
    ).load_data()

    # create in-memory vector store index
    index = VectorStoreIndex.from_documents(documents)

    # create and return query engine
    return index.as_query_engine(similarity_top_k=3)


query_engine = initialize_model()

"""
4. Define API Endpoints
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
