#!/usr/bin/env bash
# Runs notify against a stub curl: what it sends, what it makes of a refusal.
# No token, no network, no workspace.
set -euo pipefail

HERE=$(cd "$(dirname "$(readlink -f "$0")")" && pwd)
T=$(mktemp -d)
trap 'rm -rf "$T"' EXIT
mkdir -p "$T/bin"

cat > "$T/bin/curl" <<'STUB'
#!/usr/bin/env bash
cat > "$CURL_BODY"
out=${FAKE_POST:-}
[ -n "$out" ] || out='{"ok":true,"ts":"1790000000.000100"}'
printf %s "$out"
STUB
chmod +x "$T/bin/curl"

req="$T/req.json"
jq -n '{kind: "gate", target: "proj/branch", run_id: "r1", step: "ship-gate",
        title: "Prêt à livrer", url: ""}' > "$req"

export PATH="$T/bin:$PATH" CURL_BODY="$T/sent.json"
export SLACK_BOT_TOKEN=xoxb-test SLACK_CONVERSATION=D0TEST

fail=0
say() { echo "FAIL: $1" >&2; fail=1; }

# A gate is a title, where it waits, and where to go answer it.
bash "$HERE/notify" "$req"
jq -e . "$T/sent.json" >/dev/null || say "the posted body is not valid JSON"
[ "$(jq -r .channel "$T/sent.json")" = D0TEST ] || say "wrong channel in the posted body"
text=$(jq -r .text "$T/sent.json")
[ "$(head -1 <<< "$text")" = '❓ *Prêt à livrer* — `proj/branch` · étape `ship-gate`' ] \
  || say "the header line is '$(head -1 <<< "$text")'"
grep -qF '`agent menu`' <<< "$text" || say "the message does not say where to answer"

# A finished run names its pull request instead.
jq '.kind = "done" | .title = "Run terminé" | .url = "https://example.test/pr/1"' "$req" > "$T/done.json"
bash "$HERE/notify" "$T/done.json"
text=$(jq -r .text "$T/sent.json")
grep -q '^✅ \*Run terminé\*' <<< "$text" || say "a finished run is not marked as one"
grep -qxF 'https://example.test/pr/1' <<< "$text" || say "the pull request is missing"

jq '.kind = "failure" | .title = "Run en échec"' "$req" > "$T/fail.json"
bash "$HERE/notify" "$T/fail.json"
grep -q '^🚨 \*Run en échec\*' <<< "$(jq -r .text "$T/sent.json")" || say "a failure is not marked as one"

# A refusal from Slack is a failure, not a message posted into the void.
if FAKE_POST='{"ok":false,"error":"not_in_channel"}' bash "$HERE/notify" "$req" 2>"$T/err"; then
  say "notify succeeded on a Slack error"
fi
grep -qF "not_in_channel" "$T/err" || say "notify swallowed the Slack error"

[ "$fail" = 0 ] && echo "ok"
exit "$fail"
