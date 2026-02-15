#!/usr/bin/env bash
# Morpheus — Context injector (PreToolUse hook)
# Fast path: 1 jq. Slow path: 2 jq. No config reads.

set -euo pipefail

# jq 1: parse session_id from stdin
SID="$(jq -r '.session_id // empty')"
[[ -z "$SID" ]] && exit 0

TRIG_F="/tmp/.morpheus-trigger-${SID}"

# Fast path: no trigger file, exit immediately
[[ ! -f "$TRIG_F" ]] && exit 0

# jq 2: read trigger message via --rawfile, output additionalContext
jq -n --rawfile msg "$TRIG_F" '{
  hookSpecificOutput: {
    hookEventName: "PreToolUse",
    additionalContext: $msg
  }
}'

rm -f "$TRIG_F"
