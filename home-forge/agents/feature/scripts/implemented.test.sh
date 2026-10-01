#!/usr/bin/env bash
# Runs implemented.sh on a throwaway tasks.md. No model.
set -euo pipefail

HERE=$(cd "$(dirname "$(readlink -f "$0")")" && pwd)
T=$(mktemp -d)
trap 'rm -rf "$T"' EXIT

cd "$T"
fail=0
passes() { bash "$HERE/implemented.sh" 2>/dev/null || { echo "FAIL: $1" >&2; fail=1; }; }
fails() { bash "$HERE/implemented.sh" 2>/dev/null && { echo "FAIL: $1" >&2; fail=1; }; return 0; }

mkdir -p .specify specs/001
echo '{"feature_directory": "specs/001"}' > .specify/feature.json

printf -- '- [x] T001 done\n- [ ] T002 given up\n' > specs/001/tasks.md
fails "an open task passed"

printf -- '- [x] T001 done\n  - [ ] T002 [HUMAN] ask legal\n' > specs/001/tasks.md
passes "an open [HUMAN] task stopped the run"

printf -- '- [x] T001 done\n- [x] T002 done\n' > specs/001/tasks.md
passes "a finished tasks.md stopped the run"

[ "$fail" = 0 ] && echo "ok"
exit "$fail"
