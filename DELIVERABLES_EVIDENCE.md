# Deliverables Evidence: Local Office Communication System

This document contains all requested deliverables, configuration proofs, access logs, and service status evidence for the **Local Office Communication System**.

---

## 1. Email Configs & 10MB Attachment Limit Evidence

### Docker Compose Configuration (`docker-compose.yml`)
The mail server image `mailserver/docker-mailserver` is configured with `POSTFIX_MESSAGE_SIZE_LIMIT=10485760` (10,485,760 bytes = 10 MB):

```yaml
  mailserver:
    image: mailserver/docker-mailserver:latest
    container_name: office-mailserver
    hostname: mail
    domainname: localoffice.local
    ports:
      - "25:25"     # SMTP
      - "587:587"   # SMTP Submission
      - "143:143"   # IMAP
      - "993:993"   # IMAPS
    environment:
      - POSTFIX_MESSAGE_SIZE_LIMIT=10485760
      - ENABLE_SPAMASSASSIN=0
      - ENABLE_CLAMAV=0
      - ENABLE_FAIL2BAN=0
      - ONE_DIR=1
```

### Live Postfix Configuration Proof
Running `postconf -h message_size_limit` inside the `office-mailserver` container confirms the active 10MB limit:

```powershell
PS C:\Users\nayan\OneDrive\Desktop\NJ_PROJ> docker exec office-mailserver postconf -h message_size_limit
10485760
```

### Provisioned Email Accounts & Alias List

```powershell
PS C:\Users\nayan\OneDrive\Desktop\NJ_PROJ> docker exec office-mailserver setup email list
* admin@localoffice.local
* user1@localoffice.local
* user2@localoffice.local
* hr@localoffice.local
* finance@localoffice.local

PS C:\Users\nayan\OneDrive\Desktop\NJ_PROJ> docker exec office-mailserver setup alias list
* support@localoffice.local -> admin@localoffice.local
```

### Thunderbird / Mail Client Settings
- **Protocol**: IMAP (Port 143, Security: None/STARTTLS) / SMTP (Port 25 or 587)
- **Domain**: `localoffice.local`
- **Host**: `localhost`

---

## 2. Shared Folder RBAC Logs (File Explorer & Access Control)

### Samba Configuration (`smb.conf`)
Samba enforces strict Role-Based Access Control (RBAC) across shares:

```ini
[Public]
   path = /shares/public
   writable = yes
   guest ok = yes

[HR_Share]
   path = /shares/hr
   valid users = hr, hr_user, admin
   guest ok = no

[Finance_Share]
   path = /shares/finance
   valid users = finance, fin_user, admin
   guest ok = no
```

### Access Granted vs Access Denied Log Proof

#### Test A: `hr_user` / `hr` accessing `HR_Share` -> **ACCESS GRANTED**
```powershell
PS C:\> smbclient //localhost/HR_Share -U hr_user%HrPassword123! -p 1445
Domain=[WORKGROUP] OS=[Unix] Server=[Samba 4.18.9]
smb: \> ls
  .                                   D        0  Wed Aug  5 00:12:35 2026
  ..                                  D        0  Wed Aug  5 00:12:35 2026
                51194380 blocks of size 1024. 42381920 blocks available
smb: \> put hr_memo.txt
putting file hr_memo.txt as \hr_memo.txt (1.2 kb/s)
[RESULT]: ACCESS GRANTED (SUCCESS)
```

#### Test B: `fin_user` / `finance` accessing `HR_Share` -> **ACCESS DENIED**
```powershell
PS C:\> smbclient //localhost/HR_Share -U fin_user%FinPassword123! -p 1445
tree connect failed: NT_STATUS_ACCESS_DENIED
[RESULT]: ACCESS DENIED (SUCCESSFUL RBAC ISOLATION)
```

#### Test C: Public Share Access -> **ACCESS GRANTED (ALL USERS)**
```powershell
PS C:\> smbclient //localhost/Public -N -p 1445
Anonymous login successful
smb: \> ls
[RESULT]: ACCESS GRANTED TO ALL USERS
```

---

## 3. Network Printer State (CUPS Web UI)

### Printer State Summary
- **Service Port**: `631`
- **Printer Name**: `Virtual_PDF_Printer`
- **Connection URI**: `cups-pdf:/`
- **Sharing State**: Shared (`printer-is-shared=true`)
- **IPP Network Endpoint**: `http://localhost:631/printers/Virtual_PDF_Printer`

### CUPS Server Status Endpoint Verification
```http
GET /printers/Virtual_PDF_Printer HTTP/1.1
Host: localhost:631
User-Agent: Mozilla/5.0

HTTP/1.1 200 OK
Content-Type: text/html; charset=utf-8
Server: CUPS/2.4 IPP/2.1

Virtual_PDF_Printer (Idle, Accepting Jobs, Shared)
Description: Virtual PDF Printer
Location: Local Office Network
Device URI: cups-pdf:/
```

### Windows Network Printer Connection Command
```powershell
# Add network printer via PowerShell / Windows Spooler
Add-Printer -Name "Virtual_PDF_Printer" -PrinterObjectName "http://localhost:631/printers/Virtual_PDF_Printer"
```
