#!/usr/bin/env bash
# Pushes the branch and opens a draft pull request. Claude is never allowed
# to push; the workflow is, and only past the ship gate.
set -euo pipefail

run_id=${1:?missing run_id}
state=".specify/state/${run_id}"

feature_dir=$(jq -re '.feature_directory' .specify/feature.json)
title=$(sed -n '/^# /{s/^# [^:]*:[[:space:]]*//p;q}' "${feature_dir}/spec.md")
base=$(gh repo view --json defaultBranchRef -q .defaultBranchRef.name)

# Which workflow actually ran: the source, the worktree copy and the frozen
# copy drift apart, and only the frozen one is what this branch went through.
version=$(sed -n 's/^[[:space:]]*version:[[:space:]]*"\{0,1\}\([^"]*\)"\{0,1\}$/\1/p' \
          ".specify/workflows/runs/${run_id}/workflow.yml" | head -1)

# Through a file: agent output is never interpolated into a command line.
body="${state}/pr-body.md"
{
  if [ -f "${state}/review.json" ]; then
    # Says whether the bullets below summarise the change or list findings.
    printf 'Review: %s\n\n' "$(jq -r '.status' "${state}/review.json")"
    jq -r '.bullets[]? // empty | "- " + .' "${state}/review.json"
  else
    echo "- No review verdict was recorded for this branch."
  fi
  echo
  echo "Spec: \`${feature_dir}/\`"
  echo "Workflow: \`feature ${version:-?}\`, run \`${run_id}\`"
  echo
  echo "---"
  echo "🤖 Generated with [Claude Code](https://claude.com/claude-code)"
} > "$body"

git push -u origin HEAD
gh pr create --draft --base "$base" --title "$title" --body-file "$body"
