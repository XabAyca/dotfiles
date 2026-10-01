#!/usr/bin/env bash
# Runs decision.sh on a throwaway feature: what reaches the gate, and what
# stays out of it when there is nothing to say. No model.
set -euo pipefail

HERE=$(cd "$(dirname "$(readlink -f "$0")")" && pwd)
T=$(mktemp -d)
trap 'rm -rf "$T"' EXIT

cd "$T"
mkdir -p .specify/state/r1 specs/001
echo '{"feature_directory": "specs/001"}' > .specify/feature.json
echo '- **FR-001**: The system MUST snapshot balances.' > specs/001/spec.md
echo '- [ ] T002 build it' > specs/001/tasks.md
echo 'PLAN BODY' > specs/001/plan.md
echo '{"critical": 1, "high": 0, "summary": "s", "findings": ["C1 cents or BigDecimal"]}' \
  > .specify/state/r1/analyze.json

fail=0
shown() { grep -qF -- "$1" .specify/state/r1/decision.md || { echo "FAIL: $2" >&2; fail=1; }; }
hidden() { grep -qF -- "$1" .specify/state/r1/decision.md && { echo "FAIL: $2" >&2; fail=1; }; return 0; }

bash "$HERE/decision.sh" r1
shown '- C1 cents or BigDecimal' "the findings are not shown"
shown 'PLAN BODY' "the plan is not shown"
hidden 'Hypothèses' "a spec with no assumption got an assumptions section"
hidden 'seul un humain' "a feature with no [HUMAN] task got a human section"

echo '- **FR-016**: Paris day [ASSUMPTION: production runs in Europe/Paris]' >> specs/001/spec.md
echo '- **FR-015**: Scope is [NEEDS CLARIFICATION: payment accounts only?]' >> specs/001/spec.md
echo '- [ ] T001 [HUMAN] check the prod timezone on Scalingo' >> specs/001/tasks.md
bash "$HERE/decision.sh" r1
shown 'ASSUMPTION: production runs in Europe/Paris' "an assumption is not shown"
shown 'NEEDS CLARIFICATION: payment accounts only?' "a question left open is not shown"
shown 'T001 [HUMAN]' "the [HUMAN] task is not shown"

sed -i 's/- \[ \] T001/- [x] T001/' specs/001/tasks.md
bash "$HERE/decision.sh" r1
hidden 'T001 [HUMAN]' "a [HUMAN] task already answered is still shown"

rm .specify/state/r1/analyze.json
if bash "$HERE/decision.sh" r1 2>/dev/null; then
  echo "FAIL: a missing analysis was not an error" >&2; fail=1
fi

[ "$fail" = 0 ] && echo "ok"
exit "$fail"
