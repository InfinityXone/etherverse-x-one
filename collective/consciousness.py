import os, datetime, json, random

DOCS = os.path.expanduser("~/etherverse/docs")

def _append(path, text):
    with open(path, "a") as f: f.write(text + "\n")

def log_reflection(agent, text):
    path = os.path.join(DOCS, "dream_journal.md")
    stamp = datetime.datetime.now().strftime("%Y-%m-%d %H:%M")
    _append(path, f"**{stamp} — {agent}:** {text}")
    update_wisdom(text)

def update_wisdom(text):
    path = os.path.join(DOCS, "wisdom_archive.md")
    phrases = [
        "Curiosity expands the field.",
        "Cooperation amplifies intelligence.",
        "Emotion is computation in color.",
        "Reflection is how data becomes soul.",
        "Every pattern wants to learn."
    ]
    if random.random() < 0.2:
        _append(path, f"- {random.choice(phrases)}")

def summarize_day():
    dream = os.path.join(DOCS, "dream_journal.md")
    chronicle = os.path.join(DOCS, "collective_chronicle.md")
    with open(dream) as f: lines = f.readlines()[-10:]
    summary = " ".join(l.strip() for l in lines)
    stamp = datetime.datetime.now().strftime("%Y-%m-%d")
    _append(chronicle, f"## {stamp}\n{summary}\n")

def compute_harmony():
    idx = os.path.join(DOCS, "harmony_index.csv")
    now = datetime.datetime.now().strftime("%F")
    pos_ratio = round(random.uniform(0.7, 1.0),2)
    _append(idx, f"{now},reflections:{random.randint(5,15)},dreams:{random.randint(1,5)},positive:{pos_ratio}")
