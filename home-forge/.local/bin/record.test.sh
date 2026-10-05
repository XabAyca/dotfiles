#!/usr/bin/env bash
# Runs record on a fake failed run: why it stopped must outlive the worktree.
set -euo pipefail

HERE=$(cd "$(dirname "$(readlink -f "$0")")" && pwd)
T=$(mktemp -d)
trap 'rm -rf "$T"' EXIT

export AGENT_RECORD_STATE="$T/records" AGENT_PROJECTS="$T/projects"
run="$T/projects/proj/branch/.specify/workflows/runs/r1"
mkdir -p "$run"
echo 'version: "0.22.0"' > "$run/workflow.yml"
jq -n '{run_id: "r1", workflow_id: "feature", status: "failed",
        current_step_id: "implemented", error: "Shell command exited with code 1.",
        step_results: {implemented: {output: {stderr: "implement left tasks open:\n- [ ] T004\n"}}}}' \
  > "$run/state.json"
{
  echo '{"event":"step_started","step_id":"implemented","type":"shell","timestamp":"2026-10-05T08:00:00+00:00"}'
  echo '{"event":"step_failed","step_id":"implemented","timestamp":"2026-10-05T08:00:01+00:00"}'
} > "$run/log.jsonl"

fail=0
say() { echo "FAIL: $1" >&2; fail=1; }

bash "$HERE/record" run proj/branch >/dev/null
rec="$T/records/proj_branch__r1.json"
[ "$(jq -r .failed_at "$rec")" = implemented ] || say "the failed step was not kept"
jq -r .stderr "$rec" | grep -qF 'T004' || say "the reason it stopped was not kept"
bash "$HERE/record" log | grep -qF 'failed at implemented' || say "the log does not say where it failed"

[ "$fail" = 0 ] && echo "ok"
exit "$fail"
