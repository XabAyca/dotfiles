#!/usr/bin/env bash
# Runs retro against stub gh and claude: what it hands the model, and where
# the answer lands. No network, no model.
set -euo pipefail

HERE=$(cd "$(dirname "$(readlink -f "$0")")" && pwd)
T=$(mktemp -d)
trap 'rm -rf "$T"' EXIT
mkdir -p "$T/bin" "$T/records" "$T/dotfiles"

# The PR the run pushed at b, then a person added c and d.
cat > "$T/bin/gh" <<'STUB'
#!/usr/bin/env bash
case "$*" in
  *pull/7*) echo '{"state":"MERGED","commits":[{"oid":"a"},{"oid":"b"},{"oid":"c"},{"oid":"d"}]}' ;;
  *) exit 1 ;;
esac
STUB
cat > "$T/bin/claude" <<'STUB'
#!/usr/bin/env bash
cat > "$SENT"
printf '%s\n' "$@" > "$ARGS"
echo "# Bilan"
STUB
chmod +x "$T/bin/gh" "$T/bin/claude"

export PATH="$T/bin:$PATH" SENT="$T/sent.json" ARGS="$T/args"
export AGENT_RECORD_STATE="$T/records" AGENT_RETRO_STATE="$T/retro" AGENT_DOTFILES="$T/dotfiles"

echo '{"run_id":"old","pr_url":null,"shipped_sha":null}' > "$T/records/old.json"
sleep 1
echo '{"run_id":"gone","pr_url":"https://github.com/o/r/pull/9","shipped_sha":"x"}' > "$T/records/gone.json"
echo '{"run_id":"fixed","pr_url":"https://github.com/o/r/pull/7","shipped_sha":"b"}' > "$T/records/fixed.json"

fail=0
say() { echo "FAIL: $1" >&2; fail=1; }

out=$(bash "$HERE/retro" 2)
[ -f "$out" ] || say "retro printed '$out', not the file it wrote"
grep -qx '# Bilan' "$out" 2>/dev/null || say "the model's answer is not in the retro"

[ "$(jq length "$SENT")" = 2 ] || say "retro 2 sent $(jq length "$SENT") runs"
jq -e 'map(.run_id) | index("old") == null' "$SENT" >/dev/null || say "an older run was sent past the limit"
[ "$(jq -r '.[] | select(.run_id == "fixed") | .pr.fixed_after' "$SENT")" = 2 ] \
  || say "the commits added after the run were not counted"
[ "$(jq -r '.[] | select(.run_id == "fixed") | .pr.state' "$SENT")" = MERGED ] \
  || say "the PR state was not kept"
[ "$(jq -r '.[] | select(.run_id == "gone") | .pr' "$SENT")" = null ] \
  || say "an unreadable PR was given an outcome"

grep -qx 'Edit' "$ARGS" && grep -qx -- '--disallowedTools' "$ARGS" \
  || say "the model was allowed to edit"

if bash "$HERE/retro" nope 2>/dev/null; then say "a bad count was accepted"; fi

# Weekly, nothing new since the last retro means no model call and no path.
rm -f "$SENT"
out=$(bash "$HERE/retro" --if-new 2)
[ -z "$out" ] || say "--if-new printed '$out' with nothing new"
[ -e "$SENT" ] && say "--if-new called the model with nothing new"
sleep 1; touch "$T/records/fixed.json"
out=$(bash "$HERE/retro" --if-new 2)
[ -f "$out" ] || say "--if-new skipped a run recorded since the last retro"

[ "$fail" = 0 ] && echo "ok"
exit "$fail"
