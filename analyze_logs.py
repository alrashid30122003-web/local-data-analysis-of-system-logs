from pathlib import Path
import pandas as pd
import matplotlib.pyplot as plt

BASE = Path(__file__).resolve().parent
INPUT_FILE = BASE / "data" / "sample_windows_system_logs.csv"
CHART_DIR = BASE / "charts"
REPORT_DIR = BASE / "reports"
CHART_DIR.mkdir(exist_ok=True)
REPORT_DIR.mkdir(exist_ok=True)

def load_logs(path: Path) -> pd.DataFrame:
    df = pd.read_csv(path)
    required = {"Level", "Date and Time", "Source", "Event ID", "Message"}
    missing = required.difference(df.columns)
    if missing:
        raise ValueError(f"Missing required columns: {sorted(missing)}")
    df["Level"] = df["Level"].astype(str).str.strip()
    df["Source"] = df["Source"].astype(str).str.strip()
    df["Date and Time"] = pd.to_datetime(df["Date and Time"], errors="coerce")
    df = df.dropna(subset=["Date and Time"])
    df["Date"] = df["Date and Time"].dt.date
    return df

def create_charts(df: pd.DataFrame) -> None:
    levels = ["Information", "Warning", "Error", "Critical"]
    level_counts = df["Level"].value_counts().reindex(levels, fill_value=0)

    plt.figure(figsize=(8, 5))
    level_counts.plot(kind="bar")
    plt.title("Windows System Log Level Distribution")
    plt.xlabel("Severity Level")
    plt.ylabel("Event Count")
    plt.tight_layout()
    plt.savefig(CHART_DIR / "log_level_frequency.png", dpi=160)
    plt.close()

    top_sources = df["Source"].value_counts().head(10).sort_values()
    plt.figure(figsize=(9, 5.5))
    top_sources.plot(kind="barh")
    plt.title("Top Event Sources")
    plt.xlabel("Event Count")
    plt.ylabel("Source")
    plt.tight_layout()
    plt.savefig(CHART_DIR / "top_event_sources.png", dpi=160)
    plt.close()

    daily = df.groupby("Date").size()
    plt.figure(figsize=(10, 5))
    daily.plot(kind="line", marker="o", markersize=3)
    plt.title("Daily Event Trend")
    plt.xlabel("Date")
    plt.ylabel("Number of Events")
    plt.xticks(rotation=45)
    plt.tight_layout()
    plt.savefig(CHART_DIR / "daily_event_trend.png", dpi=160)
    plt.close()

def create_report(df: pd.DataFrame) -> None:
    levels = ["Information", "Warning", "Error", "Critical"]
    counts = df["Level"].value_counts().reindex(levels, fill_value=0)
    summary = pd.DataFrame({
        "Metric": ["Total Events", "Unique Sources", "Start Date", "End Date",
                   "Information", "Warnings", "Errors", "Critical", "Failed Logons (4625)"],
        "Value": [len(df), df["Source"].nunique(), df["Date and Time"].min().date(),
                  df["Date and Time"].max().date(), counts["Information"], counts["Warning"],
                  counts["Error"], counts["Critical"], (df["Event ID"] == 4625).sum()]
    })

    html = f"""<!doctype html>
<html><head><meta charset="utf-8"><title>Log Analysis Report</title>
<style>
body{{font-family:Arial;max-width:1000px;margin:40px auto;line-height:1.5}}
table{{border-collapse:collapse;width:100%}}th,td{{border:1px solid #bbb;padding:8px}}
img{{max-width:100%;margin:15px 0 30px}}
.note{{background:#fff3cd;padding:12px}}
</style></head><body>
<h1>Local Data Analysis of System Logs</h1>
<p><strong>Student:</strong> Mohammed Thayyab Yakub</p>
<p class="note"><strong>Data note:</strong> The included dataset is synthetic and should be replaced with a real Windows Event Viewer CSV when required.</p>
<h2>Summary</h2>{summary.to_html(index=False, border=0)}
<h2>Log Level Frequency</h2><img src="../charts/log_level_frequency.png">
<h2>Top Event Sources</h2><img src="../charts/top_event_sources.png">
<h2>Daily Event Trend</h2><img src="../charts/daily_event_trend.png">
<h2>Top Sources</h2>{df["Source"].value_counts().head(10).rename("Count").to_frame().to_html(border=0)}
</body></html>"""
    (REPORT_DIR / "log_analysis_report.html").write_text(html, encoding="utf-8")

if __name__ == "__main__":
    logs = load_logs(INPUT_FILE)
    create_charts(logs)
    create_report(logs)
    print(f"Completed analysis of {len(logs):,} events.")
    print(f"Open: {REPORT_DIR / 'log_analysis_report.html'}")
