#!/usr/bin/env bash
# Install one of the bundled SDDM themes.
# Usage:  sudo ./install.sh <theme-id>
# Example: sudo ./install.sh marvel
set -euo pipefail

THEME="${1:-}"
if [[ -z "$THEME" || ! -d "$(dirname "$0")/$THEME" ]]; then
  echo "Available themes:"
  for d in "$(dirname "$0")"/*/; do
    [[ -f "$d/metadata.desktop" ]] && echo "  - $(basename "$d")"
  done
  echo
  echo "Usage: sudo $0 <theme-id>"
  exit 1
fi

if [[ $EUID -ne 0 ]]; then
  echo "Run as root: sudo $0 $THEME"; exit 1
fi

SRC="$(cd "$(dirname "$0")/$THEME" && pwd)"
DEST="/usr/share/sddm/themes/$THEME"

echo "→ Installing '$THEME' to $DEST"
rm -rf "$DEST"
mkdir -p "$DEST"
cp -r "$SRC"/. "$DEST"/

CONF="/etc/sddm.conf"
echo "→ Setting Current=$THEME in $CONF"
touch "$CONF"
if grep -q '^\[Theme\]' "$CONF"; then
  if grep -q '^Current=' "$CONF"; then
    sed -i "s|^Current=.*|Current=$THEME|" "$CONF"
  else
    sed -i "/^\[Theme\]/a Current=$THEME" "$CONF"
  fi
else
  printf '\n[Theme]\nCurrent=%s\n' "$THEME" >> "$CONF"
fi

echo "✓ Done. Test with:  sddm-greeter --test-mode --theme $DEST"
echo "  Then reboot or restart sddm:  systemctl restart sddm"
