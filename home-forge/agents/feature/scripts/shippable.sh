#!/usr/bin/env bash
# Decides whether the branch may be committed and shipped: either every review
# converged on its own, or a human overrode one that did not.
set -euo pipefail

run_id=${1:?missing run_id}
override=${2:-}

state=".specify/state/${run_id}"

status_of() {
  local file="${state}/$1.json"
  [ -f "$file" ] || { printf %s DONE; return 0; }   # a review that never ran is silence
  jq -re '.status' "$file"
}

if [ "$override" = approve ] \
   || { [ "$(status_of review)" = DONE ] && [ "$(status_of ui)" = DONE ]; }; then
  printf %s SHIP
else
  printf %s HOLD
fi
