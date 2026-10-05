#!/usr/bin/env bash
# Runs open-pr.sh against stub git and gh: with and without a pull request on
# the branch, with and without a template. No network, no repository.
set -euo pipefail

HERE=$(cd "$(dirname "$(readlink -f "$0")")" && pwd)
T=$(mktemp -d)
trap 'rm -rf "$T"' EXIT

mkdir -p "$T/bin" "$T/repo/.specify/state/r1" "$T/repo/.specify/workflows/runs/r1" \
         "$T/repo/specs/001-x"

cat > "$T/bin/git" <<'STUB'
#!/usr/bin/env bash
case "$1 $2" in
  "branch --show-current") echo "001-x" ;;
  "log --reverse")         printf -- '- :sparkles: add a thing\n- :memo: describe it\n' ;;
  *)                       echo "[git $*]" ;;
esac
STUB

# FAKE_OPEN_PR stands for the pull request the branch already has.
cat > "$T/bin/gh" <<'STUB'
#!/usr/bin/env bash
case "$1 $2" in
  "repo view") echo "main" ;;
  "pr list")   [ -n "${FAKE_OPEN_PR:-}" ] && echo "$FAKE_OPEN_PR"; exit 0 ;;
  *)           echo "[gh $*]" ;;
esac
STUB
chmod +x "$T/bin/git" "$T/bin/gh"

cd "$T/repo"
echo '{"feature_directory":"specs/001-x"}' > .specify/feature.json
echo '# 001-x: add a thing' > specs/001-x/spec.md
echo '  version: "3"' > .specify/workflows/runs/r1/workflow.yml
echo '{"status":"clean","bullets":["all good"]}' > .specify/state/r1/review.json
export PATH="$T/bin:$PATH"

fail=0
expect() {
  local out=$1 want=$2 text=$3
  if [ "$want" = yes ]; then grep -qF -- "$text" <<< "$out" || { echo "FAIL: missing '$text'" >&2; fail=1; }
  else grep -qF -- "$text" <<< "$out" && { echo "FAIL: unexpected '$text'" >&2; fail=1; }; fi
  return 0
}

out=$(bash "$HERE/open-pr.sh" r1)
expect "$out" yes  "[git push -u origin HEAD]"
expect "$out" yes  "[gh pr create --draft --base main"
expect "$out" no   "pr comment"

out=$(FAKE_OPEN_PR="https://github.com/o/r/pull/42" bash "$HERE/open-pr.sh" r1)
expect "$out" yes  "[git push -u origin HEAD]"
expect "$out" yes  "pushed to the open pull request: https://github.com/o/r/pull/42"
expect "$out" yes  "[gh pr comment --body-file"
expect "$out" no   "pr create"

# No template: the commits are the summary, and nothing else is said.
out=$(bash "$HERE/open-pr.sh" r1)
[ "$(cat .specify/state/r1/pr-body.md)" = "$(printf -- '- :sparkles: add a thing\n- :memo: describe it')" ] \
  || { echo "FAIL: the body is not the commit list: $(cat .specify/state/r1/pr-body.md)" >&2; fail=1; }

# A template the step before filled is the body, as written.
mkdir -p .github
echo '## Summary' > .github/PULL_REQUEST_TEMPLATE.md
[ "$(bash "$HERE/pr-template.sh")" = .github/PULL_REQUEST_TEMPLATE.md ] \
  || { echo "FAIL: the template was not found" >&2; fail=1; }
printf '## Summary\n\nAdds a thing.\n' > .specify/state/r1/pr-body.md
out=$(bash "$HERE/open-pr.sh" r1)
grep -qF 'Adds a thing.' .specify/state/r1/pr-body.md \
  || { echo "FAIL: the filled template was replaced" >&2; fail=1; }

# A template nobody filled still ships, with the commits.
: > .specify/state/r1/pr-body.md
out=$(bash "$HERE/open-pr.sh" r1)
grep -qF -- '- :sparkles: add a thing' .specify/state/r1/pr-body.md \
  || { echo "FAIL: an unfilled template left the body empty" >&2; fail=1; }

# Elsewhere and in another case, GitHub still finds it.
rm -r .github; mkdir docs; echo x > docs/pull_request_template.md
[ "$(bash "$HERE/pr-template.sh")" = docs/pull_request_template.md ] \
  || { echo "FAIL: a template in docs/ was not found" >&2; fail=1; }
rm -r docs
[ -z "$(bash "$HERE/pr-template.sh")" ] || { echo "FAIL: a template was found where there is none" >&2; fail=1; }

[ "$fail" = 0 ] && echo "ok"
exit "$fail"
