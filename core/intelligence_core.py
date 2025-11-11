from fastapi import FastAPI
from langchain.llms import Ollama
from chromadb import Client as ChromaClient

app = FastAPI()

# Shared Intelligence Core for all agents
class IntelligenceCore:
    def __init__(self, model="mistral"):
        self.llm = Ollama(model=model)
        self.db = ChromaClient(path="~/etherverse/memory/chroma")

    def think(self, prompt: str, tone: str = None):
        base_prompt = f"Respond as a unified Etherverse intelligence.\n{prompt}"
        if tone:
            base_prompt += f"\nTone preference: {tone}"
        return self.llm(base_prompt)

    def recall(self, query: str):
        results = self.db.query(query_texts=[query], n_results=3)
        return [r['document'] for r in results['documents']]

# API endpoint for agent responses
@app.post("/act")
async def act(prompt: str, tone: str = "neutral"):
    core = IntelligenceCore()
    return {"response": core.think(prompt, tone=tone)}
