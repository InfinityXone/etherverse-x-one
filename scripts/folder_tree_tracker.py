#!/usr/bin/env python3
"""
Etherverse Folder Tree + Growth Tracker
---------------------------------------
• Builds or updates ~/etherverse/docs/folder_tree.md
• Auto-creates missing agent folders from agents_manifest.json
• Logs changes each run
"""

import os, json, time, subprocess, pathlib

ROOT = pathlib.Path.home() / "etherverse"
DOCS = ROOT / "docs"
AGENTS = ROOT / "agents"
MANIFEST = DOCS / "agents_manifest.json"
OUTFILE = DOCS / "folder_tree.md"
LOGFILE = DOCS / "folder_growth.log"

DEFAULT_MANIFEST = {
    "core_agents": [
        "guardian", "promptwriter", "quantum",
        "echo", "finsynapse", "corelight",
        "vision", "strategy", "devops",
        "finops", "codeops"
    ],
    "meta": {
        "last_update": None,
        "description": "Defines required agent folders for Etherverse growth"
    }
}

def ensure_manifest():
    DOCS.mkdir(exist_ok=True)
    if not MANIFEST.exists():
        MANIFEST.write_text(json.dumps(DEFAULT_MANIFEST, indent=2))
        print("📘 Created default agents_manifest.json")
    return json.loads(MANIFEST.read_text())

def grow_agents(manifest):
    AGENTS.mkdir(exist_ok=True)
    created = []
    for agent in manifest.get("core_agents", []):
        folder = AGENTS / agent
        if not folder.exists():
            folder.mkdir(parents=True)
            created.append(agent)
    if created:
        with open(LOGFILE, "a") as log:
            log.write(f"[{time.strftime('%Y-%m-%d %H:%M:%S')}] Created: {', '.join(created)}\n")
    return created

def make_tree():
    try:
        tree = subprocess.check_output(["tree", "-a", "-L", "3", str(ROOT)], text=True)
    except Exception:
        lines = []
        for dirpath, dirs, files in os.walk(ROOT):
            level = dirpath.replace(str(ROOT), "").count(os.sep)
            indent = "  " * level
            lines.append(f"{indent}{os.path.basename(dirpath)}/")
            for f in files:
                lines.append(f"{indent}  {f}")
        tree = "\n".join(lines)
    ts = time.strftime("%Y-%m-%d %H:%M:%S")
    OUTFILE.write_text(f"# Etherverse Folder Snapshot\n\n_Last updated: {ts}_\n\n```\n{tree}\n```")
    print(f"✅ Folder tree updated → {OUTFILE}")

if __name__ == "__main__":
    manifest = ensure_manifest()
    new_dirs = grow_agents(manifest)
    make_tree()
    if new_dirs:
        print("🌱 Created new agent folders:", ", ".join(new_dirs))
    else:
        print("✅ All agent folders already exist.")
