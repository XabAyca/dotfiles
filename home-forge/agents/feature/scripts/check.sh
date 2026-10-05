#!/usr/bin/env bash
# Runs a check so that the step it guards can learn from a failure. The first
# one is written to repair.md, which that step reads on its second try, and
# REPAIR tells the loop around them to go again; only a second one stops the
# run. On success it prints what the check printed, so a check whose output
# drives the workflow keeps doing so.
#   check.sh <run_id> <name> <command...>
set -euo pipefail

run_id=${1:?missing run_id}
name=${2:?missing check name}
shift 2

state=".specify/state/${run_id}"
mkdir -p "$state"
err="${state}/check-${name}.err"
failed_once="${state}/repair-${name}"

if out=$("$@" 2>"$err"); then
  rm -f "$err" "$failed_once" "${state}/repair.md"
  printf %s "$out"
  exit 0
fi

if [ -e "$failed_once" ]; then
  cat "$err" >&2
  exit 1
fi

{
  echo "# The last attempt was rejected by the check \`${name}\`"
  echo
  cat "$err"
} > "${state}/repair.md"
touch "$failed_once"
printf %s REPAIR
