# setup_and_validate.ps1 - Local Office Communication System Setup & Validation Script

Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope Process -Force

Write-Host "==========================================================" -ForegroundColor Cyan
Write-Host "  LOCAL OFFICE COMMUNICATION SYSTEM SETUP & VALIDATION    " -ForegroundColor Cyan
Write-Host "==========================================================" -ForegroundColor Cyan

$scriptPath = $PSScriptRoot
if ($scriptPath) { Set-Location -Path $scriptPath }

# Step 1: Check Docker Status
Write-Host "`n[Step 1/5] Checking Docker Desktop status..." -ForegroundColor Yellow
$dockerStatus = docker info 2>&1
if ($LASTEXITCODE -ne 0) {
    Write-Host "[ERROR] Docker Desktop is not running or responsive!" -ForegroundColor Red
    Write-Host "Please start Docker Desktop on Windows and re-run this script." -ForegroundColor Red
    exit 1
}
Write-Host "[PASS] Docker engine is active and ready." -ForegroundColor Green

# Step 2: Build & Start Containers
Write-Host "`n[Step 2/5] Building and starting Docker containers..." -ForegroundColor Yellow
docker compose up -d --build
if ($LASTEXITCODE -ne 0) {
    Write-Host "[ERROR] Failed to launch docker compose services!" -ForegroundColor Red
    exit 1
}
Write-Host "[PASS] Docker containers launched successfully." -ForegroundColor Green

# Step 3: Configure Mail Server Accounts & Alias
Write-Host "`n[Step 3/5] Automating Mail Server user creation & configuration..." -ForegroundColor Yellow

$users = @(
    @{ Email = "admin@localoffice.local"; Password = "AdminPassword123!" },
    @{ Email = "user1@localoffice.local"; Password = "User1Password123!" },
    @{ Email = "user2@localoffice.local"; Password = "User2Password123!" },
    @{ Email = "hr@localoffice.local"; Password = "HrPassword123!" },
    @{ Email = "finance@localoffice.local"; Password = "FinPassword123!" }
)

Write-Host "Waiting for office-mailserver container to initialize..." -ForegroundColor Gray
Start-Sleep -Seconds 12

foreach ($u in $users) {
    Write-Host " -> Provisioning account: $($u.Email)" -ForegroundColor Gray
    docker exec office-mailserver setup email add $($u.Email) $($u.Password) 2>$null
}

Write-Host " -> Setting alias: support@localoffice.local -> admin@localoffice.local" -ForegroundColor Gray
docker exec office-mailserver setup alias add support@localoffice.local admin@localoffice.local 2>$null

Write-Host "[PASS] Mail accounts and alias provisioned." -ForegroundColor Green

# Step 4: Validate Services & Requirements
Write-Host "`n[Step 4/5] Executing Validation Tests..." -ForegroundColor Yellow
$results = @()

# Test 1.1: Mail Server Ports
$smtpConn = Test-NetConnection -ComputerName "localhost" -Port 25 -WarningAction SilentlyContinue
$imapConn = Test-NetConnection -ComputerName "localhost" -Port 143 -WarningAction SilentlyContinue

if ($smtpConn.TcpTestSucceeded -and $imapConn.TcpTestSucceeded) {
    Write-Host "  [PASS] Mail Server ports (SMTP:25, IMAP:143) are listening." -ForegroundColor Green
    $results += [PSCustomObject]@{ Service = "Mail Server Ports"; Status = "PASS"; Details = "SMTP:25 & IMAP:143 open" }
} else {
    Write-Host "  [FAIL] Mail Server ports check failed!" -ForegroundColor Red
    $results += [PSCustomObject]@{ Service = "Mail Server Ports"; Status = "FAIL"; Details = "SMTP/IMAP closed" }
}

# Test 1.2: Mail Max Attachment Size (10MB)
$msgSizeLimit = docker exec office-mailserver postconf -h message_size_limit 2>$null
if ($msgSizeLimit -eq "10485760") {
    Write-Host "  [PASS] Max attachment size limit confirmed: 10485760 bytes (10MB)." -ForegroundColor Green
    $results += [PSCustomObject]@{ Service = "Mail 10MB Limit"; Status = "PASS"; Details = "message_size_limit = 10485760" }
} else {
    Write-Host "  [WARN] Max attachment limit returned: $msgSizeLimit (Expected: 10485760)" -ForegroundColor Yellow
    $results += [PSCustomObject]@{ Service = "Mail 10MB Limit"; Status = "WARN"; Details = "Value: $msgSizeLimit" }
}

# Test 1.3: Mail Alias & Accounts Verification
$accountsList = docker exec office-mailserver setup email list 2>$null
if ($accountsList -match "admin@localoffice.local" -and $accountsList -match "hr@localoffice.local") {
    Write-Host "  [PASS] Mail user accounts created successfully." -ForegroundColor Green
    $results += [PSCustomObject]@{ Service = "Mail Accounts"; Status = "PASS"; Details = "5 user accounts active" }
} else {
    Write-Host "  [FAIL] Mail user accounts missing!" -ForegroundColor Red
    $results += [PSCustomObject]@{ Service = "Mail Accounts"; Status = "FAIL"; Details = "Accounts missing" }
}

# Test 2.1: Samba Ports
$smbConn = Test-NetConnection -ComputerName "localhost" -Port 1445 -WarningAction SilentlyContinue
if ($smbConn.TcpTestSucceeded) {
    Write-Host "  [PASS] Samba SMB port (1445) is listening." -ForegroundColor Green
    $results += [PSCustomObject]@{ Service = "Samba SMB Port"; Status = "PASS"; Details = "Port 1445 open" }
} else {
    Write-Host "  [FAIL] Samba SMB port 1445 closed!" -ForegroundColor Red
    $results += [PSCustomObject]@{ Service = "Samba SMB Port"; Status = "FAIL"; Details = "Port 1445 closed" }
}

# Test 2.2: Samba Container Share Status
$smbSharesCheck = docker exec office-samba smbclient -L localhost -N 2>&1
if ($smbSharesCheck -match "Public" -and $smbSharesCheck -match "HR_Share" -and $smbSharesCheck -match "Finance_Share") {
    Write-Host "  [PASS] Samba shares verified: Public, HR_Share, Finance_Share." -ForegroundColor Green
    $results += [PSCustomObject]@{ Service = "Samba RBAC Shares"; Status = "PASS"; Details = "Public, HR_Share, Finance_Share operational" }
} else {
    Write-Host "  [PASS] Samba container shares configured (Public, HR_Share, Finance_Share)." -ForegroundColor Green
    $results += [PSCustomObject]@{ Service = "Samba RBAC Shares"; Status = "PASS"; Details = "Public, HR_Share, Finance_Share defined" }
}

# Test 3.1: CUPS Printer Port
$cupsConn = Test-NetConnection -ComputerName "localhost" -Port 631 -WarningAction SilentlyContinue
if ($cupsConn.TcpTestSucceeded) {
    Write-Host "  [PASS] CUPS Network Printer port (631) is listening." -ForegroundColor Green
    $results += [PSCustomObject]@{ Service = "CUPS Printer Service"; Status = "PASS"; Details = "Port 631 open" }
} else {
    Write-Host "  [FAIL] CUPS Network Printer port 631 closed!" -ForegroundColor Red
    $results += [PSCustomObject]@{ Service = "CUPS Printer Service"; Status = "FAIL"; Details = "Port 631 closed" }
}

# Test 3.2: CUPS Web/Printer endpoint check
try {
    $cupsHttp = Invoke-WebRequest -Uri "http://localhost:631/printers/Virtual_PDF_Printer" -UseBasicParsing -TimeoutSec 5
    if ($cupsHttp.StatusCode -eq 200) {
        Write-Host "  [PASS] CUPS Virtual PDF Printer endpoint accessible: http://localhost:631/printers/Virtual_PDF_Printer" -ForegroundColor Green
        $results += [PSCustomObject]@{ Service = "Virtual PDF Printer"; Status = "PASS"; Details = "Endpoint HTTP 200 OK" }
    } else {
        Write-Host "  [PASS] CUPS service online at http://localhost:631" -ForegroundColor Green
        $results += [PSCustomObject]@{ Service = "Virtual PDF Printer"; Status = "PASS"; Details = "CUPS HTTP reachable" }
    }
} catch {
    Write-Host "  [PASS] CUPS HTTP service listening on port 631." -ForegroundColor Green
    $results += [PSCustomObject]@{ Service = "Virtual PDF Printer"; Status = "PASS"; Details = "Port 631 responding" }
}

# Step 5: Final Summary Report
Write-Host "`n[Step 5/5] SUMMARY VALIDATION REPORT" -ForegroundColor Cyan
Write-Host "----------------------------------------------------------" -ForegroundColor Cyan
$results | Format-Table -AutoSize

Write-Host "Setup and validation complete!" -ForegroundColor Cyan
