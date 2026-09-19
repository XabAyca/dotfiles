#!/usr/bin/env bash
# Reads the reviewer's verdict and decides what the loop does next.
# Exits non-zero when the verdict is missing or invalid, so the run stops
# rather than carrying on with an assumption.
set -euo pipefail

run_id=${1:?missing run_id}
max=${2:?missing maximum attempts}

state=".specify/state/${run_id}"
file="${state}/review.json"

[ -f "$file" ] || { echo "verdict missing: $file" >&2; exit 1; }

status=$(jq -re '.status' "$file") || { echo "unreadable verdict: $file" >&2; exit 1; }

attempts=$(( $(cat "${state}/attempts" 2>/dev/null || echo 0) + 1 ))
mkdir -p "$state"
echo "$attempts" > "${state}/attempts"

case "$status" in
  DONE)                verdict=DONE ;;
  NEEDS_HUMAN|BLOCKED) verdict=ESCALATE ;;
  NEEDS_FIX)
    if [ "$attempts" -lt "$max" ]; then verdict=RETRY; else verdict=ESCALATE; fi ;;
  *) echo "unknown status: $status" >&2; exit 1 ;;
esac

# printf without a newline: the engine compares raw stdout, and "RETRY\n"
# does not equal "RETRY".
printf %s "$verdict"
