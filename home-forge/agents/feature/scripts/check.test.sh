#!/usr/bin/env bash
# Runs check.sh on throwaway commands, then a toy workflow through the real
# engine to show a loop repairs once and stops on the second failure. No model.
set -euo pipefail

HERE=$(cd "$(dirname "$(readlink -f "$0")")" && pwd)
T=$(mktemp -d)
trap 'rm -rf "$T"' EXIT

cd "$T"
state=.specify/state/r1
fail=0
say() { echo "FAIL: $1" >&2; fail=1; }

# A passing check is invisible: its own stdout, nothing left behind.
out=$(bash "$HERE/check.sh" r1 decision printf REVIEW)
[ "$out" = REVIEW ] || say "a passing check printed '$out'"

# The first failure is a lesson for the step, not a stop for the run.
out=$(bash "$HERE/check.sh" r1 decision sh -c 'echo "analyze.json: parse error" >&2; exit 2')
[ "$out" = REPAIR ] || say "a first failure printed '$out'"
grep -qF "analyze.json: parse error" "$state/repair.md" || say "repair.md lacks the reason"

# The second one stops it, with the reason where the engine keeps stderr.
if bash "$HERE/check.sh" r1 decision sh -c 'echo "still broken" >&2; exit 1' 2>"$T/err"; then
  say "a second failure did not stop the run"
fi
grep -qF "still broken" "$T/err" || say "the second failure lost its reason"

# A repaired step leaves no trace for the next check to trip on.
bash "$HERE/check.sh" r1 decision true >/dev/null
[ -e "$state/repair.md" ] && say "repair.md outlived the repair"
out=$(bash "$HERE/check.sh" r1 decision false 2>/dev/null) || say "a fresh failure after a repair stopped the run"
[ "$out" = REPAIR ] || say "a fresh failure after a repair printed '$out'"

if ! command -v specify >/dev/null; then
  echo "skip: no specify, the engine half is not run" >&2
else
  # The guarded step succeeds on its second try when `need` is 2, never at 9.
  cat > wf.yml <<YML
schema_version: "1.0"
workflow: {id: toy, name: toy, version: "0.1.0"}
inputs:
  need: {type: number, default: 2}
steps:
  - id: make-loop
    type: do-while
    max_iterations: 2
    condition: "{{ steps.made.output.stdout == 'REPAIR' }}"
    steps:
      - id: make
        type: shell
        run: 'echo x >> tries'
      - id: made
        type: shell
        run: 'bash $HERE/check.sh r2 made test \$(wc -l < tries) -ge {{ inputs.need }}'
YML
  for need in 2 9; do
    mkdir -p "$T/need$need/.specify"
    (cd "$T/need$need" && specify workflow run ../wf.yml -i need=$need >/dev/null 2>&1) || true
    status=$(jq -r .status "$T"/need$need/.specify/workflows/runs/*/state.json)
    tries=$(wc -l < "$T/need$need/tries")
    case $need in
      2) [ "$status/$tries" = completed/2 ] || say "a repairable step ended $status after $tries tries" ;;
      9) [ "$status/$tries" = failed/2 ] || say "an unrepairable step ended $status after $tries tries" ;;
    esac
  done
fi

[ "$fail" = 0 ] && echo "ok"
exit "$fail"
