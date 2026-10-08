#!/usr/bin/env bash
# Feeds claude_statusline a fixed session JSON and checks what it renders.
set -euo pipefail
script="$(dirname "$0")/claude_statusline"
fail() { printf 'FAIL: %s\n%s\n' "$1" "$out" >&2; exit 1; }
run() { printf '%s' "$1" | TZ=UTC "$script"; }

out=$(run '{"workspace":{"current_dir":"/nonexistent/home/proj"},"model":{"display_name":"Opus"},
  "effort":{"level":"medium"},"context_window":{"used_percentage":65.7},
  "rate_limits":{"five_hour":{"used_percentage":91.2,"resets_at":0}}}')
[[ $out == *$'\e[1;36mproj\e[0m'* ]] || fail "dir not reduced to its name"
[[ $out == *'(medium)'* ]] || fail "effort missing"
[[ $out == *$'Ctx \e[33m▓▓▓▓▓▓\e[2m░░░░\e[0m \e[33m65%'* ]] || fail "ctx not a yellow 65% bar"
[[ $out == *$'Use \e[31m▓▓▓▓▓▓▓▓▓\e[2m░\e[0m \e[31m91%'* ]] || fail "quota not a red 91% bar"
[[ $out == *'00:00'* ]] || fail "reset time missing"

out=$(run '{"workspace":{"current_dir":"/nonexistent/home/proj"},"model":{"display_name":"Opus"}}')
[[ $out != *Ctx* && $out != *Use* && $out != *'('* ]] || fail "empty fields still rendered"
echo ok
