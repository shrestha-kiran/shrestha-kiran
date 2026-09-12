#!/usr/bin/env bash
set -euo pipefail

OUT_DIR="${1:-dist}"
mkdir -p "$OUT_DIR"

NAMES=("worldofaiagent" "quant-agent" "myirelandvacation" "foundry-os" "mindfulbite")
URLS=(
  "https://www.worldofaiagent.com"
  "https://www.bookiebo.com/admin/dashboard"
  "https://www.myirelandvacation.com/"
  "https://foundry-os-beta.vercel.app"
  "https://mindful-bite-seven.vercel.app"
)

TOTAL=${#NAMES[@]}
HEALTHY=0
LINES=""
Y=86
PID=1001

for i in "${!NAMES[@]}"; do
  NAME="${NAMES[$i]}"
  URL="${URLS[$i]}"
  CODE=$(curl -s -o /dev/null -w "%{http_code}" --max-time 10 "$URL" || echo "000")
  if [[ "$CODE" =~ ^(2|3) ]]; then
    STATUS="RUNNING"
    COLOR="#3ddc97"
    DOT="&#9679;"
    HEALTHY=$((HEALTHY + 1))
  else
    STATUS="DOWN"
    COLOR="#ff5f56"
    DOT="&#10007;"
  fi

  LABEL=$(printf "%-18s" "$NAME")
  LINE=$(cat <<EOF
    <text x="20" y="${Y}" font-family="Fira Code, SFMono-Regular, Consolas, monospace" font-size="14"><tspan fill="#6C63FF">[spawn]</tspan> <tspan fill="#6b6b7a">pid ${PID}</tspan>  <tspan fill="#e6e6f0">${LABEL}</tspan> <tspan fill="${COLOR}">${DOT} ${STATUS}</tspan></text>
EOF
)
  LINES="${LINES}${LINE}"$'\n'
  Y=$((Y + 26))
  PID=$((PID + 1))
done

SUMMARY_Y=$((Y + 14))
HEIGHT=$((SUMMARY_Y + 26))
TIMESTAMP=$(date -u +"%Y-%m-%d %H:%M UTC")

cat > "${OUT_DIR}/agent-status.svg" <<SVGEOF
<svg width="660" height="${HEIGHT}" viewBox="0 0 660 ${HEIGHT}" xmlns="http://www.w3.org/2000/svg" role="img" aria-label="orchestrator agent status: ${HEALTHY} of ${TOTAL} projects healthy">
  <defs>
    <linearGradient id="obf" x1="0" y1="0" x2="1" y2="1">
      <stop offset="0%" stop-color="#6C63FF"/>
      <stop offset="100%" stop-color="#00D4FF"/>
    </linearGradient>
  </defs>
  <rect x="0.75" y="0.75" width="658.5" height="$((HEIGHT - 2))" rx="12" fill="#0d0f1a" stroke="url(#obf)" stroke-width="1.5"/>
  <circle cx="22" cy="20" r="6" fill="#FF5F56"/>
  <circle cx="42" cy="20" r="6" fill="#FFBD2E"/>
  <circle cx="62" cy="20" r="6" fill="#27C93F"/>
  <text x="20" y="48" font-family="Fira Code, SFMono-Regular, Consolas, monospace" font-size="15" fill="#6C63FF">\$ ./orchestrator.sh --agent kiran_shrestha</text>
  <text x="20" y="70" font-family="Fira Code, SFMono-Regular, Consolas, monospace" font-size="14"><tspan fill="#00D4FF">[boot]</tspan> <tspan fill="#e6e6f0">identity: kiran_shrestha &#8212; building AI agents for the future</tspan></text>
${LINES}  <text x="20" y="${SUMMARY_Y}" font-family="Fira Code, SFMono-Regular, Consolas, monospace" font-size="13" fill="#8a8a99">[status] ${HEALTHY}/${TOTAL} agents healthy &#183; last check: ${TIMESTAMP}</text>
  <rect x="600" y="$((SUMMARY_Y - 12))" width="8" height="14" fill="#e6e6f0">
    <animate attributeName="opacity" values="1;1;0;0" keyTimes="0;0.5;0.5;1" dur="1s" repeatCount="indefinite"/>
  </rect>
</svg>
SVGEOF

echo "generated ${OUT_DIR}/agent-status.svg — ${HEALTHY}/${TOTAL} healthy"
