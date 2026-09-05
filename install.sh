#!/usr/bin/env bash
# ═══════════════════════════════════════════════════════════════════
#   JOKER53 · SDDM THEME INSTALLER
#   Usage:  sudo ./install.sh [theme-id]
# ═══════════════════════════════════════════════════════════════════
set -euo pipefail

REPO_DIR="$(cd "$(dirname "$0")" && pwd)"
THEMES_DIR="$REPO_DIR"
SDDM_THEMES="/usr/share/sddm/themes"
SDDM_CONF="/etc/sddm.conf"

# ── 256-colour palette ──────────────────────────────────────────────
ESC=$'\033'
RST="${ESC}[0m"
BLD="${ESC}[1m"
DIM="${ESC}[2m"
ITL="${ESC}[3m"

# foreground colours
BLK="${ESC}[30m";  RED="${ESC}[31m";  GRN="${ESC}[32m";  YEL="${ESC}[33m"
BLU="${ESC}[34m";  MAG="${ESC}[35m";  CYN="${ESC}[36m";  WHT="${ESC}[37m"

# bright foreground
BBLK="${ESC}[90m"; BRED="${ESC}[91m"; BGRN="${ESC}[92m"; BYEL="${ESC}[93m"
BBLU="${ESC}[94m"; BMAG="${ESC}[95m"; BCYN="${ESC}[96m"; BWHT="${ESC}[97m"

# 256-colour extras (vivid accent colours)
ORG="${ESC}[38;5;208m"   # orange
PNK="${ESC}[38;5;213m"   # pink
LVN="${ESC}[38;5;135m"   # lavender
TRQ="${ESC}[38;5;51m"    # turquoise
GLD="${ESC}[38;5;220m"   # gold
LME="${ESC}[38;5;154m"   # lime
SKY="${ESC}[38;5;117m"   # sky blue
CRL="${ESC}[38;5;203m"   # coral
MNT="${ESC}[38;5;121m"   # mint
PRP="${ESC}[38;5;141m"   # purple

# background colours (for inline highlights)
BG_BLU="${ESC}[44m"
BG_MAG="${ESC}[45m"
BG_CYN="${ESC}[46m"
BG_GRN="${ESC}[42m"
BG_RED="${ESC}[41m"
BG_YEL="${ESC}[43m"

# ── helpers ─────────────────────────────────────────────────────────
cols()  { tput cols 2>/dev/null || echo 72; }
center(){ local s="$1"; local w=${2:-$(cols)}; local pad=$(( (w - ${#s}) / 2 ))
          printf "%*s%s%*s\n" "$pad" "" "$s" "$pad" ""; }
hline() { local c="${1:-─}"; local w=$(cols); printf '%*s\n' "$w" '' | tr ' ' "$c"; }
hline2(){ printf "${BBLK}"; hline "─"; printf "${RST}"; }

info()  { echo -e "  ${SKY}◆${RST}  $*"; }
ok()    { echo -e "  ${BGRN}✔${RST}  $*"; }
warn()  { echo -e "  ${GLD}⚠${RST}  $*"; }
step()  { echo -e "  ${PNK}▶${RST}  ${BLD}$*${RST}"; }
die()   { echo -e "\n  ${BRED}✖${RST}  ${BRED}${BLD}ERROR:${RST} $*" >&2; exit 1; }

# animated spinner while running a command silently
spin() {
  local msg="$1"; shift
  local frames=('⠋' '⠙' '⠹' '⠸' '⠼' '⠴' '⠦' '⠧' '⠇' '⠏')
  ("$@") &
  local pid=$!
  local i=0
  while kill -0 $pid 2>/dev/null; do
    printf "\r  ${BCYN}%s${RST}  %s…" "${frames[$i]}" "$msg"
    i=$(( (i+1) % ${#frames[@]} ))
    sleep 0.08
  done
  printf "\r  ${BGRN}✔${RST}  %s — ${BGRN}done${RST}\n" "$msg"
  wait $pid
}

# print a coloured progress bar  usage: pbar current total label
pbar() {
  local cur=$1 tot=$2 lbl="${3:-}"
  local w=30
  local fill=$(( cur * w / tot ))
  local empty=$(( w - fill ))
  printf "  ${BBLK}[${BGRN}"
  printf '%0.s█' $(seq 1 $fill 2>/dev/null) 2>/dev/null || true
  printf "${BBLK}"
  printf '%0.s░' $(seq 1 $empty 2>/dev/null) 2>/dev/null || true
  printf "${BBLK}]${RST} ${BLD}%d%%${RST}  %s\n" $(( cur * 100 / tot )) "$lbl"
}

# ── root check ──────────────────────────────────────────────────────
[[ $EUID -eq 0 ]] || die "Run as root:  ${CYN}sudo $0 ${1:-}${RST}"

# ── big banner ──────────────────────────────────────────────────────
clear
echo ""
echo -e "${BBLK}$(hline '═')${RST}"
echo ""
echo -e "${BMAG}${BLD}$(center "   ░░░ JOKER53 · SDDM THEME INSTALLER ░░░   ")${RST}"
echo ""
echo -e "${BBLK}$(hline '═')${RST}"
echo ""
echo -e "$(center "${DIM}${BBLK}Anime · JDM · Cyberpunk · Marvel · Nature · Pixel${RST}")"
echo -e "$(center "${BBLK}${DIM}44 hand-crafted themes · Pure QML · Qt5 & Qt6${RST}")"
echo ""
echo -e "${BBLK}$(hline '─')${RST}"
echo ""

# ── detect Qt version ───────────────────────────────────────────────
detect_qt_version() {
  if pacman -Qq sddm &>/dev/null 2>&1; then
    pacman -Qi sddm 2>/dev/null | grep -q 'qt6' && { echo "6"; return; }
    echo "5"; return
  fi
  if dpkg -l sddm &>/dev/null 2>&1; then
    dpkg -l | grep -q 'sddm-qt6\|qt6-sddm' && { echo "6"; return; }
    echo "5"; return
  fi
  echo "6"
}

QT_VER=$(detect_qt_version)
echo -e "  ${SKY}◈${RST}  SDDM runtime  →  ${BLD}${BCYN}Qt${QT_VER}${RST}"

# ── dependency check ────────────────────────────────────────────────
install_missing() {
  local pm=$1; shift; local pkgs=("$@")
  step "Installing missing packages: ${CYN}${pkgs[*]}${RST}"
  case "$pm" in
    pacman) pacman -S --noconfirm "${pkgs[@]}" ;;
    apt)    apt update && apt install -y "${pkgs[@]}" ;;
    dnf)    dnf install -y "${pkgs[@]}" ;;
    zypper) zypper install -y "${pkgs[@]}" ;;
  esac
}

check_deps_qt6() {
  local pm="" missing=()
  if   command -v pacman &>/dev/null; then pm="pacman"
    for pkg in qt6-declarative qt6-5compat qt6-svg; do
      pacman -Qq "$pkg" &>/dev/null || missing+=("$pkg"); done
  elif command -v apt    &>/dev/null; then pm="apt"
    for pkg in qml6-module-qtquick qml6-module-qt5compat-graphicaleffects libqt6svg6; do
      dpkg -l "$pkg" &>/dev/null || missing+=("$pkg"); done
  elif command -v dnf    &>/dev/null; then pm="dnf"
    for pkg in qt6-qtdeclarative qt6-qt5compat qt6-qtsvg; do
      rpm -q "$pkg" &>/dev/null || missing+=("$pkg"); done
  elif command -v zypper &>/dev/null; then pm="zypper"
    for pkg in qt6-declarative qt6-5compat qt6-svg; do
      rpm -q "$pkg" &>/dev/null || missing+=("$pkg"); done
  fi
  if [[ ${#missing[@]} -gt 0 ]]; then
    [[ -n "$pm" ]] && install_missing "$pm" "${missing[@]}" \
                   || warn "Missing Qt6 packages: ${missing[*]}  (install manually)"
  else
    ok "All Qt6 dependencies satisfied"
  fi
}

check_deps_qt5() {
  local pm="" missing=()
  if   command -v pacman &>/dev/null; then pm="pacman"
    for pkg in qt5-declarative qt5-graphicaleffects qt5-quickcontrols2; do
      pacman -Qq "$pkg" &>/dev/null || missing+=("$pkg"); done
  elif command -v apt    &>/dev/null; then pm="apt"
    for pkg in qml-module-qtquick2 qml-module-qtgraphicaleffects qml-module-qtquick-controls2; do
      dpkg -l "$pkg" &>/dev/null || missing+=("$pkg"); done
  elif command -v dnf    &>/dev/null; then pm="dnf"
    for pkg in qt5-qtdeclarative qt5-qtgraphicaleffects qt5-qtquickcontrols2; do
      rpm -q "$pkg" &>/dev/null || missing+=("$pkg"); done
  elif command -v zypper &>/dev/null; then pm="zypper"
    for pkg in libqt5-qtdeclarative qt5-graphicaleffects; do
      rpm -q "$pkg" &>/dev/null || missing+=("$pkg"); done
  fi
  if [[ ${#missing[@]} -gt 0 ]]; then
    [[ -n "$pm" ]] && install_missing "$pm" "${missing[@]}" \
                   || warn "Missing Qt5 packages: ${missing[*]}  (install manually)"
  else
    ok "All Qt5 dependencies satisfied"
  fi
}

if [[ "$QT_VER" == "6" ]]; then check_deps_qt6; else check_deps_qt5; fi

# ── gather themes ────────────────────────────────────────────────────
THEMES=()
for d in "$THEMES_DIR"/*/; do
  [[ -f "$d/metadata.desktop" ]] && THEMES+=("$(basename "$d")")
done

TOTAL=${#THEMES[@]}

# ── category colours map ─────────────────────────────────────────────
theme_colour() {
  case "$1" in
    marvel|deadpool|joker|spiderverse|spiderman) echo "$BRED" ;;
    bmw|bmw-m3|classic-jdm|drag-racer|dodge|mazda-mx5|nissan|nissan-skyline) echo "$BYEL" ;;
    neon-gif|alienx|hoodie|oni-robot|cosmic-gateway) echo "$BCYN" ;;
    gojo|kawaii|neko-anime|zoro-dragon|zoro-blue|oni-anime-girl|hitagi-senjougahara|hilda-and-tepig|neverness-to-everness|purrple-cat|moonlit-rooftop-cat|sakura-lake|pokeball|pixel-sakura-city) echo "$BMAG" ;;
    pixel-gaming-room|super-mario-pixel) echo "$BGRN" ;;
    cat-pond|everest|fish-in-rock-pond|mount-fuji|mountain-sunset|ocean-in-jar|pink-bloom|the-dark-river|pirates-of-the-caribbean) echo "$MNT" ;;
    rdr2|the-dark-river|pirates-of-the-caribbean) echo "$ORG" ;;
    *) echo "$BWHT" ;;
  esac
}

# ── theme selection ───────────────────────────────────────────────────
THEME="${1:-}"

if [[ -z "$THEME" ]]; then

  # ── whiptail TUI (if available) ───────────────────────────────────
  if command -v whiptail &>/dev/null; then
    options=()
    for i in "${!THEMES[@]}"; do
      options+=("$((i+1))" "${THEMES[$i]}")
    done
    choice=$(whiptail \
      --backtitle "JOKER53 · SDDM Themes — github.com/KADHIRAVANEG/sddm-themes" \
      --title "  ✦  SELECT A THEME  ✦  " \
      --menu "\n  Use ↑ ↓ arrows · ENTER to install · ESC to quit\n" \
      26 52 16 "${options[@]}" \
      3>&1 1>&2 2>&3) || true

    [[ -z "$choice" ]] && {
      echo ""
      echo -e "${BBLK}$(hline '─')${RST}"
      echo -e "$(center "${BYEL}${BLD}  Installation cancelled.${RST}")"
      echo -e "${BBLK}$(hline '─')${RST}"
      echo ""
      exit 0
    }
    THEME="${THEMES[$((choice-1))]}"

  else
    # ── fancy plain-text grid ─────────────────────────────────────
    echo ""
    echo -e "${BBLK}$(hline '─')${RST}"
    echo -e "$(center "${BLD}${BWHT}  AVAILABLE THEMES  ${RST}")"
    echo -e "${BBLK}$(hline '─')${RST}"
    echo ""

    num=$TOTAL
    half=$(( (num + 1) / 2 ))
    col_w=36

    for (( i=0; i<half; i++ )); do
      j=$(( i + half ))
      t1="${THEMES[$i]}"
      c1=$(theme_colour "$t1")
      n1=$(printf "%2d" $((i+1)))
      pad1=$(( col_w - ${#t1} ))
      left="  ${BBLK}[${RST}${BYEL}${BLD}${n1}${RST}${BBLK}]${RST} ${c1}${t1}${RST}$(printf '%*s' $pad1 '')"

      if [[ $j -lt $num ]]; then
        t2="${THEMES[$j]}"
        c2=$(theme_colour "$t2")
        n2=$(printf "%2d" $((j+1)))
        right="${BBLK}[${RST}${BYEL}${BLD}${n2}${RST}${BBLK}]${RST} ${c2}${t2}${RST}"
        echo -e "${left}${right}"
      else
        echo -e "${left}"
      fi
    done

    echo ""
    echo -e "${BBLK}$(hline '─')${RST}"
    echo ""
    # styled prompt box
    prompt_line="  ${BBLK}┌─────────────────────────────────────┐${RST}"
    echo -e "$prompt_line"
    printf "  ${BBLK}│${RST}  ${SKY}🚀${RST}  ${BLD}Enter theme number:${RST}  "
    read -r choice
    echo -e "  ${BBLK}└─────────────────────────────────────┘${RST}"
    echo ""

    if ! [[ "$choice" =~ ^[0-9]+$ ]] || \
       [[ "$choice" -lt 1 ]] || \
       [[ "$choice" -gt "$num" ]]; then
      die "Invalid selection: '${choice}'"
    fi
    THEME="${THEMES[$((choice-1))]}"
  fi
fi

# ── validate ──────────────────────────────────────────────────────────
THEME_SRC="$THEMES_DIR/$THEME"
[[ -d "$THEME_SRC" ]]                   || die "Theme '${THEME}' not found."
[[ -f "$THEME_SRC/Main.qml" ]]          || die "Theme '${THEME}' is missing Main.qml"
[[ -f "$THEME_SRC/metadata.desktop" ]]  || die "Theme '${THEME}' is missing metadata.desktop"

DEST="$SDDM_THEMES/$THEME"
[[ "$DEST" == /usr/share/sddm/themes/* ]] \
  || die "Destination path looks wrong: ${DEST}"

# ── installation header ───────────────────────────────────────────────
echo ""
echo -e "${BBLK}$(hline '═')${RST}"
echo ""
echo -e "$(center "${BLD}${BCYN}  Installing:  ${BMAG}${THEME^^}${RST}")"
echo ""
echo -e "${BBLK}$(hline '═')${RST}"
echo ""

# ── backup ────────────────────────────────────────────────────────────
if [[ -d "$DEST" ]]; then
  BACKUP="${DEST}.bak.$(date +%Y%m%d_%H%M%S)"
  step "Backing up existing theme"
  cp -r "$DEST" "$BACKUP"
  ok  "Saved to ${DIM}${BACKUP}${RST}"
fi

if [[ -f "$SDDM_CONF" ]]; then
  cp "$SDDM_CONF" "${SDDM_CONF}.bak.$(date +%Y%m%d_%H%M%S)" || true
fi

# ── copy with progress ────────────────────────────────────────────────
step "Copying theme files"
rm -rf "$DEST"
mkdir -p "$DEST"

# count files for progress
file_count=$(find "$THEME_SRC" -type f | wc -l)
copied=0
while IFS= read -r -d '' src_file; do
  rel="${src_file#$THEME_SRC/}"
  dst_file="$DEST/$rel"
  mkdir -p "$(dirname "$dst_file")"
  cp "$src_file" "$dst_file"
  (( copied++ )) || true
  pbar "$copied" "$file_count" "${rel}" 2>/dev/null
  printf "\033[A"  # move cursor up one line to overwrite pbar
done < <(find "$THEME_SRC" -type f -print0)
pbar "$file_count" "$file_count" "Complete"
echo ""

# ── Qt patches ────────────────────────────────────────────────────────
transpile_for_qt5() {
  step "Patching QML imports for Qt5…"
  find "$DEST" -name "*.qml" | while read -r f; do
    perl -i -pe '
      s/^(\s*import\s+QtQuick\s*)(\n|$)/${1}2.15\n/;
      s/^(\s*import\s+QtQuick\.Controls\s*)(\n|$)/${1}2.15\n/;
      s/^(\s*import\s+QtQuick\.Layouts\s*)(\n|$)/${1}1.15\n/;
      s/^(\s*import\s+Qt5Compat\.GraphicalEffects\b)/import QtGraphicalEffects 1.0/;
    ' "$f"
  done
  ok "Qt5 patches applied"
}

if [[ "$QT_VER" == "6" ]]; then
  if ! grep -q "^QtVersion=" "$DEST/metadata.desktop"; then
    echo "QtVersion=6" >> "$DEST/metadata.desktop"
    ok "QtVersion=6 appended to metadata.desktop"
  else
    ok "metadata.desktop already has QtVersion"
  fi
else
  transpile_for_qt5
fi

# ── permissions ────────────────────────────────────────────────────────
step "Setting permissions"
chmod -R a+rX "$DEST"
ok  "Permissions set (a+rX)"

# ── update sddm.conf ────────────────────────────────────────────────────
step "Updating SDDM configuration"
touch "$SDDM_CONF"
if grep -q '^\[Theme\]' "$SDDM_CONF"; then
  if grep -q '^Current=' "$SDDM_CONF"; then
    sed -i "s|^Current=.*|Current=$THEME|" "$SDDM_CONF"
  else
    sed -i "/^\[Theme\]/a Current=$THEME" "$SDDM_CONF"
  fi
else
  printf '\n[Theme]\nCurrent=%s\n' "$THEME" >> "$SDDM_CONF"
fi

CONFD="/etc/sddm.conf.d"
if [[ -d "$CONFD" ]]; then
  for f in "$CONFD"/*.conf; do
    [[ -f "$f" ]] && grep -q '^Current=' "$f" && \
      sed -i "s|^Current=.*|Current=$THEME|" "$f" && \
      ok "Also updated ${DIM}$f${RST}"
  done
fi
ok "SDDM will use ${BLD}${BCYN}${THEME}${RST} on next login"

# ── success banner ─────────────────────────────────────────────────────
echo ""
echo -e "${BGRN}$(hline '═')${RST}"
echo ""
echo -e "$(center "${BGRN}${BLD}  ✓  INSTALLATION COMPLETE  ✓  ${RST}")"
echo ""
echo -e "$(center "${BLD}${BMAG}  ${THEME^^}  ${RST}${DIM}is ready on your login screen${RST}")"
echo ""
echo -e "${BGRN}$(hline '═')${RST}"
echo ""

# ── next steps ─────────────────────────────────────────────────────────
echo -e "  ${BYEL}NEXT STEPS${RST}"
echo -e "  ${BBLK}──────────────────────────────────────────────────────${RST}"
echo ""
echo -e "  ${SKY}◈${RST}  ${BLD}Preview without rebooting:${RST}"
echo -e "      ${BCYN}sddm-greeter-qt6 --test-mode --theme ${DEST}${RST}"
echo ""
echo -e "  ${SKY}◈${RST}  ${BLD}Apply permanently:${RST}"
echo -e "      ${BGRN}reboot${RST}  ${BBLK}(recommended)${RST}"
echo -e "      ${DIM}— or —${RST}  ${BCYN}systemctl restart sddm${RST}  ${BBLK}(while in TTY only)${RST}"
echo ""
echo -e "  ${BBLK}──────────────────────────────────────────────────────${RST}"
echo -e "  ${BBLK}  github.com/KADHIRAVANEG/sddm-themes${RST}"
echo ""