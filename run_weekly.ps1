$ProjectDir = Split-Path -Parent $MyInvocation.MyCommand.Path
Set-Location $ProjectDir
python .\analyze_logs.py *>> .\reports\weekly_run.log
