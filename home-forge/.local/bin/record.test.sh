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

# A shipped run keeps what a retro needs once the worktree is gone: what it
# repaired, what the reviews said, and what it pushed.
tree="$T/projects/proj/shipped"
run="$tree/.specify/workflows/runs/r2"
mkdir -p "$run" "$tree/.specify/state/r2"
git -C "$tree" init -q && git -C "$tree" -c user.name=t -c user.email=t@t commit -q --allow-empty -m init
echo 'version: "0.22.0"' > "$run/workflow.yml"
jq -n '{run_id: "r2", workflow_id: "feature", status: "completed", current_step_id: "do-open-pr",
        step_results: {"do-open-pr": {status: "completed",
          output: {stdout: "branch set up\nhttps://github.com/o/r/pull/7\n"}},
        "ship-summary": {output: {stdout: "Prêt à livrer"}}}}' > "$run/state.json"
cp "$T/projects/proj/branch/.specify/workflows/runs/r1/log.jsonl" "$run/log.jsonl"
echo '{"status":"DONE","summary":"s","bullets":["Note: plural label"]}' > "$tree/.specify/state/r2/review.json"
echo '{"critical":0,"high":1,"summary":"s","findings":[]}' > "$tree/.specify/state/r2/analyze.json"
echo '{"check":"decision","at":"2026-10-05T08:00:00+02:00","reason":"parse error\n"}' \
  > "$tree/.specify/state/r2/repairs.jsonl"

bash "$HERE/record" run proj/shipped >/dev/null
rec="$T/records/proj_shipped__r2.json"
[ "$(jq -r .pr_url "$rec")" = https://github.com/o/r/pull/7 ] || say "the pull request was not kept"
[ "$(jq -r .shipped_sha "$rec")" = "$(git -C "$tree" rev-parse HEAD)" ] || say "the pushed commit was not kept"
[ "$(jq -r '.repairs[0].check' "$rec")" = decision ] || say "the repairs were not kept"
[ "$(jq -r '.review.bullets[0]' "$rec")" = "Note: plural label" ] || say "the review bullets were not kept"
[ "$(jq -r '.repairs | length' "$T/records/proj_branch__r1.json")" = 0 ] || say "a run with no repair got some"
[ "$(jq -r '.analysis.high' "$rec")" = 1 ] || say "the analysis counts were not kept"
[ "$(jq -r '.ship_title' "$rec")" = "Prêt à livrer" ] || say "the ship gate title was not kept"
[ "$(jq -r '.analysis' "$T/records/proj_branch__r1.json")" = null ] || say "a run with no analysis got one"

[ "$fail" = 0 ] && echo "ok"
exit "$fail"
