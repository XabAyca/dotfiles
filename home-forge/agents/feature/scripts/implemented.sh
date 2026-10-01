#!/usr/bin/env bash
# Fails the run while implement has tasks it gave up on: the reviews and the
# commit would otherwise carry it to the ship gate as if it were done. It reads
# tasks.md rather than converge's verdict, so a retry passes once a person has
# finished them.
set -euo pipefail

feature_dir=$(jq -re '.feature_directory' .specify/feature.json)
open=$(grep -E '^[[:space:]]*- \[ \]' "${feature_dir}/tasks.md" | grep -vF '[HUMAN]' || true)
[ -z "$open" ] || { printf 'implement left tasks open:\n%s\n' "$open" >&2; exit 1; }
