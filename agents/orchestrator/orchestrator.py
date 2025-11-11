from agents.echo.echo_agent import respond
from core.intelligence_core import IntelligenceCore

core = IntelligenceCore()

def orchestrate(task):
    if task.lower() in ["debug", "optimize"]:
        return respond(task)
    else:
        return "Task not recognized."
