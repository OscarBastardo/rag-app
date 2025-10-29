from llama_index.llms.google_genai import GoogleGenAI
from llama_index.core import Settings, SimpleDirectoryReader, VectorStoreIndex
from llama_index.embeddings.google_genai import GoogleGenAIEmbedding


# initialise LLM
llm = GoogleGenAI(model_name="gemini-2.5-flash")

# initialise embedding model
embed_model = GoogleGenAIEmbedding(model_name="text-embedding-004")

# global settings
Settings.llm = llm
Settings.embed_model = embed_model

# loading documents
documents = SimpleDirectoryReader(input_dir="./data", required_exts=[".md"]).load_data()

# index documents using vector store
index = VectorStoreIndex.from_documents(documents)

# create query engine
query_engine = index.as_query_engine(similarity_top_k=3)

# generating query responses
query1 = "Who is Kaelen Nightbreeze?"
response1 = query_engine.query(query1)
print(f"Q: {query1}\nA: {response1}\n")

query2 = "What are the main factions in Oakhaven?"
response2 = query_engine.query(query2)
print(f"Q: {query2}\nA: {response2}\n")

query3 = "What is the Shaw-Fujita Drive?"
response3 = query_engine.query(query3)
print(f"Q: {query3}\nA: {response3}\n")
