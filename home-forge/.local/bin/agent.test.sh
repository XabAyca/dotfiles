#!/usr/bin/env bash
# The naming call is the only thing standing between a French description and
# a French branch, so what it makes of an answer is worth pinning down. Stub
# claude, no model; done gets a throwaway repo and worktree.
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

# retry clears what the steps it runs again rewrite, and keeps the rest.
retry_from() {
  local run=$T/projects/p/r/.specify/workflows/runs/r1 s=$T/projects/p/r/.specify/state/r1
  mkdir -p "$run" "$s"
  printf -- '- id: decision-gate\n  answer_file: decision-answer.md\n  verdict_input: decision_verdict\n- id: review-loop\n- id: ship-gate\n  verdict_input: ship_verdict\n' > "$run/workflow.yml"
  echo '{"status":"completed","current_step_index":2,"current_step_id":"ship-gate"}' > "$run/state.json"
  echo '{"inputs":{"decision_verdict":"approve","ship_verdict":"reject"}}' > "$run/inputs.json"
  touch "$s/review.json" "$s/decision-answer.md" "$s/ship.md"
  ( PROJECTS=$T/projects; idle_or_die() { :; }; in_tmux() { :; }; retry p/r r1 "$1" >/dev/null )
}
retry_from ship-gate
s=$T/projects/p/r/.specify/state/r1
[ -e "$s/review.json" ] || { echo "FAIL: a rewind past the review dropped its verdict" >&2; fail=1; }
[ -e "$s/decision-answer.md" ] || { echo "FAIL: a rewind past the decision dropped its answer" >&2; fail=1; }
[ -e "$s/ship.md" ] && { echo "FAIL: a rewind to the ship gate kept the old summary" >&2; fail=1; }
[ "$(jq -r '.inputs | .decision_verdict + "/" + .ship_verdict' "$T/projects/p/r/.specify/workflows/runs/r1/inputs.json")" = approve/ ] \
  || { echo "FAIL: the rewind cleared the wrong verdicts" >&2; fail=1; }
retry_from review-loop
[ -e "$s/review.json" ] && { echo "FAIL: a rewind to the review kept the old verdict" >&2; fail=1; }

# A new worktree reads main's secrets through a link; one it already has stays.
mkdir -p "$T/env/main" "$T/env/new" "$T/env/own"
echo SECRET=1 > "$T/env/main/.env"
echo OWN=1 > "$T/env/own/.env"
link_env "$T/env/main" "$T/env/new"
link_env "$T/env/main" "$T/env/own"
[ "$(readlink "$T/env/new/.env")" = "$T/env/main/.env" ] || { echo "FAIL: link_env did not link .env" >&2; fail=1; }
[ "$(cat "$T/env/own/.env")" = OWN=1 ] || { echo "FAIL: link_env replaced an existing .env" >&2; fail=1; }

# done tears down what the bootstrap set up before the worktree goes.
for cmd in record tmux; do printf '#!/usr/bin/env bash\n' > "$T/bin/$cmd"; chmod +x "$T/bin/$cmd"; done
PROJECTS="$T/projects"
git init -q "$PROJECTS/p/main"
git -C "$PROJECTS/p/main" commit -q --allow-empty -m init
git -C "$PROJECTS/p/main" worktree add -q "$PROJECTS/p/b"
mkdir "$PROJECTS/p/b/.specify"
printf '#!/usr/bin/env bash\npwd > "%s/torn"\n' "$T" > "$PROJECTS/p/b/.specify/agents-teardown.sh"
chmod +x "$PROJECTS/p/b/.specify/agents-teardown.sh"
done_ p/b >/dev/null
[ "$(cat "$T/torn" 2>/dev/null)" = "$PROJECTS/p/b" ] || { echo "FAIL: done did not run the teardown in the worktree" >&2; fail=1; }
[ -e "$PROJECTS/p/b" ] && { echo "FAIL: done left the worktree" >&2; fail=1; }

[ "$fail" = 0 ] && echo "ok"
exit "$fail"
