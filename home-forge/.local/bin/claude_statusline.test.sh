#!/usr/bin/env bash
# Feeds claude_statusline a fixed session JSON and checks what it renders.
set -euo pipefail
script="$(dirname "$0")/claude_statusline"
fail() { printf 'FAIL: %s\n%s\n' "$1" "$out" >&2; exit 1; }
run() { printf '%s' "$1" | HOME=/nonexistent/home TZ=UTC "$script"; }

out=$(run '{"workspace":{"current_dir":"/nonexistent/home/proj"},"model":{"display_name":"Opus"},
  "context_window":{"used_percentage":65.7},
  "rate_limits":{"five_hour":{"used_percentage":91.2,"resets_at":0}}}')
[[ $out == *'~/proj'* ]] || fail "home not shortened"
[[ $out == *$'ctx \e[33m65%'* ]] || fail "ctx not yellow 65%"
[[ $out == *$'5h \e[31m91%'* ]] || fail "quota not red 91%"
[[ $out == *'↻ 00:00'* ]] || fail "reset time missing"

out=$(run '{"workspace":{"current_dir":"/nonexistent/home/proj"},"model":{"display_name":"Opus"}}')
[[ $out != *ctx* && $out != *5h* ]] || fail "empty fields still rendered"
echo ok
