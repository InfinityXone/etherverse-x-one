import psutil, time, subprocess, logging

logging.basicConfig(filename='/home/$(whoami)/etherverse/immune/health.log',
                    level=logging.INFO,
                    format='%(asctime)s %(levelname)s %(message)s')

THRESH_CPU = 80.0
THRESH_MEM = 80.0

while True:
    cpu = psutil.cpu_percent(interval=1)
    mem = psutil.virtual_memory().percent
    if cpu > THRESH_CPU or mem > THRESH_MEM:
        logging.warning(f'High usage detected: CPU={cpu}, MEM={mem}')
        subprocess.run(['systemctl', 'restart', 'etherverse-agent.service'])
    time.sleep(10)
