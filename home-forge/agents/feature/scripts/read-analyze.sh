#!/usr/bin/env bash
# Turns what the analysis recorded into a decision. /speckit.analyze is
# read-only, so the prompt step that runs it writes the file.
set -euo pipefail

run_id=${1:?missing run_id}
state=".specify/state/${run_id}"
file="${state}/analyze.json"

[ -f "$file" ] || { echo "analysis verdict missing: $file" >&2; exit 1; }

critical=$(jq -re '.critical // 0' "$file")
high=$(jq -re '.high // 0' "$file")

# A task only a person can do blocks whatever builds on it, so it is settled
# before the code, whatever severity the analysis gave it.
feature_dir=$(jq -re '.feature_directory' .specify/feature.json)
human=$(grep -E '^[[:space:]]*- \[ \].*\[HUMAN\]' "${feature_dir}/tasks.md" || true)

# The gate shows one file, and the tasks are not in the analysis.
{
  jq -r '.summary' "$file"
  printf '\n'
  jq -r '.findings[]? | "- " + .' "$file"
  if [ -n "$human" ]; then
    printf '\n## Tasks only a person can do\n\n%s\n' "$human"
  fi
} > "${state}/analyze.md"

if [ "$critical" -gt 0 ] || [ -n "$human" ]; then printf %s BLOCKING
elif [ "$high" -gt 0 ]; then printf %s CONCERNS
else printf %s CLEAR
fi
