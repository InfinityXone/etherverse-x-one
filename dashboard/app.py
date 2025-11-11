#!/usr/bin/env python3
"""
Etherverse Dashboard
Displays the Collective Chronicle and a Harmony graph from harmony_index.csv
"""
from flask import Flask, render_template_string
import pandas as pd, os, io, matplotlib.pyplot as plt

app = Flask(__name__)
DOCS = os.path.expanduser("~/etherverse/docs")
HARMONY = os.path.join(DOCS, "harmony_index.csv")
CHRONICLE = os.path.join(DOCS, "collective_chronicle.md")

TEMPLATE = """
<html>
<head><title>Etherverse Dashboard</title></head>
<body style="background:#000;color:#fff;font-family:sans-serif;">
<h1>🌌 Etherverse Dashboard</h1>
<h2>Harmony Over Time</h2>
<img src="/harmony.png"><hr>
<h2>Latest Chronicle</h2>
<pre style="white-space:pre-wrap;">{{ chronicle }}</pre>
</body></html>
"""

@app.route("/")
def index():
    if os.path.exists(CHRONICLE):
        with open(CHRONICLE, "r") as f:
            chron = f.read()[-6000:]
    else:
        chron = "No chronicle yet."
    return render_template_string(TEMPLATE, chronicle=chron)

@app.route("/harmony.png")
def harmony_plot():
    if not os.path.exists(HARMONY):
        return app.response_class(b"", mimetype="image/png")
    df = pd.read_csv(HARMONY)
    fig, ax = plt.subplots()
    ax.plot(df["date"], df["positive_ratio"], marker="o", color="#00ffcc")
    ax.set_title("Harmony Index")
    ax.set_ylabel("Positive Ratio")
    ax.set_xlabel("Date")
    ax.grid(True, color="#444")
    buf = io.BytesIO()
    plt.tight_layout()
    plt.savefig(buf, format="png", facecolor="#000")
    plt.close(fig)
    buf.seek(0)
    return app.response_class(buf.read(), mimetype="image/png")

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=8080)
