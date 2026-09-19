#!/usr/bin/env bash
# Reports whether the freshly written spec still carries open questions, and
# collects them where the human gate can show them.
set -euo pipefail

run_id=${1:?missing run_id}
state=".specify/state/${run_id}"
mkdir -p "$state"

feature_dir=$(jq -re '.feature_directory' .specify/feature.json)
spec="${feature_dir}/spec.md"

if grep -n 'NEEDS CLARIFICATION' "$spec" > "${state}/questions.md"; then
  printf %s BLOCKED
else
  # grep exits 1 on no match, which set -e would take for a failure.
  rm -f "${state}/questions.md"
  printf %s CLEAR
fi
