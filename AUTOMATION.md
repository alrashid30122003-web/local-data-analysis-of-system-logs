# Weekly Automation on Windows

## Option 1: Task Scheduler GUI

1. Open **Task Scheduler**.
2. Click **Create Basic Task**.
3. Name: `Weekly System Log Analysis`.
4. Trigger: **Weekly**, choose Monday at 7:00 AM.
5. Action: **Start a program**.
6. Program/script: select `run_weekly.bat`.
7. Start in: enter the full project folder path.
8. Finish and test the task.

## Option 2: PowerShell script

Use `run_weekly.ps1` as the program action:

```text
powershell.exe
```

Arguments:

```text
-ExecutionPolicy Bypass -File "C:\path\to\project\run_weekly.ps1"
```
