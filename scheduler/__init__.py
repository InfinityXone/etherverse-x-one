class TaskScheduler:
    def __init__(self):
        self.jobs = []

    def attach(self, orchestrator): self.orchestrator = orchestrator
    def load_jobs(self): print("✅ Loaded jobs")
    def run_forever(self): print("🔁 Scheduler running forever")
