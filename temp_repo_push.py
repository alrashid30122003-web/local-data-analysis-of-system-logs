import os
import subprocess
import urllib.request
import urllib.error

cwd = os.getcwd()
git = r'C:\Program Files\Microsoft Visual Studio\2022\Community\Common7\IDE\CommonExtensions\Microsoft\TeamFoundation\Team Explorer\Git\cmd\git.exe'
remote_url = 'https://github.com/alrashid30122003-web/local-data-analysis-of-system-logs.git'
branch = 'local-data-analysis-of-system-logs-alrashid30122003-web'

print('cwd', cwd)
print('git path exists', os.path.exists(git))

for cmd in [[git, '--version'], [git, 'status', '--short', '--branch'], [git, 'remote', '-v']]:
    print('\nCMD:', cmd)
    p = subprocess.run(cmd, cwd=cwd, capture_output=True, text=True)
    print('RC', p.returncode)
    print('OUT', p.stdout)
    print('ERR', p.stderr)

print('\nChecking repository existence via GitHub API')
req = urllib.request.Request(remote_url, method='HEAD', headers={'User-Agent': 'Python'})
try:
    with urllib.request.urlopen(req, timeout=15) as r:
        print('HEAD status', r.status)
except urllib.error.HTTPError as e:
    print('HEAD HTTPError', e.code)
    try:
        print('message', e.read().decode('utf-8', errors='ignore'))
    except Exception:
        pass
except Exception as e:
    print('HEAD error', type(e).__name__, e)

print('\nAttempting git push')
cmd = [git, 'push', '-u', 'origin', branch]
p = subprocess.run(cmd, cwd=cwd, capture_output=True, text=True)
print('RC', p.returncode)
print('OUT', p.stdout)
print('ERR', p.stderr)
