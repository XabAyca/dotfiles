#!/usr/bin/env bash
# Writes what the ship gate shows: the one place a person sees how the run went
# before anything leaves the machine, so whatever did not pass is said first.
set -euo pipefail

run_id=${1:?missing run_id}
state=".specify/state/${run_id}"

status_of() {
  local file="${state}/$1.json"
  [ -f "$file" ] || { printf %s ABSENT; return 0; }
  jq -re '.status' "$file"
}

# Read at the end, not from implement's own report: a repaired pass has
# checked some of what that report lists, and marked the rest [HUMAN].
feature_dir=$(jq -re '.feature_directory' .specify/feature.json 2>/dev/null || true)
open=$(grep -E '^[[:space:]]*- \[ \]' "${feature_dir}/tasks.md" 2>/dev/null || true)
# What a person does on the draft — a manual check, a question outside the
# repository — is no reason to keep it on the machine.
unfinished=$(grep -vF '[HUMAN]' <<< "$open" || true)

review=$(status_of review)
ui=$(status_of ui)
passed=yes
if [ "$review" != DONE ] || { [ "$ui" != DONE ] && [ "$ui" != ABSENT ]; }; then
  passed=no
fi

{
  echo "# Livraison — run ${run_id}"
  echo
  echo "| check | verdict |"
  echo "|---|---|"
  echo "| feature review | ${review} |"
  echo "| interface review | ${ui} |"
  # A missing ui.json is normal, as in verdict.sh; a missing review.json is a
  # review that never reached a verdict.
  if [ "$passed" = no ]; then
    echo
    echo "**Les reviews ne sont pas passées. Lire les verdicts avant de pousser.**"
  fi
  if [ -n "$open" ]; then
    printf '\n## Tâches encore ouvertes\n\n%s\n' "$open"
  fi
  if [ -f "${state}/converge.md" ]; then
    echo
    sed 's/^# /## /' "${state}/converge.md"
  fi
  for f in review ui; do
    [ -f "${state}/${f}.json" ] || continue
    echo
    echo "## ${f}"
    echo
    jq -r '.summary' "${state}/${f}.json"
    jq -r '.bullets[]? // empty | "- " + .' "${state}/${f}.json"
  done
} > "${state}/ship.md"

# The ship gate's title; no newline, it is spliced into the message. The
# workflow pushes without a gate on exactly "Prêt à livrer".
if [ "$passed" = no ]; then printf %s "Pas prêt à livrer : les reviews ne sont pas passées"
elif [ -n "$unfinished" ]; then printf %s "Reviews passées, mais des tâches restent ouvertes"
else printf %s "Prêt à livrer"; fi
