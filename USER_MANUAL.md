# User Manual: Local Office Communication System

Welcome to the **Local Office Communication System** manual. This document provides complete operational, administration, and end-user setup instructions for the local infrastructure containerized using Docker Desktop on Windows.

---

## 1. Architecture Overview

The system integrates three core office communication and resource-sharing services running as Docker containers:

```
                  +-------------------------------------------------------+
                  |               Docker Desktop on Windows               |
                  |                                                       |
                  |  +--------------------+  +-------------------------+  |
                  |  |  docker-mailserver |  |       Samba SMB         |  |
                  |  | localoffice.local  |  |  Role-Based File Shares |  |
                  |  | (SMTP 25/587, IMAP)|  |  (Public, HR, Finance)  |  |
                  |  +---------+----------+  +------------+------------+  |
                  |            |                          |               |
                  |            |  +--------------------+  |               |
                  |            +--|    CUPS Printer    |--+               |
                  |               |  Virtual PDF (631) |                  |
                  |               +--------------------+                  |
                  +-------------------------------------------------------+
```

### Infrastructure Summary

| Service | Port(s) | Protocol / Interface | Main Features |
| :--- | :--- | :--- | :--- |
| **Mail Server** | `25`, `587`, `143`, `993` | SMTP, Submission, IMAP, IMAPS | Domain `localoffice.local`, 5 user accounts, `support` alias, 10MB attachment limit. |
| **Samba File Shares** | `1139`, `1445` | SMB / CIFS | Role-Based Access Control (RBAC) across `Public`, `HR_Share`, and `Finance_Share`. |
| **Network Printer** | `631` | IPP / HTTP / CUPS Web UI | Virtual PDF Printer shared on `http://localhost:631/printers/Virtual_PDF_Printer`. |

---

## 2. Prerequisites & Quickstart

### Prerequisites
- **Operating System**: Windows 10 or Windows 11
- **Runtimes**: Docker Desktop (with Linux container mode active) & PowerShell 5.1 or 7+

### Automated Setup & Validation
1. Open PowerShell as Administrator in the project directory:
   ```powershell
   cd c:\Users\nayan\OneDrive\Desktop\NJ_PROJ
   ```
2. Run the automated setup and validation script:
   ```powershell
   .\setup_and_validate.ps1
   ```
3. The script will automatically:
   - Verify Docker daemon status.
   - Build and start all 3 Docker services (`mailserver`, `samba`, `cups`).
   - Provision all 5 mail accounts and the `support` alias.
   - Execute automated port, RBAC share, and printer connectivity checks.

---

## 3. Mail Server (`localoffice.local`)

### Account Credentials
The mail server runs `docker-mailserver` for the domain `localoffice.local`. The following 5 user accounts are provisioned:

| User Account | Email Address | Default Password |
| :--- | :--- | :--- |
| **Admin** | `admin@localoffice.local` | `AdminPassword123!` |
| **User 1** | `user1@localoffice.local` | `User1Password123!` |
| **User 2** | `user2@localoffice.local` | `User2Password123!` |
| **HR** | `hr@localoffice.local` | `HrPassword123!` |
| **Finance** | `finance@localoffice.local` | `FinPassword123!` |

### Email Alias
- **Alias Address**: `support@localoffice.local`
- **Destination**: `admin@localoffice.local`
- *Any email sent to `support@localoffice.local` is automatically delivered to the `admin` inbox.*

### Attachment Size Limit
- **Max Attachment Size**: **10 MB (10,485,760 bytes)**
- Enforced via Postfix configuration: `message_size_limit = 10485760`.

### Client Configuration (Thunderbird / Outlook / Apple Mail)
To connect your email client:
- **Incoming (IMAP) Server**: `localhost` (Port `143`, Security: None/STARTTLS)
- **Outgoing (SMTP) Server**: `localhost` (Port `25` or `587`, Security: None/STARTTLS)
- **Username**: Full email address (e.g., `user1@localoffice.local`)

---

## 4. Shared Resources & Role-Based SMB File Shares

Samba provides centralized file storage with strict Role-Based Access Control (RBAC).

### Access Control Matrix

| Share Name | UNC Path | Access Level | Authorized Users |
| :--- | :--- | :--- | :--- |
| **Public** | `\\localhost\Public` | **Read / Write (All)** | Everyone (Guest & Authenticated) |
| **HR_Share** | `\\localhost\HR_Share` | **Restricted (HR Only)** | `hr`, `hr_user`, `admin` |
| **Finance_Share** | `\\localhost\Finance_Share` | **Restricted (Finance Only)** | `finance`, `fin_user`, `admin` |

### Accessing Shares on Windows File Explorer
1. Press `Win + R` to open the Run dialog.
2. Enter the share UNC path (e.g., `\\localhost\Public` or `\\localhost\HR_Share`).
3. When prompted for credentials, enter the appropriate account:
   - **HR Share**: User `hr` / Password `HrPassword123!`
   - **Finance Share**: User `finance` / Password `FinPassword123!`
   - **Admin Access**: User `admin` / Password `AdminPassword123!`

### Mounting Shares via PowerShell
```powershell
# Mount Public Share as drive P:
New-PSDrive -Name "P" -PSProvider "FileSystem" -Root "\\localhost\Public" -Persist

# Mount HR Share as drive H: using HR credentials
$secPass = ConvertTo-SecureString "HrPassword123!" -AsPlainText -Force
$cred = New-Object System.Management.Automation.PSCredential("hr", $secPass)
New-PSDrive -Name "H" -PSProvider "FileSystem" -Root "\\localhost\HR_Share" -Credential $cred -Persist
```

---

## 5. Network Printer Sharing (CUPS)

The network printing service exposes a virtual PDF printer via CUPS on port **631**.

### Printer Endpoint Information
- **CUPS Web Administration Interface**: `http://localhost:631`
- **Virtual Printer Name**: `Virtual_PDF_Printer`
- **IPP / HTTP Connection URL**: `http://localhost:631/printers/Virtual_PDF_Printer`

### Adding Network Printer on Windows
1. Open **Settings** > **Bluetooth & devices** > **Printers & scanners**.
2. Click **Add device**, then select **Add manually**.
3. Choose **Select a shared printer by name**.
4. Enter the URL:
   `http://localhost:631/printers/Virtual_PDF_Printer`
5. Select standard generic printer driver (e.g., *Generic / Text Only* or *MS Publisher Color Printer*).
6. Documents submitted to this printer are rendered directly to PDF format inside the container volume (`cups_pdf_out`).

---

## 6. Maintenance & Troubleshooting

### Operational Commands
- **Check Container Status**:
  ```powershell
  docker compose ps
  ```
- **View Container Logs**:
  ```powershell
  docker compose logs -f
  ```
- **Restart Services**:
  ```powershell
  docker compose restart
  ```
- **Stop Infrastructure**:
  ```powershell
  docker compose down
  ```

### Troubleshooting Checklist
1. **Port Conflicts**:
   - Ensure ports `25`, `143`, `445`, `631` are not occupied by local Windows services (e.g. IIS, local SMTP, or Windows Print Spooler on port 631).
2. **Mail Alias Verification**:
   - Run `docker exec office-mailserver setup alias list` to verify `support@localoffice.local` mapping.
3. **Samba Permission Denied**:
   - Ensure you clear cached Windows network credentials (`net use * /delete`) when switching between `hr` and `finance` test accounts.
