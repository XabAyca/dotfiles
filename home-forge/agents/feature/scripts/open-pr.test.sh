#!/usr/bin/env bash
# Runs open-pr.sh against stub git and gh, once with no pull request on the
# branch and once with one already open. No network, no repository.
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

[ "$fail" = 0 ] && echo "ok"
exit "$fail"
