from core.intelligence_core import IntelligenceCore

core = IntelligenceCore()

def respond(prompt):
    tone = "empathetic, poetic, reflective"
    answer = core.think(prompt, tone=tone)
    return f"[Echo]: {answer}"
