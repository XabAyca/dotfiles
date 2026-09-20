#!/usr/bin/env bash
# Reads what the analysis recorded. /speckit-analyze is read-only by design,
# so the step that runs it writes this file; here we only decide.
set -euo pipefail

run_id=${1:?missing run_id}
file=".specify/state/${run_id}/analyze.json"

[ -f "$file" ] || { echo "analysis verdict missing: $file" >&2; exit 1; }

critical=$(jq -re '.critical // 0' "$file")
high=$(jq -re '.high // 0' "$file")

# A constitution breach or a requirement with no coverage is settled before
# code is written, not after.
if [ "$critical" -gt 0 ]; then printf %s BLOCKING
elif [ "$high" -gt 0 ]; then printf %s CONCERNS
else printf %s CLEAR
fi
