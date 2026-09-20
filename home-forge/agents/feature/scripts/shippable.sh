#!/usr/bin/env bash
# Decides whether the branch may be shipped, and records why: the ship gate
# shows that record rather than asserting a verification it has not made.
set -euo pipefail

run_id=${1:?missing run_id}
override=${2:-}

state=".specify/state/${run_id}"

status_of() {
  local file="${state}/$1.json"
  [ -f "$file" ] || { printf %s ABSENT; return 0; }
  jq -re '.status' "$file"
}

review=$(status_of review)
ui=$(status_of ui)

# A missing review.json means the review never reached a verdict, which is
# silence, not permission. A missing ui.json is normal, as in verdict.sh.
passed=false
if [ "$review" = DONE ] && { [ "$ui" = DONE ] || [ "$ui" = ABSENT ]; }; then
  passed=true
fi

# Two independent reasons, tested separately: one `|| ... &&` chain would let
# the second condition silently veto the first.
if [ "$passed" = true ]; then
  verdict=SHIP
elif [ "$override" = approve ]; then
  verdict=SHIP
else
  verdict=HOLD
fi

{
  echo "# Ship decision — run ${run_id}"
  echo
  echo "| check | verdict |"
  echo "|---|---|"
  echo "| feature review | ${review} |"
  echo "| interface review | ${ui} |"
  echo "| human override | ${override:-none} |"
  echo
  if [ "$verdict" = SHIP ] && [ "$passed" = false ]; then
    echo "**The reviews did not pass. This branch is shippable only because a"
    echo "human overrode them. Read the verdicts before pushing.**"
  fi
  for f in review ui; do
    [ -f "${state}/${f}.json" ] || continue
    echo
    echo "## ${f}"
    echo
    jq -r '.summary' "${state}/${f}.json"
    jq -r '.bullets[]? // empty | "- " + .' "${state}/${f}.json"
  done
} > "${state}/ship.md"

printf %s "$verdict"
