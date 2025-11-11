#!/usr/bin/env python3
import os, re, datetime
from pathlib import Path
from wordcloud import WordCloud
import matplotlib.pyplot as plt

docs = Path.home() / "etherverse" / "docs"
analytics = Path.home() / "etherverse" / "analytics" / "dreams"
analytics.mkdir(parents=True, exist_ok=True)

dreams = (docs / "dreams_idle.md").read_text(encoding="utf-8")
words = " ".join(re.findall(r"\b[A-Za-z]{4,}\b", dreams))
if words:
    cloud = WordCloud(width=1600, height=900, background_color="black", colormap="plasma").generate(words)
    img_path = analytics / f"dream_cloud_{datetime.date.today()}.png"
    cloud.to_file(img_path)
    print(f"[✓] Dream cloud saved: {img_path}")
else:
    print("[!] No dream data found.")
