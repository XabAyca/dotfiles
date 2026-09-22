#!/usr/bin/env bash
# Runs `gateway reply` against a fake worktree and a stub agent: what it
# accepts, what it writes, what it refuses. No engine, no channel, no network.
set -euo pipefail

HERE=$(cd "$(dirname "$(readlink -f "$0")")" && pwd)
T=$(mktemp -d)
trap 'rm -rf "$T"' EXIT
mkdir -p "$T/bin" "$T/state/requests" "$T/state/done"

tree="$T/projects/proj/branch"
mkdir -p "$tree/.specify/workflows/runs/r1"

cat > "$T/bin/agent" <<'STUB'
#!/usr/bin/env bash
printf '%s\n' "$*" >> "$CALLED"
STUB
chmod +x "$T/bin/agent"

export PATH="$T/bin:$PATH" CALLED="$T/called"
export AGENT_GATEWAY_STATE="$T/state" AGENT_PROJECTS="$T/projects"

paused_on() {
  jq -n --arg s "$1" '{run_id: "r1", status: "paused", current_step_id: $s,
                       updated_at: "2026-09-22T06:00:00+00:00", step_results: {}}' \
    > "$tree/.specify/workflows/runs/r1/state.json"
}

request() {
  jq -n --arg tree "$tree" --arg f "${1:-}" \
    '{id: "proj_branch__r1__ship-gate__1790", kind: "gate",
      target: "proj/branch", project: "proj", run_id: "r1", step: "ship-gate",
      input: "ship_verdict", tree: $tree, answer_file: $f,
      question: "Prêt à livrer", options: ["push", "reject"], attachment: null,
      handle: "1790000000.000100"}' \
    > "$T/state/requests/proj_branch__r1__ship-gate__1790.json"
  rm -f "$T/state/done"/*.json "$CALLED"
}

fail=0
say() { echo "FAIL: $1" >&2; fail=1; }

# An offered option reaches the run as the input the gate declares.
paused_on ship-gate; request
bash "$HERE/gateway" reply proj/branch r1 push >/dev/null
grep -qxF "answer proj/branch r1 ship_verdict=push" "$CALLED" \
  || say "the option was forwarded as '$(cat "$CALLED" 2>/dev/null)'"
[ -f "$T/state/done/proj_branch__r1__ship-gate__1790.json" ] \
  || say "the answered request stayed outstanding"

# Prose is a file, never an argument, and the gate still gets one of its words.
paused_on ship-gate; request ship-answer.md
bash "$HERE/gateway" reply proj/branch r1 "pousse, mais sans la migration" >/dev/null
grep -qxF "answer proj/branch r1 ship_verdict=push" "$CALLED" \
  || say "a written answer did not carry the gate's first option"
grep -qF "sans la migration" "$tree/.specify/state/r1/ship-answer.md" 2>/dev/null \
  || say "the written answer was not left in the worktree"

# A gate that asked for two words only gets two words.
paused_on ship-gate; request
bash "$HERE/gateway" reply proj/branch r1 "vas-y" >/dev/null 2>"$T/err"
grep -qF "not one of the offered options" "$T/err" || say "prose was accepted by a gate that offers none"
[ -s "$CALLED" ] && say "the run was answered anyway"

# The run must still be waiting on the very step the question came from.
paused_on other-gate; request
bash "$HERE/gateway" reply proj/branch r1 push >/dev/null 2>"$T/err"
grep -qF "not paused on ship-gate" "$T/err" || say "a stale answer was applied"
[ -s "$CALLED" ] && say "the moved-on run was answered anyway"

# Nothing announced, nothing to answer: the menu must not invent a question.
rm -f "$T/state/requests"/*.json
if bash "$HERE/gateway" reply proj/branch r1 push 2>"$T/err"; then
  say "reply succeeded with no outstanding question"
fi
grep -qF "no question outstanding" "$T/err" || say "reply was silent about the missing question"

[ "$fail" = 0 ] && echo "ok"
exit "$fail"
