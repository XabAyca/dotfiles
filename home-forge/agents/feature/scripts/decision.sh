#!/usr/bin/env bash
# Gathers everything a person must see before code is written into the one
# file the decision gate shows. /speckit.analyze is read-only, so the prompt
# step that runs it writes analyze.json. Prints CLEAR when there is nothing to
# decide, REVIEW otherwise.
set -euo pipefail

run_id=${1:?missing run_id}
state=".specify/state/${run_id}"
file="${state}/analyze.json"

[ -f "$file" ] || { echo "analysis verdict missing: $file" >&2; exit 1; }

feature_dir=$(jq -re '.feature_directory' .specify/feature.json)
assumed=$(grep -E 'ASSUMPTION|NEEDS CLARIFICATION' "${feature_dir}/spec.md" || true)
human=$(grep -E '^[[:space:]]*- \[ \].*\[HUMAN\]' "${feature_dir}/tasks.md" || true)

# A feature that waits on people this much cannot finish in one run; the
# only one that went past it shipped unfinished. The task count predicts
# nothing: 86 tasks shipped fine, 35 took three runs.
max_human=8
human_count=$(grep -cE '^[[:space:]]*- \[ \].*\[HUMAN\]' "${feature_dir}/tasks.md" || true)
too_big=""
if [ "$human_count" -gt "$max_human" ]; then too_big=yes; fi

{
  echo "# Avant le code — run ${run_id}"
  if [ -n "$too_big" ]; then
    printf '\n## Trop gros pour un seul run\n\n'
    printf '%s tâches attendent un humain (au-delà de %s, un run ne tient pas). ' \
      "$human_count" "$max_human"
    printf '`reject` puis un `agent start` par morceau qui se livre seul ; `approve` construit quand même.\n'
  fi
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

# A count the analysis left out is not a zero.
if [ -z "$assumed$human$too_big" ] && jq -e '.critical == 0 and .high == 0' "$file" >/dev/null; then
  printf %s CLEAR
else
  printf %s REVIEW
fi
