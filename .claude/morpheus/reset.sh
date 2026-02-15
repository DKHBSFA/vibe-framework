#!/usr/bin/env bash
# Morpheus — Compaction reset (SessionStart hook)
# 1 jq call. Clears stale flag files after compaction.

set -euo pipefail

# jq 1: parse session_id from stdin
SID="$(jq -r '.session_id // empty')"
[[ -z "$SID" ]] && exit 0

rm -f "/tmp/.morpheus-trigger-${SID}" "/tmp/.morpheus-fired-${SID}"
