#!/usr/bin/env bash
# Decides whether the branch may be committed and shipped: either the review
# converged on its own, or a human overrode a review that did not.
set -euo pipefail

run_id=${1:?missing run_id}
override=${2:-}

status=$(jq -re '.status' ".specify/state/${run_id}/review.json")

if [ "$status" = DONE ] || [ "$override" = approve ]; then
  printf %s SHIP
else
  printf %s HOLD
fi
