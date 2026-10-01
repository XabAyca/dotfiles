#!/usr/bin/env bash
# Gathers everything a person must see before code is written into the one
# file the decision gate shows. /speckit.analyze is read-only, so the prompt
# step that runs it writes analyze.json.
set -euo pipefail

run_id=${1:?missing run_id}
state=".specify/state/${run_id}"
file="${state}/analyze.json"

[ -f "$file" ] || { echo "analysis verdict missing: $file" >&2; exit 1; }

feature_dir=$(jq -re '.feature_directory' .specify/feature.json)
assumed=$(grep -E 'ASSUMPTION|NEEDS CLARIFICATION' "${feature_dir}/spec.md" || true)
human=$(grep -E '^[[:space:]]*- \[ \].*\[HUMAN\]' "${feature_dir}/tasks.md" || true)

{
  echo "# Avant le code — run ${run_id}"
  if [ -n "$assumed" ]; then
    printf '\n## Hypothèses prises sur la spec\n\n%s\n' "$assumed"
  fi
  printf '\n## Analyse — %s critique(s), %s haute(s)\n\n' \
    "$(jq -r '.critical // 0' "$file")" "$(jq -r '.high // 0' "$file")"
  jq -r '.summary' "$file"
  jq -r '.findings[]? | "- " + .' "$file"
  if [ -n "$human" ]; then
    printf '\n## Tâches que seul un humain peut faire\n\n%s\n' "$human"
  fi
  printf '\n## Plan\n\n'
  cat "${feature_dir}/plan.md"
} > "${state}/decision.md"
