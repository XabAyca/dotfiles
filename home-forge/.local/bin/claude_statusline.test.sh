#!/usr/bin/env bash
# Feeds claude_statusline a fixed session JSON and checks what it renders.
set -euo pipefail
script="$(dirname "$0")/claude_statusline"
fail() { printf 'FAIL: %s\n%s\n' "$1" "$out" >&2; exit 1; }
run() { printf '%s' "$1" | HOME=/nonexistent/home TZ=UTC "$script"; }

out=$(run '{"workspace":{"current_dir":"/nonexistent/home/proj"},"model":{"display_name":"Opus"},
  "effort":{"level":"medium"},"context_window":{"used_percentage":65.7},
  "rate_limits":{"five_hour":{"used_percentage":91.2,"resets_at":0},"seven_day":{"used_percentage":40.5}}}')
[[ $out == *$'\e[1m\e[38;5;108m~\e[0m\e[38;5;109m/\e[1m\e[38;5;108mproj\e[0m'* ]] || fail "home not shown as ~ with bold aqua anchors"
[[ $out == *'(medium)'* ]] || fail "effort missing"
[[ $out == *$'Ctx \e[38;5;214m▓▓▓▓▓▓\e[2m░░░░\e[0m \e[38;5;214m65%'* ]] || fail "ctx not a yellow 65% bar"
[[ $out == *$'Use \e[38;5;167m▓▓▓▓▓▓▓▓▓\e[2m░\e[0m \e[38;5;167m91%'* ]] || fail "quota not a red 91% bar"
[[ $out == *'00:00'* ]] || fail "reset time missing"
[[ $out == *$'7d\e[0m \e[38;5;142m40%'* ]] || fail "7d quota not green 40%"

out=$(run '{"workspace":{"current_dir":"/nonexistent/home/proj"},
  "model":{"display_name":"Opus"},"pr":{"number":42,"review_state":"changes_requested"}}')
[[ $out == *$'\e[38;5;167m#42'* ]] || fail "PR with changes requested not red"

out=$(run '{"workspace":{"current_dir":"/nonexistent/home/proj"},"model":{"display_name":"Opus"}}')
[[ $out != *Ctx* && $out != *Use* && $out != *'('* && $out != *7d* && $out != *'#'* && $out != *' on '* ]] ||
  fail "empty fields still rendered"

repo=$(mktemp -d)
trap 'rm -rf "$repo"' EXIT
git -C "$repo" init -q -b main && mkdir "$repo/sub" && touch "$repo/a" "$repo/b" "$repo/c"
git -C "$repo" add a b && git -C "$repo" -c user.name=t -c user.email=t@t commit -qm init
echo x > "$repo/a" && echo x > "$repo/b" && git -C "$repo" add b && echo y > "$repo/b"
out=$(run '{"workspace":{"current_dir":"'"$repo/sub"'"},"model":{"display_name":"Opus"}}')
[[ $out == *$'\e[1m\e[38;5;108m'"${repo##*/}"$'\e[0m'* ]] || fail "repo root not an anchor"
[[ $out == *$' on \e[38;5;142m main'* ]] || fail "branch missing"
[[ $out == *$'\e[38;5;214m+1 \e[38;5;214m!2 \e[38;5;108m?1'* ]] || fail "staged/unstaged/untracked counts wrong"

git -C "$repo" checkout -q --detach
out=$(run '{"workspace":{"current_dir":"'"$repo"'"},"model":{"display_name":"Opus"}}')
[[ $out == *$'\e[0m@\e[38;5;142m'"$(git -C "$repo" rev-parse --short=8 HEAD)"* ]] || fail "detached head not shown as @sha"
echo ok
