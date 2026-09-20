#!/usr/bin/env bash
# Says whether /speckit.converge found anything left to build. The command
# leaves tasks.md byte-for-byte unchanged when nothing remains, so the file is
# the signal and nothing has to be parsed out of what the agent said.
set -euo pipefail

run_id=${1:?missing run_id}
max=${2:?missing maximum rounds}
mode=${3:?missing mode: snapshot|check}

state=".specify/state/${run_id}"
mkdir -p "$state"

feature_dir=$(jq -re '.feature_directory' .specify/feature.json)
tasks="${feature_dir}/tasks.md"
[ -f "$tasks" ] || { echo "no tasks.md at $tasks" >&2; exit 1; }

before="${state}/tasks.snapshot"

if [ "$mode" = snapshot ]; then
  cp "$tasks" "$before"
  printf %s SNAPSHOT
  exit 0
fi

[ -f "$before" ] || { echo "no snapshot taken before converge" >&2; exit 1; }

if cmp -s "$before" "$tasks"; then
  printf %s CONVERGED
  exit 0
fi

rounds=$(( $(cat "${state}/converge-rounds" 2>/dev/null || echo 0) + 1 ))
echo "$rounds" > "${state}/converge-rounds"

if [ "$rounds" -lt "$max" ]; then
  printf %s MORE
  exit 0
fi

# Still appending after the last round: a call for a human, not another lap.
{
  echo "# Convergence exhausted — run ${run_id}"
  echo
  echo "After ${rounds} rounds /speckit.converge is still finding work the plan"
  echo "did not foresee. Appended in the last round:"
  echo
  diff "$before" "$tasks" | sed -n 's/^> //p' || true
} > "${state}/converge.md"

printf %s EXHAUSTED
