#!/usr/bin/env bash
# Runs the gateway against a fake worktree and a stub agent: what `reply`
# accepts, writes and refuses, and what `scan` says, once. No engine, no
# network.
set -euo pipefail

HERE=$(cd "$(dirname "$(readlink -f "$0")")" && pwd)
T=$(mktemp -d)
trap 'rm -rf "$T"' EXIT
mkdir -p "$T/bin"

run="$T/projects/proj/branch/.specify/workflows/runs/r1"
mkdir -p "$run"

cat > "$T/bin/agent" <<'STUB'
#!/usr/bin/env bash
printf '%s\n' "$*" >> "$CALLED"
STUB
printf '#!/usr/bin/env bash\n' > "$T/bin/record"
chmod +x "$T/bin/agent" "$T/bin/record"

export PATH="$T/bin:$PATH" CALLED="$T/called"
export AGENT_GATEWAY_STATE="$T/state" AGENT_PROJECTS="$T/projects"
export AGENT_GATEWAY_CHANNEL=file

# The gate declares where its answer goes; the engine records what it asked.
workflow() {
  {
    echo 'steps:'
    echo '  - id: ship-gate'
    echo '    type: gate'
    [ -n "${1:-}" ] && echo "    answer_file: $1"
    echo '    verdict_input: ship_verdict'
  } > "$run/workflow.yml"
}

paused_on() {
  jq -n --arg s "$1" '{run_id: "r1", status: "paused", current_step_id: $s,
      updated_at: "2026-09-22T06:00:00+00:00",
      step_results: {($s): {output: {message: "Prêt à livrer\n\nle détail",
                                     options: ["push", "reject"]}}}}' \
    > "$run/state.json"
  rm -f "$CALLED"
}

fail=0
say() { echo "FAIL: $1" >&2; fail=1; }

# An offered option reaches the run as the input the gate declares.
workflow; paused_on ship-gate
bash "$HERE/gateway" reply proj/branch r1 push >/dev/null
grep -qxF "answer proj/branch r1 ship_verdict=push" "$CALLED" \
  || say "the option was forwarded as '$(cat "$CALLED" 2>/dev/null)'"

# Prose is a file, never an argument, and the gate still gets one of its words.
workflow ship-answer.md; paused_on ship-gate
bash "$HERE/gateway" reply proj/branch r1 "pousse, mais sans la migration" >/dev/null
grep -qxF "answer proj/branch r1 ship_verdict=push" "$CALLED" \
  || say "a written answer did not carry the gate's first option"
grep -qF "sans la migration" "$T/projects/proj/branch/.specify/state/r1/ship-answer.md" 2>/dev/null \
  || say "the written answer was not left in the worktree"

# A gate that asked for two words only gets two words.
workflow; paused_on ship-gate
if bash "$HERE/gateway" reply proj/branch r1 "vas-y" >/dev/null 2>"$T/err"; then
  say "prose was accepted by a gate that offers none"
fi
grep -qF "not one of" "$T/err" || say "the refusal does not name the options"
[ -s "$CALLED" ] && say "the run was answered anyway"

# A run that is not waiting has nothing to answer.
jq '.status = "running"' "$run/state.json" > "$T/s" && mv "$T/s" "$run/state.json"
if bash "$HERE/gateway" reply proj/branch r1 push 2>"$T/err"; then
  say "a running run was answered"
fi
grep -qF "not paused on a gate" "$T/err" || say "reply was silent about the run not waiting"

# A pause is said once, with its title, however many passes see it.
workflow; paused_on ship-gate
bash "$HERE/gateway" scan >/dev/null
bash "$HERE/gateway" scan >/dev/null
[ "$(grep -c 'Prêt à livrer' "$T/state/inbox.md")" = 1 ] \
  || say "the pause was said $(grep -c 'Prêt à livrer' "$T/state/inbox.md") times"
grep -qF "le détail" "$T/state/inbox.md" && say "more than the title was sent"

# A run that reaches the end names its pull request.
jq -n '{run_id: "r1", status: "completed", current_step_id: "do-open-pr",
        updated_at: "2026-09-22T07:00:00+00:00",
        step_results: {"do-open-pr": {output: {stdout: "branch set up\nhttps://example.test/pr/1\n"}}}}' \
  > "$run/state.json"
bash "$HERE/gateway" scan >/dev/null
grep -qF "Run terminé  https://example.test/pr/1" "$T/state/inbox.md" \
  || say "the finished run was not announced with its pull request"

# A message no run asked for goes through the same channel, with what to do.
bash "$HERE/gateway" say "Bilan des runs prêt" "bat /tmp/x.md"
tail -1 "$T/state/inbox.md" | grep -qF "Bilan des runs prêt  bat /tmp/x.md" \
  || say "say did not reach the channel: $(tail -1 "$T/state/inbox.md")"

[ "$fail" = 0 ] && echo "ok"
exit "$fail"
