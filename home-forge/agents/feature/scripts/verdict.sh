#!/usr/bin/env bash
# Merges the reviewers' verdicts and decides what the loop does next.
# Exits non-zero when a verdict is missing or invalid, so the run stops
# rather than carrying on with an assumption.
set -euo pipefail

run_id=${1:?missing run_id}
max=${2:?missing maximum attempts}

state=".specify/state/${run_id}"

# review.json is written on every pass. ui.json only exists once a UI review
# has run, so a missing one is silence, not failure.
read_status() {
  local file="${state}/$1.json" required=$2 status
  if [ ! -f "$file" ]; then
    [ "$required" = optional ] && { printf %s DONE; return 0; }
    echo "verdict missing: $file" >&2
    return 1
  fi
  status=$(jq -re '.status' "$file") || { echo "unreadable verdict: $file" >&2; return 1; }
  case "$status" in
    DONE|NEEDS_FIX|NEEDS_HUMAN|BLOCKED) printf %s "$status" ;;
    *) echo "unknown status in $file: $status" >&2; return 1 ;;
  esac
}

review=$(read_status review required)
ui=$(read_status ui optional)

attempts=$(( $(cat "${state}/attempts" 2>/dev/null || echo 0) + 1 ))
mkdir -p "$state"
echo "$attempts" > "${state}/attempts"

# The worst of the two decides: an interface finding is as blocking as a
# correctness one, or the loop would learn to ignore it.
case "${review}/${ui}" in
  *NEEDS_HUMAN*|*BLOCKED*) verdict=ESCALATE ;;
  *NEEDS_FIX*)
    if [ "$attempts" -lt "$max" ]; then verdict=RETRY; else verdict=ESCALATE; fi ;;
  DONE/DONE) verdict=DONE ;;
  *) echo "unexpected combination: ${review}/${ui}" >&2; exit 1 ;;
esac

# printf without a newline: the engine compares raw stdout, and "RETRY\n"
# does not equal "RETRY".
printf %s "$verdict"
