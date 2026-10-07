#!/usr/bin/env bash
# Runs produced.sh on a throwaway feature, one document at a time. No model.
set -euo pipefail

HERE=$(cd "$(dirname "$(readlink -f "$0")")" && pwd)
T=$(mktemp -d)
trap 'rm -rf "$T"' EXIT

cd "$T"
fail=0
passes() { bash "$HERE/produced.sh" "$1" 2>/dev/null || { echo "FAIL: $2" >&2; fail=1; }; }
fails() { bash "$HERE/produced.sh" "$1" 2>/dev/null && { echo "FAIL: $2" >&2; fail=1; }; return 0; }

fails spec "no feature.json was not an error"

mkdir -p .specify specs/001
echo '{"feature_directory": "specs/001"}' > .specify/feature.json
fails spec "a feature with no spec.md was not an error"

: > specs/001/spec.md
fails spec "an empty spec.md was not an error"

echo '# Spec' > specs/001/spec.md
passes spec "a written spec.md was refused"
fails plan "spec.md alone passed for plan"

mkdir -p .specify/templates
echo '# Plan: [FEATURE]' > .specify/templates/plan-template.md
cp .specify/templates/plan-template.md specs/001/plan.md
fails plan "a plan.md still the template passed"

echo '# Plan' > specs/001/plan.md
passes plan "a written plan.md was refused"

[ "$fail" = 0 ] && echo "ok"
exit "$fail"
