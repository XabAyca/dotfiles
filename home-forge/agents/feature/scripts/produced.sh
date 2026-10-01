#!/usr/bin/env bash
# Fails the run when a Spec Kit step exited 0 without writing its document: a
# headless agent that stops to ask still exits 0, and every step after it
# would then work on nothing.
set -euo pipefail

doc=${1:?missing document: spec|plan|tasks}

feature_dir=$(jq -re '.feature_directory' .specify/feature.json 2>/dev/null) || {
  echo "no feature: .specify/feature.json is missing or names no directory" >&2
  exit 1; }
[ -s "${feature_dir}/${doc}.md" ] || { echo "no ${doc}.md in ${feature_dir}" >&2; exit 1; }
