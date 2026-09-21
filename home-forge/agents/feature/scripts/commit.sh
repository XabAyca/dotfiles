#!/usr/bin/env bash
# Commits the feature work. Gitmoji subject, no body: the repo convention.
set -euo pipefail

. "$(dirname "$(readlink -f "$0")")/runner-paths.sh"

feature_dir=$(jq -re '.feature_directory' .specify/feature.json)
title=$(sed -n '/^# /{s/^# [^:]*:[[:space:]]*//p;q}' "${feature_dir}/spec.md")
[ -n "$title" ] || { echo "no title found in ${feature_dir}/spec.md" >&2; exit 1; }

git add -A
# Excluded here and not through a .gitignore: a worktree branched before that
# ignore existed would carry the footprint straight into the commit.
git reset -q -- "${RUNNER_PATHSPEC[@]}"

# A replayed run has nothing to add, and that is not an error.
if git diff --cached --quiet; then
  printf %s SKIPPED
  exit 0
fi

git commit -q -m "✨ add ${title,}"
printf %s COMMITTED
