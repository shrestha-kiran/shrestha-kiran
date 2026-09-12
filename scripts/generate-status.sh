#!/usr/bin/env bash
set -euo pipefail

OUT_DIR="${1:-dist}"
mkdir -p "$OUT_DIR"

CODES=("WOAI" "QANT" "IRLD" "FNDY" "MBTE")
NAMES=("WORLDOFAIAGENT.COM" "QUANTAGENT" "MYIRELANDVACATION.COM" "FOUNDRY OS" "MINDFULBITE")
GATES=("A1" "A2" "A3" "A4" "A5")
URLS=(
  "https://www.worldofaiagent.com"
  "https://www.bookiebo.com/admin/dashboard"
  "https://www.myirelandvacation.com/"
  "https://foundry-os-beta.vercel.app"
  "https://mindful-bite-seven.vercel.app"
)

ROW_H=34
HEADER_H=78
TOP_PAD=16
WIDTH=680

TOTAL=${#NAMES[@]}
ONTIME=0
ROWS=""
Y=$((TOP_PAD + HEADER_H))

for i in "${!NAMES[@]}"; do
  CODE="${CODES[$i]}"
  NAME="${NAMES[$i]}"
  GATE="${GATES[$i]}"
  URL="${URLS[$i]}"
  HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" --max-time 10 "$URL" || echo "000")
  if [[ "$HTTP_CODE" =~ ^(2|3) ]]; then
    STATUS="ON TIME"
    ONTIME=$((ONTIME + 1))
  else
    STATUS="DELAYED"
  fi

  ROW_Y_TEXT=$((Y + 23))
  STRIPE=""
  if [ $((i % 2)) -eq 1 ]; then
    STRIPE="<rect x=\"12\" y=\"${Y}\" width=\"$((WIDTH - 24))\" height=\"${ROW_H}\" fill=\"#141414\"/>"
  fi

  ROW=$(cat <<EOF
  ${STRIPE}
  <text x="28" y="${ROW_Y_TEXT}" font-family="Helvetica, Arial, sans-serif" font-size="16" font-weight="700" fill="#FFB627" letter-spacing="1">${CODE}</text>
  <text x="110" y="${ROW_Y_TEXT}" font-family="Helvetica, Arial, sans-serif" font-size="16" fill="#e8e8e0" letter-spacing="0.5">${NAME}</text>
  <text x="440" y="${ROW_Y_TEXT}" font-family="Helvetica, Arial, sans-serif" font-size="14" fill="#8a8a80">GATE ${GATE}</text>
  <text x="540" y="${ROW_Y_TEXT}" font-family="Helvetica, Arial, sans-serif" font-size="16" font-weight="700" fill="#FFB627" letter-spacing="1">${STATUS}</text>
EOF
)
  ROWS="${ROWS}${ROW}"$'\n'
  Y=$((Y + ROW_H))
done

FOOTER_Y=$((Y + 26))
HEIGHT=$((FOOTER_Y + 20))
TIMESTAMP=$(date -u +"%Y-%m-%d %H:%M UTC")

cat > "${OUT_DIR}/agent-status.svg" <<SVGEOF
<svg width="${WIDTH}" height="${HEIGHT}" viewBox="0 0 ${WIDTH} ${HEIGHT}" xmlns="http://www.w3.org/2000/svg" role="img" aria-label="departures board: ${ONTIME} of ${TOTAL} projects on time">
  <rect x="0" y="0" width="${WIDTH}" height="${HEIGHT}" rx="6" fill="#0b0b0d" stroke="#2a2a2a" stroke-width="1.5"/>
  <circle cx="18" cy="18" r="3" fill="#3a3a3a"/>
  <circle cx="$((WIDTH - 18))" cy="18" r="3" fill="#3a3a3a"/>
  <circle cx="18" cy="$((HEIGHT - 18))" r="3" fill="#3a3a3a"/>
  <circle cx="$((WIDTH - 18))" cy="$((HEIGHT - 18))" r="3" fill="#3a3a3a"/>

  <text x="28" y="42" font-family="Helvetica, Arial, sans-serif" font-size="13" font-weight="700" fill="#8a8a80" letter-spacing="2">DEPARTURES</text>
  <line x1="12" y1="${TOP_PAD}" x2="12" y2="${TOP_PAD}"/>
  <line x1="12" y1="$((TOP_PAD + 52))" x2="$((WIDTH - 12))" y2="$((TOP_PAD + 52))" stroke="#2a2a2a" stroke-width="1"/>

  <text x="28" y="$((TOP_PAD + 46))" font-family="Helvetica, Arial, sans-serif" font-size="12" font-weight="700" fill="#5a5a52" letter-spacing="1">FLIGHT</text>
  <text x="110" y="$((TOP_PAD + 46))" font-family="Helvetica, Arial, sans-serif" font-size="12" font-weight="700" fill="#5a5a52" letter-spacing="1">PROJECT</text>
  <text x="440" y="$((TOP_PAD + 46))" font-family="Helvetica, Arial, sans-serif" font-size="12" font-weight="700" fill="#5a5a52" letter-spacing="1"></text>
  <text x="540" y="$((TOP_PAD + 46))" font-family="Helvetica, Arial, sans-serif" font-size="12" font-weight="700" fill="#5a5a52" letter-spacing="1">STATUS</text>

${ROWS}
  <line x1="12" y1="${Y}" x2="$((WIDTH - 12))" y2="${Y}" stroke="#2a2a2a" stroke-width="1"/>
  <text x="28" y="${FOOTER_Y}" font-family="Helvetica, Arial, sans-serif" font-size="12" fill="#5a5a52">${ONTIME}/${TOTAL} ON TIME &#183; LAST CHECKED ${TIMESTAMP}</text>
</svg>
SVGEOF

echo "generated ${OUT_DIR}/agent-status.svg — ${ONTIME}/${TOTAL} on time"
