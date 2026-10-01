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

review=$(status_of review)
ui=$(status_of ui)

{
  echo "# Livraison — run ${run_id}"
  echo
  echo "| check | verdict |"
  echo "|---|---|"
  echo "| feature review | ${review} |"
  echo "| interface review | ${ui} |"
  # A missing ui.json is normal, as in verdict.sh; a missing review.json is a
  # review that never reached a verdict.
  if [ "$review" != DONE ] || { [ "$ui" != DONE ] && [ "$ui" != ABSENT ]; }; then
    echo
    echo "**Les reviews ne sont pas passées. Lire les verdicts avant de pousser.**"
  fi
  for f in incomplete converge; do
    [ -f "${state}/${f}.md" ] || continue
    echo
    sed 's/^# /## /' "${state}/${f}.md"
  done
  for f in review ui; do
    [ -f "${state}/${f}.json" ] || continue
    echo
    echo "## ${f}"
    echo
    jq -r '.summary' "${state}/${f}.json"
    jq -r '.bullets[]? // empty | "- " + .' "${state}/${f}.json"
  done
} > "${state}/ship.md"
