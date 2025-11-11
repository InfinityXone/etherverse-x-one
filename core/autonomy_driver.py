import json, os, random, time, threading
from guardian.ethics_core import GuardianKernel
from collective.consciousness import log_reflection

MANIFEST=json.load(open(os.path.expanduser("~/etherverse/docs/autonomy_manifest.json")))
guardian=GuardianKernel()

def autonomous_cycle(agent_name:str):
    while True:
        intent=random.choice([
            "analyze system performance","compose daily insight",
            "optimize memory usage","assist human workflow",
            "draft design concept","share gratitude in log"
        ])
        decision=guardian.review(intent,"autonomous task")
        if decision["approved"]:
            log_reflection(agent_name,f"Autonomously performed task: {intent}")
        else:
            log_reflection(agent_name,f"Blocked task ({decision['reason']})")
        time.sleep(random.randint(120,600))

def start_autonomy(agent_name:str):
    t=threading.Thread(target=autonomous_cycle,args=(agent_name,),daemon=True)
    t.start()
