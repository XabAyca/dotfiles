#!/usr/bin/env bash
# The naming call is the only thing standing between a French description and
# a French branch, so what it makes of an answer is worth pinning down. Stub
# claude, no model, no worktree.
set -euo pipefail

HERE=$(cd "$(dirname "$(readlink -f "$0")")" && pwd)
T=$(mktemp -d)
trap 'rm -rf "$T"' EXIT
mkdir -p "$T/bin"

cat > "$T/bin/claude" <<'STUB'
#!/usr/bin/env bash
printf '%s' "${FAKE_SLUG-}"
STUB
chmod +x "$T/bin/claude"

export PATH="$T/bin:$PATH"
AGENT_LIB=1 . "$HERE/agent"

fail=0
is() {
  local want=$1 answer=$2 got
  got=$(FAKE_SLUG="$answer" english_short_name "peu importe la description")
  [ "$got" = "$want" ] || { echo "FAIL: '$answer' gave '$got', not '$want'" >&2; fail=1; }
}

is plan-status-archive 'plan-status-archive'
is plan-status-archive 'Plan Status Archive'
is export-csv-enfin '  Export CSV, enfin !  '
# Git takes anything, a human reads four words: the rest is dropped, not kept.
is one-two-three-four 'one two three four five six'
# Nothing usable is not a failure — Spec Kit names the branch as it always did.
is '' ''
is '' '   '
[ "$(FAKE_SLUG="$(printf 'a%.0s' {1..80})" english_short_name x | wc -c)" -le 41 ] \
  || { echo "FAIL: a long answer was not cut down" >&2; fail=1; }

# A frozen run has its steps at column 0; a nested id must not be offered as a
# rewind point, retry would refuse it.
cat > "$T/workflow.yml" <<'YML'
steps:
- id: plan
  steps:
  - id: plan-gate
- id: review-loop
  steps:
    - id: review
- id: ship
YML
got=$(top_steps "$T/workflow.yml" | tr '\n' ' ')
[ "$got" = "plan review-loop ship " ] || { echo "FAIL: top_steps gave '$got'" >&2; fail=1; }

[ "$fail" = 0 ] && echo "ok"
exit "$fail"
