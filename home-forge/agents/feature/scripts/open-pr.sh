#!/usr/bin/env bash
# Pushes the branch, and opens a draft pull request unless it already has one.
# Claude is never allowed to push; the workflow is, and only past the ship gate.
set -euo pipefail

run_id=${1:?missing run_id}
state=".specify/state/${run_id}"

feature_dir=$(jq -re '.feature_directory' .specify/feature.json)
title=$(sed -n '/^# /{s/^# [^:]*:[[:space:]]*//p;q}' "${feature_dir}/spec.md")
base=$(gh repo view --json defaultBranchRef -q .defaultBranchRef.name)

# Through files: agent output is never interpolated into a command line. The
# body is the repository's template, filled by the step before; without one,
# the commits this branch adds, one topic each already.
body="${state}/pr-body.md"
if [ -z "$(bash "$(dirname "$0")/pr-template.sh")" ] || [ ! -s "$body" ]; then
  git log --reverse --format='- %s' "origin/${base}..HEAD" > "$body"
fi

# What the review said goes to a pull request shipped again, as a comment.
comment="${state}/pr-comment.md"
if [ -f "${state}/review.json" ]; then
  { printf 'Review: %s\n\n' "$(jq -r '.status' "${state}/review.json")"
    jq -r '.bullets[]? // empty | "- " + .' "${state}/review.json"; } > "$comment"
else
  echo "- No review verdict was recorded for this branch." > "$comment"
fi

git push -u origin HEAD
# A rewound run ships the same branch twice: the second time the push is the
# whole delivery, and gh refuses to open a pull request that stands already.
open=$(gh pr list --head "$(git branch --show-current)" --state open --json url -q '.[].url')
if [ -n "$open" ]; then
  echo "pushed to the open pull request: $open"
  gh pr comment --body-file "$comment"
else
  gh pr create --draft --base "$base" --title "$title" --body-file "$body"
fi
