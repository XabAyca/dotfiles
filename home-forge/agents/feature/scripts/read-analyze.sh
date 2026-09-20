#!/usr/bin/env bash
# Turns what the analysis recorded into a decision. /speckit.analyze is
# read-only, so the prompt step that runs it writes the file.
set -euo pipefail

run_id=${1:?missing run_id}
file=".specify/state/${run_id}/analyze.json"

[ -f "$file" ] || { echo "analysis verdict missing: $file" >&2; exit 1; }

critical=$(jq -re '.critical // 0' "$file")
high=$(jq -re '.high // 0' "$file")

if [ "$critical" -gt 0 ]; then printf %s BLOCKING
elif [ "$high" -gt 0 ]; then printf %s CONCERNS
else printf %s CLEAR
fi
