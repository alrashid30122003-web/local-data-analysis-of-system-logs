# Assignment II: Local Office Communication System

**Git Nickname / Author**: `alrashid30122003-web`  
**Branch Name**: `local-office-communication-system-alrashid30122003-web` / `local-data-analysis-of-system-logs-alrashid30122003-web`  
**Project Goal**: Set up local email infrastructure and network resource sharing (file shares with Role-Based Access Control and shared network printing) using containerized Docker Desktop services on Windows.

---

## 📋 Task Checklist & Status

- [x] **Local Mail Server**: Installed & configured Postfix/IMAP via `docker-mailserver` on domain `localoffice.local`.
- [x] **5 Email User Accounts**: Provisioned `admin`, `user1`, `user2`, `hr`, and `finance`.
- [x] **Mail Client Configuration**: Endpoints configured for SMTP (Ports 25/587) and IMAP (Port 143).
- [x] **Aliases & Limits**: Configured `support@localoffice.local` alias forwarding to `admin` and set **10 MB** maximum attachment size limit (`POSTFIX_MESSAGE_SIZE_LIMIT=10485760`).
- [x] **Role-Based File Sharing**: Configured Linux Samba container with `Public` (all users), `HR_Share` (HR role only), and `Finance_Share` (Finance role only).
- [x] **Network Printer Sharing**: Configured CUPS network container exposing `Virtual_PDF_Printer` via IPP on port `631`.
- [x] **RBAC Simulation & Verification**: Logged and verified access isolation (`hr_user` GRANTED to `HR_Share`, `fin_user` DENIED).
- [x] **Documentation & Manuals**: Complete [USER_MANUAL.md](./USER_MANUAL.md) and [DELIVERABLES_EVIDENCE.md](./DELIVERABLES_EVIDENCE.md) created.

---

## 📁 Repository Directory Structure

```
Assignment_2_Local_Office_Communication_System/
├── README.md               # Main project overview & assignment documentation
├── DELIVERABLES_EVIDENCE.md # Verification evidence, access logs, and test outputs
├── USER_MANUAL.md          # User operational manual for mail, Samba, and CUPS printer
├── docker-compose.yml      # Orchestration for mailserver, samba, and cups containers
├── setup_and_validate.ps1  # Automated setup and full system validation script
├── config/
│   └── mailserver/         # Postfix account credentials & alias mapping configurations
└── docker/
    ├── cups/               # Dockerfile & configuration for CUPS network printing
    └── samba/              # Dockerfile & smb.conf for Role-Based Access Control shares
```

---

## 🚀 Quickstart & Deployment Instructions

### Prerequisites
- Windows 10 / 11 with **Docker Desktop** installed and running.
- PowerShell 5.1 or 7+.

### Automated One-Click Setup & Validation
Run the PowerShell script from the root directory:
```powershell
.\setup_and_validate.ps1
```

This script will automatically:
1. Verify Docker daemon availability.
2. Build and start all 3 Docker services (`mailserver`, `samba`, `cups`).
3. Provision all 5 email accounts and the `support@localoffice.local` alias.
4. Execute automated network port checks, Samba share RBAC isolation tests, and printer connectivity checks.

---

## 📖 User Manual & Evidence Links

- **User Manual**: Refer to [USER_MANUAL.md](./USER_MANUAL.md) for detailed credentials, client setup instructions, share mapping commands, and printer connections.
- **Evidence & Verification Logs**: Refer to [DELIVERABLES_EVIDENCE.md](./DELIVERABLES_EVIDENCE.md) for execution logs, active Postfix settings, and Samba RBAC access test results.
