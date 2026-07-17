from pathlib import Path
import numpy as np
import pandas as pd

rng = np.random.default_rng(42)
base = Path(__file__).resolve().parent
out = base / "data" / "sample_windows_system_logs.csv"
out.parent.mkdir(exist_ok=True)

sources = [
    "Microsoft-Windows-DistributedCOM", "Service Control Manager",
    "Microsoft-Windows-WindowsUpdateClient", "Microsoft-Windows-Kernel-Power",
    "Microsoft-Windows-Security-Auditing", "Application Error", "Winlogon"
]
levels = ["Information", "Warning", "Error", "Critical"]

rows = []
for ts in pd.date_range("2026-05-01", "2026-06-30", freq="h"):
    n = rng.poisson(7 if ts.day in (3, 12, 19) else 2)
    for _ in range(n):
        src = rng.choice(sources)
        level = rng.choice(levels, p=[0.61, 0.27, 0.105, 0.015])
        event_id = int(rng.choice([19, 41, 1000, 4624, 4625, 7000, 10016]))
        rows.append({
            "Level": level,
            "Date and Time": ts + pd.Timedelta(minutes=int(rng.integers(0, 60))),
            "Source": src,
            "Event ID": event_id,
            "Task Category": "None",
            "Message": "Synthetic Windows-style event generated for coursework demonstration."
        })

pd.DataFrame(rows).to_csv(out, index=False)
print(f"Created {out}")
