#!/usr/bin/env bash
# Pushes the branch and opens a draft pull request. Claude is never allowed
# to push; the workflow is, and only past the ship gate.
set -euo pipefail

run_id=${1:?missing run_id}
state=".specify/state/${run_id}"

feature_dir=$(jq -re '.feature_directory' .specify/feature.json)
title=$(sed -n 's/^# Feature Specification: //p' "${feature_dir}/spec.md" | head -1)
base=$(gh repo view --json defaultBranchRef -q .defaultBranchRef.name)

# Through a file: agent output is never interpolated into a command line.
body="${state}/pr-body.md"
{
  jq -r '.bullets[]? // empty | "- " + .' "${state}/review.json"
  echo
  echo "Spec: \`${feature_dir}/\`"
  echo
  echo "---"
  echo "🤖 Generated with [Claude Code](https://claude.com/claude-code)"
} > "$body"

git push -u origin HEAD
gh pr create --draft --base "$base" --title "$title" --body-file "$body"
