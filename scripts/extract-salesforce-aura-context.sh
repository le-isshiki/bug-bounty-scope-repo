#!/usr/bin/env bash
set -euo pipefail

TARGET="${1:-https://marketplace.tw.coupangcorp.com/tw/s/}"

echo "[*] Fetching Salesforce community page: $TARGET"
html="$(curl -s "$TARGET")"

echo "[*] Extracting fwuid candidates"
echo "$html" | grep -oE '"fwuid":"[^"]+"' | head -5 || true

echo "[*] Looking for Aura/Apex controller references"
echo "$html" | grep -oE '(apex://|serviceComponent://|ACTION\$)[^"]+' | sort -u | head -50 || true

echo "[*] Done. Copy current fwuid into manual Aura probes."
