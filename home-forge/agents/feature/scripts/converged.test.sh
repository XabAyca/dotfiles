#!/usr/bin/env bash
# Runs converged.sh on a throwaway tasks.md, one round at a time: what implement
# and converge leave behind, and the verdict it must give. No model.
set -euo pipefail

HERE=$(cd "$(dirname "$(readlink -f "$0")")" && pwd)
T=$(mktemp -d)
trap 'rm -rf "$T"' EXIT

cd "$T"
mkdir -p .specify/state/r1 specs/001
echo '{"feature_directory": "specs/001"}' > .specify/feature.json
tasks=specs/001/tasks.md
state=.specify/state/r1

fail=0
say() { echo "FAIL: $*" >&2; fail=1; }
append() { echo "- [ ] $1" >> "$tasks"; }
check_all() { sed -i 's/- \[ \] \(T[0-9]* [^[]\)/- [x] \1/' "$tasks"; }

# snapshot, then what converge does, then the verdict.
round() {
  local want=$1 got
  shift
  bash "$HERE/converged.sh" r1 3 snapshot >/dev/null
  "$@"
  got=$(bash "$HERE/converged.sh" r1 3 check)
  [ "$got" = "$want" ] || say "'$got', not '$want', after: $*"
  return 0
}

printf '%s\n' '- [x] T001 done' '- [ ] T002 [HUMAN] check the prod timezone' > "$tasks"
round CONVERGED true
round MORE append 'T003 found by converge'
check_all

append 'T004 given up by implement'
echo "T004: no database to migrate" > "$state/blocked.md"
round BLOCKED append 'T005 found by converge'
grep -qF 'T004 given up' "$state/incomplete.md" || say "the open task is not shown"
grep -qF 'no database' "$state/incomplete.md" || say "blocked.md is not shown"
grep -qF 'T002' "$state/incomplete.md" && say "a [HUMAN] task counted as given up"
[ -e "$state/blocked.md" ] && say "blocked.md was left for the next stop"

check_all
round MORE append 'T006 found by converge'
check_all
round EXHAUSTED append 'T007 found by converge'

[ "$fail" = 0 ] && echo "ok"
exit "$fail"
