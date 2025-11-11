import asyncio, aiohttp, time, json
from core.agent_registry import AGENT_REGISTRY

async def send_task(agent, payload):
    port = AGENT_REGISTRY[agent]["port"]
    url  = f"http://127.0.0.1:{port}/task"
    async with aiohttp.ClientSession() as s:
        try:
            async with s.post(url, json=payload, timeout=20) as r:
                return {agent: await r.text()}
        except Exception as e:
            return {agent: f"error: {e}"}

async def orchestrate(task):
    print(f"[+] Swarm orchestrating task: {task}")
    agents = list(AGENT_REGISTRY.keys())
    results = await asyncio.gather(*(send_task(a, {"task": task}) for a in agents))
    print(json.dumps(results, indent=2))

if __name__ == "__main__":
    t0 = time.time()
    asyncio.run(orchestrate("run system self-reflection"))
    print(f"[✓] Completed in {time.time()-t0:.2f}s")
