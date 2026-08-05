#!/bin/bash
set -e

# Create share directories
mkdir -p /shares/public /shares/hr /shares/finance
chmod 777 /shares/public
chmod 770 /shares/hr /shares/finance

# Function to add smb user safely
add_smb_user() {
    local username=$1
    local password=$2
    if ! id "$username" &>/dev/null; then
        adduser -D -H "$username" 2>/dev/null || useradd -M -s /sbin/nologin "$username"
    fi
    (echo "$password"; echo "$password") | smbpasswd -a -s "$username"
}

# Create accounts for RBAC
# Requirements specify: admin, user1, user2, hr, finance, hr_user, fin_user
add_smb_user "admin" "AdminPassword123!"
add_smb_user "user1" "User1Password123!"
add_smb_user "user2" "User2Password123!"
add_smb_user "hr" "HrPassword123!"
add_smb_user "hr_user" "HrPassword123!"
add_smb_user "finance" "FinPassword123!"
add_smb_user "fin_user" "FinPassword123!"

# Set ownership
chown -R hr:hr /shares/hr 2>/dev/null || true
chown -R finance:finance /shares/finance 2>/dev/null || true

echo "[Samba] Users created successfully."
echo "[Samba] Starting Samba smbd daemon..."

exec smbd --foreground --no-process-group --debug-stdout
