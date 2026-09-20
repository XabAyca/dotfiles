#!/usr/bin/env bash
# Says whether /speckit-converge found anything left to build.
#
# The command appends missing work to tasks.md and leaves the file untouched
# when nothing remains — so the file is the signal, and nothing has to be
# parsed out of what the agent said.
set -euo pipefail

run_id=${1:?missing run_id}
max=${2:?missing maximum rounds}
mode=${3:?missing mode: snapshot|check}

state=".specify/state/${run_id}"
mkdir -p "$state"

feature_dir=$(jq -re '.feature_directory' .specify/feature.json)
tasks="${feature_dir}/tasks.md"
[ -f "$tasks" ] || { echo "no tasks.md at $tasks" >&2; exit 1; }

before="${state}/tasks.sha"

if [ "$mode" = snapshot ]; then
  sha256sum "$tasks" | cut -d' ' -f1 > "$before"
  printf %s SNAPSHOT
  exit 0
fi

[ -f "$before" ] || { echo "no snapshot taken before converge" >&2; exit 1; }

rounds=$(( $(cat "${state}/converge-rounds" 2>/dev/null || echo 0) + 1 ))
echo "$rounds" > "${state}/converge-rounds"

if [ "$(sha256sum "$tasks" | cut -d' ' -f1)" = "$(cat "$before")" ]; then
  printf %s CONVERGED
elif [ "$rounds" -lt "$max" ]; then
  printf %s MORE
else
  # Still appending work after the last round: the feature is larger than the
  # plan thought, and that is a call for a human, not another lap.
  printf %s EXHAUSTED
fi
