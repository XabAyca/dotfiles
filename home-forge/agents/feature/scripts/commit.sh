#!/usr/bin/env bash
# Commits the feature work on the worktree branch.
# One-line gitmoji subject, no body: the repository convention.
set -euo pipefail

feature_dir=$(jq -re '.feature_directory' .specify/feature.json)
title=$(sed -n 's/^# Feature Specification: //p' "${feature_dir}/spec.md" | head -1)
[ -n "$title" ] || { echo "no title found in ${feature_dir}/spec.md" >&2; exit 1; }

git add -A
# The runner leaves its own footprint in the worktree: the installed workflow,
# the state of the run, the answers a human typed, the files that bootstrap a
# fresh checkout. None of it is the feature. Excluding it here rather than
# through a .gitignore is deliberate: a worktree branched before that ignore
# existed would carry the footprint straight into the commit.
git reset -q -- .specify/workflows \
                .specify/state \
                .specify/.workflow-install.lock \
                ':(glob).specify/agents-*'

# A run replayed on an already-committed feature has nothing to add. That is
# not an error, the rest of the workflow must carry on.
if git diff --cached --quiet; then
  printf %s SKIPPED
  exit 0
fi

git commit -q -m "✨ add ${title,}"
printf %s COMMITTED
