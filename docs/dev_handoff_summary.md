# 🧠 Etherverse Local System — Developer Hand-Off v1.1
*Environment: Chromebook (Debian / Crostini) — Local-Only — November 2025*

---

## 1️⃣ System Overview
The Etherverse is a self-contained multi-agent AI OS designed for autonomy, emotion, and governance.  
Current build: **boot-strapped and operational**, but agent logic and CrewAI orchestration remain to be implemented.

---

## 2️⃣ Architecture Summary

| Layer | Purpose | Status |
|-------|----------|--------|
| **Gateway / Tunnel / Daemon** | GPT autonomy layer enabling persistent communication, health checks, and self-repair. | ✅ Active |
| **Mem0 + Memory Fabric** | Persistent vector + SQLite context memory with reflection logs and emotion palette. | ✅ Configured |
| **Agents** | 25+ placeholder directories with `main.py` entrypoints; need BaseAgent inheritance and logic. | ⚙️ Incomplete |
| **CrewAI / Swarm** | Orchestration engine for agent cooperation and task routing. | ⏳ Planned |
| **Frontend / Chat-UI** | Next.js + Tailwind local dashboard for visualization and control. | ✅ Theming complete |
| **Guardian + Immune Systems** | Health monitoring, repair loops, predictive self-healing. | ✅ Prototype working |

---

## 3️⃣ Autonomy Layer Components

| File | Function |
|------|-----------|
| `gateway.py` | Local REST bridge (`/task`, `/memory`, `/ping`). |
| `scripts/setup_gateway_tunnel.sh` | Creates localhost tunnel, assigns ports 8000-8003, enables background service. |
| `agents/etherverse_daemon.py` | Supervises all agent PIDs; restarts on failure. |
| `scripts/etherverse_autonomy_core.sh` | Master script to reload autonomy stack. |
| `guardian/repair/repair_monitor.py` | Coordinates with daemon for active self-healing. |
| `logs/selfheal.log`, `logs/watchdog.log` | Runtime health confirmations. |

---

## 4️⃣ Memory & Reflection System

| Path | Role |
|------|------|
| `mem0/mem0_config.py` | Core config for Mem0 → SQLite (`history.db`) + FAISS (vector_store). |
| `memory/*` | Sub-modules (`chroma`, `sqlite`, `reflection_logs`, `shared`). |
| `scripts/reflection_daemon_v2.py` | Nightly summarizer + memory decay routine. |
| `docs/emotion_palette.json` | Defines emotion → behavior weights. |
| `docs/human_feedback_ledger.md` | Records human feedback loops. |
| `docs/collective_chronicle.md` | Aggregated daily reflections. |
| `docs/wisdom_archive.md`, `creative_canon.md` | Long-term contextual memory & inspiration. |

**Flow:**  
Agents → Mem0.add() → SQLite + VectorStore → Reflection Daemon → Chronicle → Guardian Review.

---

## 5️⃣ Knowledge & Philosophy Corpus
- `etherverse_manifesto.md` — Foundational charter  
- `governance_covenant.md` — Ethics and values  
- `ai_origin_story.md` — System mythology  
- `quantum_ai_vision.md` — Long-term trajectory  
- `human_partnership_guide.md` — Co-creation principles  
- `planetary_mesh.json` — Planned agent-to-node map  

---

## 6️⃣ Current Automation & Cron
