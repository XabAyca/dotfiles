#!/usr/bin/env bash
# Runs notify and poll against a stub curl: what they send, what they make of
# what comes back. No token, no network, no workspace.
set -euo pipefail

HERE=$(cd "$(dirname "$(readlink -f "$0")")" && pwd)
T=$(mktemp -d)
trap 'rm -rf "$T"' EXIT
mkdir -p "$T/bin"

cat > "$T/bin/curl" <<'STUB'
#!/usr/bin/env bash
case "$*" in
  *chat.postMessage*)
    cat > "$CURL_BODY"
    out=${FAKE_POST:-}
    [ -n "$out" ] || out='{"ok":true,"ts":"1790000000.000100"}'
    printf %s "$out" ;;
  *conversations.replies*)
    out=${FAKE_REPLIES:-}
    [ -n "$out" ] || out='{"ok":true,"messages":[{"ts":"1790000000.000100","text":"the question"}]}'
    printf %s "$out" ;;
esac
STUB
chmod +x "$T/bin/curl"

req="$T/req.json"
cat > "$req" <<JSON
{"id":"proj_branch__r1__ship-gate__1790",
 "kind":"gate","target":"proj/branch","run_id":"r1","step":"ship-gate",
 "question":"Pr\u00eat \u00e0 livrer\n\nTout est commit\u00e9 sur la branche.\n\u2022 \`push\` \u2014 je pousse",
 "options":["push","reject"],"answer_file":"",
 "tree":"$T","attachment":"verdict.json",
 "handle":"1790000000.000100"}
JSON
cat > "$T/verdict.json" <<'JSON'
{"status":"PASS","summary":"tout tient","bullets":["la migration passe"]}
JSON

export PATH="$T/bin:$PATH" CURL_BODY="$T/sent.json"
export SLACK_BOT_TOKEN=xoxb-test SLACK_CONVERSATION=D0TEST

fail=0
say() { echo "FAIL: $1" >&2; fail=1; }

# notify posts the question and hands back the timestamp that keys the thread.
out=$(bash "$HERE/notify" "$req")
[ "$out" = "1790000000.000100" ] || say "notify returned '$out'"
jq -e . "$T/sent.json" >/dev/null || say "the posted body is not valid JSON"
[ "$(jq -r .channel "$T/sent.json")" = D0TEST ] || say "wrong channel in the posted body"
text=$(jq -r .text "$T/sent.json")
# The gate writes what is said; the channel only frames it. A title on the
# header line, the rest of the message as it stands, the digest quoted.
head -1 <<< "$text" | grep -qF '❓ *Prêt à livrer* — `proj/branch`' \
  || say "the header line is '$(head -1 <<< "$text")'"
grep -qF '• `push` — je pousse' <<< "$text" || say "the gate's own options are missing"
grep -qF '> *PASS* — tout tient' <<< "$text" || say "the digest is not quoted into the body"
grep -qF '> • la migration passe' <<< "$text" || say "the digest bullets are missing"
grep -qF 'run `r1` · étape `ship-gate`' <<< "$text" || say "the footer is missing"

# A failure is not a question, and reads as one at a glance.
jq '.kind = "failure" | .question = "Run en échec\n\nrien à répondre"' "$req" > "$T/fail.json"
bash "$HERE/notify" "$T/fail.json" >/dev/null
grep -q '^🚨 \*Run en échec\*' <<< "$(jq -r .text "$T/sent.json")" || say "a failure is not marked as one"

# A refusal from Slack is a failure, not a message posted into the void.
if FAKE_POST='{"ok":false,"error":"not_in_channel"}' bash "$HERE/notify" "$req" 2>"$T/err"; then
  say "notify succeeded on a Slack error"
fi
grep -qF "not_in_channel" "$T/err" || say "notify swallowed the Slack error"

# The parent message is never an answer: a thread with only it is silence.
out=$(bash "$HERE/poll" "$req")
[ -z "$out" ] || say "poll took the question for an answer: '$out'"

replies='{"ok":true,"messages":[
  {"ts":"1790000000.000100","text":"the question"},
  {"ts":"1790000009.000200","text":"push"}]}'
out=$(FAKE_REPLIES="$replies" bash "$HERE/poll" "$req")
[ "$out" = push ] || say "poll returned '$out' instead of the reply"

out=$(FAKE_REPLIES='{"ok":false,"error":"missing_scope"}' bash "$HERE/poll" "$req" 2>"$T/err")
[ -z "$out" ] || say "poll answered '$out' on a Slack error"
grep -qF "missing_scope" "$T/err" || say "poll swallowed the Slack error"

[ "$fail" = 0 ] && echo "ok"
exit "$fail"
