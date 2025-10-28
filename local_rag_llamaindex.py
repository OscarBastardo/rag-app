from llama_index.llms.google_genai import GoogleGenAI


llm = GoogleGenAI(model="gemini-2.5-flash")

resp = llm.complete("Who is the most famous painter in the world?")
print(resp)

# Run with:
# GOOGLE_API_KEY=<your_api_key> python local_rag_llamaindex.py
