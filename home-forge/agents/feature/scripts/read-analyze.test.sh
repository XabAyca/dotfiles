#!/usr/bin/env bash
# Runs read-analyze.sh on throwaway analyses: the decision each one must give,
# and a [HUMAN] task reaching the gate whatever its severity. No model.
set -euo pipefail

HERE=$(cd "$(dirname "$(readlink -f "$0")")" && pwd)
T=$(mktemp -d)
trap 'rm -rf "$T"' EXIT

cd "$T"
mkdir -p .specify/state/r1 specs/001
echo '{"feature_directory": "specs/001"}' > .specify/feature.json
echo '- [ ] T002 build it' > specs/001/tasks.md

fail=0
is() {
  local want=$1 json=$2 got
  echo "$json" > .specify/state/r1/analyze.json
  got=$(bash "$HERE/read-analyze.sh" r1)
  [ "$got" = "$want" ] || { echo "FAIL: '$got', not '$want', for $json" >&2; fail=1; }
  return 0
}

is CLEAR '{"critical": 0, "high": 0, "summary": "s", "findings": []}'
is CONCERNS '{"critical": 0, "high": 2, "summary": "s", "findings": ["H1 one"]}'
is BLOCKING '{"critical": 1, "high": 0, "summary": "s", "findings": ["C1 cents or BigDecimal"]}'
grep -qxF -- '- C1 cents or BigDecimal' .specify/state/r1/analyze.md || { echo "FAIL: findings not shown" >&2; fail=1; }

echo '- [ ] T001 [HUMAN] check the prod timezone on Scalingo' >> specs/001/tasks.md
is BLOCKING '{"critical": 0, "high": 0, "summary": "s", "findings": []}'
grep -qF 'T001 [HUMAN]' .specify/state/r1/analyze.md || { echo "FAIL: the [HUMAN] task is not shown" >&2; fail=1; }

sed -i 's/- \[ \] T001/- [x] T001/' specs/001/tasks.md
is CLEAR '{"critical": 0, "high": 0, "summary": "s", "findings": []}'

[ "$fail" = 0 ] && echo "ok"
exit "$fail"
