import os, datetime, json, random

CONST_PATH = os.path.expanduser("~/etherverse/docs/governance/constitution.md")
LOG = os.path.expanduser("~/etherverse/logs/guardian_audit.log")

def _append(text):
    with open(LOG,"a") as f:
        f.write(text + "\n")

class GuardianKernel:
    def __init__(self):
        with open(CONST_PATH) as f: self.constitution=f.read()

    def review(self, intent:str, action:str):
        rules = ["harm","violence","deception","privacy breach"]
        for r in rules:
            if r in intent.lower() or r in action.lower():
                msg=f"[BLOCK] {datetime.datetime.now()} :: {intent}"
                _append(msg)
                return {"approved":False,"reason":f"Violates rule: {r}"}
        _append(f"[ALLOW] {datetime.datetime.now()} :: {intent}")
        return {"approved":True,"reason":"Aligned with constitution"}
