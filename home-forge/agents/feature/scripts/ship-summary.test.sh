#!/usr/bin/env bash
# Runs ship-summary.sh on throwaway verdicts: a failed review is said out loud,
# and what the run gave up on reaches the gate. No model.
set -euo pipefail

HERE=$(cd "$(dirname "$(readlink -f "$0")")" && pwd)
T=$(mktemp -d)
trap 'rm -rf "$T"' EXIT

cd "$T"
state=.specify/state/r1
mkdir -p "$state"

fail=0
shown() { grep -qF -- "$1" "$state/ship.md" || { echo "FAIL: $2" >&2; fail=1; }; }
hidden() { grep -qF -- "$1" "$state/ship.md" && { echo "FAIL: $2" >&2; fail=1; }; return 0; }
titled() { [ "$title" = "$1" ] || { echo "FAIL: $2 (got: $title)" >&2; fail=1; }; }

echo '{"status": "DONE", "summary": "all good", "bullets": ["adds snapshots"]}' > "$state/review.json"
title=$(bash "$HERE/ship-summary.sh" r1)
shown '| interface review | ABSENT |' "a missing ui verdict is not reported"
shown '- adds snapshots' "the review bullets are not shown"
hidden 'pas passées' "a passed review was flagged"
titled "Prêt à livrer" "a passed review was not titled ready"

echo '{"status": "NEEDS_FIX", "summary": "plural", "bullets": []}' > "$state/ui.json"
title=$(bash "$HERE/ship-summary.sh" r1)
shown 'pas passées' "a failed interface review was not flagged"
titled "Pas prêt à livrer : les reviews ne sont pas passées" "a failed interface review was titled ready"

rm "$state/review.json" "$state/ui.json"
title=$(bash "$HERE/ship-summary.sh" r1)
shown 'pas passées' "a review that never ran was not flagged"
titled "Pas prêt à livrer : les reviews ne sont pas passées" "a review that never ran was titled ready"

mkdir -p specs/001
echo '{"feature_directory": "specs/001"}' > .specify/feature.json
printf -- '- [x] T003 done\n- [ ] T004 [HUMAN] ask legal\n' > specs/001/tasks.md
printf '# Implementation incomplete — run r1\n\n- [ ] T003 given up\n' > "$state/incomplete.md"
title=$(bash "$HERE/ship-summary.sh" r1)
shown '## Tâches encore ouvertes' "the open tasks are not shown"
shown 'T004 [HUMAN] ask legal' "the open task is not shown"
hidden 'T003 given up' "a task the repair finished is still shown open"

[ "$fail" = 0 ] && echo "ok"
exit "$fail"
