#!/usr/bin/env bash
# Commits the feature work as the agent split it, one topic per commit.
# list: writes what changed for the agent to split. apply: commits its split.
# The agent never runs git; it only writes commits.json.
set -euo pipefail

. "$(dirname "$(readlink -f "$0")")/runner-paths.sh"

run_id=${1:?missing run_id}
mode=${2:?missing mode: list|apply}

state=".specify/state/${run_id}"
mkdir -p "$state"

if [ "$mode" = list ]; then
  git add -A
  # Excluded here and not through a .gitignore: a worktree branched before that
  # ignore existed would carry the footprint straight into the commit.
  git reset -q -- "${RUNNER_PATHSPEC[@]}"

  # A replayed run has nothing to add, and that is not an error.
  if git diff --cached --quiet; then
    printf %s SKIPPED
    exit 0
  fi

  # --no-renames: a rename is a deletion plus an addition, and both paths
  # must land in some commit.
  git diff --cached --no-renames --name-only > "${state}/changes.txt"
  git diff --cached --no-renames > "${state}/changes.diff"
  git reset -q
  printf %s CHANGES
  exit 0
fi

# A replayed run finds the split already committed.
if [ -z "$(git status --porcelain -- "${RUNNER_EXCLUDE[@]}")" ]; then
  printf %s SKIPPED
  exit 0
fi

plan="${state}/commits.json"
[ -f "$plan" ] || { echo "no split written at $plan" >&2; exit 1; }

# Checked in full before the first commit, so a bad split commits nothing.
bad=$(jq -r '.[] | select((.subject | test("^(:[a-z0-9_+-]+:|[^\\x00-\\x7F]+) [^\n]+$")) and (.paths | length > 0) | not) | .subject' "$plan")
[ -z "$bad" ] || { echo "no one-line gitmoji subject, or no path: $bad" >&2; exit 1; }

missing=$(comm -23 <(sort -u "${state}/changes.txt") <(jq -r '.[].paths[]' "$plan" | sort -u))
[ -z "$missing" ] || { echo "left out of every commit: $missing" >&2; exit 1; }
unknown=$(comm -13 <(sort -u "${state}/changes.txt") <(jq -r '.[].paths[]' "$plan" | sort -u))
[ -z "$unknown" ] || { echo "not among the changes: $unknown" >&2; exit 1; }
twice=$(jq -r '.[].paths[]' "$plan" | sort | uniq -d)
[ -z "$twice" ] || { echo "in more than one commit: $twice" >&2; exit 1; }

count=$(jq length "$plan")
for ((i = 0; i < count; i++)); do
  mapfile -t paths < <(jq -r ".[$i].paths[]" "$plan")
  git add -A -- "${paths[@]}"
  git commit -q -m "$(jq -r ".[$i].subject" "$plan")"
done

[ -z "$(git status --porcelain -- "${RUNNER_EXCLUDE[@]}")" ] || {
  echo "still uncommitted after the split:" >&2
  git status --porcelain -- "${RUNNER_EXCLUDE[@]}" >&2
  exit 1
}
printf %s COMMITTED
