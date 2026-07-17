# Local Data Analysis of System Logs

**Student:** Mohammed Thayyab Yakub  
**GitHub username:** `alrashid30122003-web`  
**Branch:** `local-data-analysis-of-system-logs-alrashid30122003-web`

## Important data note

The included CSV is a **synthetic Windows-style dataset** created so the project can run immediately.  
For a final submission requiring real local data, export Windows Event Viewer logs to CSV and replace:

`data/sample_windows_system_logs.csv`

Keep these columns:

- Level
- Date and Time
- Source
- Event ID
- Task Category
- Message

## Setup on Windows

```powershell
git checkout -b local-data-analysis-of-system-logs-alrashid30122003-web
python -m venv .venv
.venv\Scripts\Activate.ps1
pip install -r requirements.txt
python analyze_logs.py
```

- Install requirements from `requirements.txt`
- Run `python analyze_logs.py` to generate charts and the HTML report
- The HTML report is saved to `reports/log_analysis_report.html`
- The charts are saved to the `charts/` folder

Open `reports/log_analysis_report.html` in a browser.

## Export a real Windows log

1. Open **Event Viewer**.
2. Select **Windows Logs → System** or **Application**.
3. Choose **Save All Events As** or export/copy the required fields to CSV.
4. Replace the sample CSV and rerun `python analyze_logs.py`.

## Outputs

- Log-level frequency chart
- Top event sources chart
- Daily event trend chart
- Offline HTML report
- Weekly automation scripts
