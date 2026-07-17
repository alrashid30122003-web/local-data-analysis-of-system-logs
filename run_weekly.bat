@echo off
cd /d "%~dp0"
if not exist reports mkdir reports
python analyze_logs.py >> reports\weekly_run.log 2>&1
