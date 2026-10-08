#!/usr/bin/env bash
# Feeds claude_statusline a fixed session JSON and checks what it renders.
set -euo pipefail
script="$(dirname "$0")/claude_statusline"
fail() { printf 'FAIL: %s\n%s\n' "$1" "$out" >&2; exit 1; }
run() { printf '%s' "$1" | TZ=UTC "$script"; }

out=$(run '{"workspace":{"current_dir":"/nonexistent/home/proj"},"model":{"display_name":"Opus"},
  "effort":{"level":"medium"},"context_window":{"used_percentage":65.7},
  "rate_limits":{"five_hour":{"used_percentage":91.2,"resets_at":0},"seven_day":{"used_percentage":40.5}}}')
[[ $out == *$'\e[1;36mproj\e[0m'* ]] || fail "dir not reduced to its name"
[[ $out == *'(medium)'* ]] || fail "effort missing"
[[ $out == *$'Ctx \e[33m▓▓▓▓▓▓\e[2m░░░░\e[0m \e[33m65%'* ]] || fail "ctx not a yellow 65% bar"
[[ $out == *$'Use \e[31m▓▓▓▓▓▓▓▓▓\e[2m░\e[0m \e[31m91%'* ]] || fail "quota not a red 91% bar"
[[ $out == *'00:00'* ]] || fail "reset time missing"
[[ $out == *$'7d\e[0m \e[32m40%'* ]] || fail "7d quota not green 40%"

out=$(run '{"workspace":{"current_dir":"/nonexistent/home/proj"},
  "model":{"display_name":"Opus"},"pr":{"number":42,"review_state":"changes_requested"}}')
[[ $out == *$'\e[31m#42'* ]] || fail "PR with changes requested not red"

out=$(run '{"workspace":{"current_dir":"/nonexistent/home/proj"},"model":{"display_name":"Opus"}}')
[[ $out != *Ctx* && $out != *Use* && $out != *'('* && $out != *7d* && $out != *'#'* ]] || fail "empty fields still rendered"

repo=$(mktemp -d)
trap 'rm -rf "$repo"' EXIT
git -C "$repo" init -q -b main && touch "$repo/a" "$repo/b"
git -C "$repo" remote add origin git@github-alias:me/dotfiles.git
out=$(run '{"workspace":{"current_dir":"'"$repo"'","git_worktree":"feat"},"model":{"display_name":"Opus"}}')
[[ $out == *$'\e[1;36mdotfiles/feat\e[0m'* ]] || fail "origin repo name/worktree not shown"
[[ $out == *$'\e[33m*2'* ]] || fail "dirty count missing"
echo ok
