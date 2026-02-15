#!/usr/bin/env bash
# Morpheus — Context sensor (statusLine)
# 2 jq calls: (1) parse stdin, (2) mega-jq: config + thresholds + bar
# Dependencies: jq

set -euo pipefail

# jq 1: parse stdin → session_id, used%, remaining%
read -r SID USED REM <<< "$(jq -r '[
  .session_id // "",
  .context_window.used_percentage // 0,
  .context_window.remaining_percentage // 100
] | @tsv')"

[[ -z "$SID" ]] && exit 0

CFG="${CLAUDE_PROJECT_DIR:-.}/.claude/morpheus/config.json"
[[ ! -f "$CFG" ]] && exit 0

FIRED_F="/tmp/.morpheus-fired-${SID}"
TRIG_F="/tmp/.morpheus-trigger-${SID}"

# Load fired state (bash built-in $(<), no subprocess)
FIRED='{}'
[[ -f "$FIRED_F" ]] && FIRED="$(<"$FIRED_F")"

# jq 2: mega-jq — config via --slurpfile, threshold processing, bar rendering
# Output: 3 lines — (1) ANSI status bar, (2) fired JSON, (3) trigger message or NULL
RESULT="$(jq -r -n \
  --slurpfile cfg "$CFG" \
  --argjson used "$USED" --argjson rem "$REM" \
  --argjson fired "$FIRED" '
  ($cfg[0]) as $c |
  ($c.repeat_mode // "once_per_tier_reset_on_compaction") as $rm |
  ($c.statusline.bar_width // 20) as $bw |
  ($c.statusline.bar_filled // "\u2588") as $bf |
  ($c.statusline.bar_empty // "\u2591") as $be |
  ($c.statusline.format // "ctx {bar} {percentage}%") as $fmt |
  ($c.statusline.color_normal // "37") as $cn |
  ($c.statusline.color_warning // "31") as $cw |
  (($c.thresholds // []) | sort_by(.percent)) as $ts |

  # Process thresholds
  {ex: false, f: $fired, t: null} |
  reduce $ts[] as $th (.;
    if $used >= ($th.percent | tonumber) then
      .ex = true |
      if (.f[$th.level] != true) or ($rm == "every_turn") then
        .t = ($th.message
          | gsub("\\{percentage\\}"; ($used | tostring))
          | gsub("\\{remaining\\}"; ($rem | tostring))) |
        .f[$th.level] = true
      else . end
    else
      if (.f[$th.level] == true) and ($rm != "once_per_tier") then
        .f |= del(.[$th.level])
      else . end
    end
  ) |

  # Render bar
  (($used * $bw / 100) | floor) as $filled |
  ($bw - $filled) as $empty |
  ((if $filled > 0 then $bf * $filled else "" end) +
   (if $empty > 0 then $be * $empty else "" end)) as $bar |
  ($fmt
    | gsub("\\{bar\\}"; $bar)
    | gsub("\\{percentage\\}"; ($used | tostring))) as $display |
  (if .ex then $cw else $cn end) as $color |

  # Output 3 lines
  ("\u001b[" + $color + "m" + $display + "\u001b[0m"),
  (.f | @json),
  (.t // "NULL")
')"

# Parse 3-line output
{ read -r STATUS_LINE; read -r NEW_FIRED; read -r TRIGGER_MSG; } <<< "$RESULT"

# Persist fired state
echo "$NEW_FIRED" > "$FIRED_F"

# Write trigger if threshold crossed
if [[ "$TRIGGER_MSG" != "NULL" ]]; then
  printf '%s' "$TRIGGER_MSG" > "$TRIG_F"
fi

# Output status bar
printf '%s' "$STATUS_LINE"
