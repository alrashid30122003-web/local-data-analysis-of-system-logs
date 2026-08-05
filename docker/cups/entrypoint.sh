#!/bin/bash
set -e

echo "[CUPS] Starting CUPS daemon in background..."
cupsd

sleep 2

echo "[CUPS] Configuring Virtual PDF Printer..."
lpadmin -p Virtual_PDF_Printer -v cups-pdf:/ -E -m raw -o printer-is-shared=true || true
cupsctl --share-printers --remote-any --remote-admin || true
lpdefault -d Virtual_PDF_Printer 2>/dev/null || true

echo "[CUPS] Virtual PDF Printer configured successfully."
echo "[CUPS] CUPS Server listening on port 631."

# Stop background cupsd and run in foreground
killall cupsd 2>/dev/null || true
sleep 1
exec cupsd -f
