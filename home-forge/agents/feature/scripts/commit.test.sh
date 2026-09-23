#!/usr/bin/env bash
# Runs commit.sh in a throwaway repository: a clean tree, a good split, and
# splits that must be refused before anything is committed. No network.
set -euo pipefail

HERE=$(cd "$(dirname "$(readlink -f "$0")")" && pwd)
T=$(mktemp -d)
trap 'rm -rf "$T"' EXIT

cd "$T"
git init -q
git config user.name test
git config user.email test@example.com
mkdir -p docs db app spec .specify/state/r1
echo old > app/old.rb
echo readme > README.md
git add -A
git commit -q -m init

fail=0
check() {
  local text=$1; shift
  "$@" || { echo "FAIL: $text" >&2; fail=1; }
  return 0
}

check "clean tree is skipped" [ "$(bash "$HERE/commit.sh" r1 list)" = SKIPPED ]

echo guide > docs/guide.md
echo migration > db/001_add.rb
echo feature > app/new.rb
echo test > spec/new_spec.rb
mv app/old.rb app/renamed.rb
echo footprint > .specify/state/r1/log

check "changes are listed" [ "$(bash "$HERE/commit.sh" r1 list)" = CHANGES ]
check "rename lists both paths" grep -qx app/old.rb .specify/state/r1/changes.txt
check "runner footprint is not listed" bash -c '! grep -q "^.specify" .specify/state/r1/changes.txt'

refused() {
  echo "$2" > .specify/state/r1/commits.json
  local head
  head=$(git rev-parse HEAD)
  check "$1 is refused" bash -c "! bash '$HERE/commit.sh' r1 apply 2>/dev/null"
  check "$1 commits nothing" [ "$(git rev-parse HEAD)" = "$head" ]
}
all='"docs/guide.md","db/001_add.rb","app/new.rb","spec/new_spec.rb","app/old.rb","app/renamed.rb"'
refused "a path left out" '[{"subject":":sparkles: add","paths":["app/new.rb"]}]'
refused "a path twice" "[{\"subject\":\":sparkles: add\",\"paths\":[$all,\"app/new.rb\"]}]"
refused "an unknown path" "[{\"subject\":\":sparkles: add\",\"paths\":[$all,\"nope.rb\"]}]"
refused "a subject without gitmoji" "[{\"subject\":\"add\",\"paths\":[$all]}]"
refused "a two-line subject" "[{\"subject\":\":sparkles: add\\nbody\",\"paths\":[$all]}]"
refused "a commit without paths" "[{\"subject\":\":memo: x\",\"paths\":[]},{\"subject\":\":sparkles: add\",\"paths\":[$all]}]"

cat > .specify/state/r1/commits.json <<'JSON'
[
  {"subject": ":memo: document the thing", "paths": ["docs/guide.md"]},
  {"subject": ":card_file_box: add the table", "paths": ["db/001_add.rb"]},
  {"subject": ":truck: rename old to renamed", "paths": ["app/old.rb", "app/renamed.rb"]},
  {"subject": "✨ add the thing", "paths": ["app/new.rb", "spec/new_spec.rb"]}
]
JSON
check "a good split is committed" [ "$(bash "$HERE/commit.sh" r1 apply)" = COMMITTED ]
check "one commit per topic, in order" [ "$(git log --format=%s -4 | tr '\n' '|')" = \
  "✨ add the thing|:truck: rename old to renamed|:card_file_box: add the table|:memo: document the thing|" ]
check "the feature carries its test" [ "$(git show --format= --name-only HEAD | sort | tr '\n' ' ')" = "app/new.rb spec/new_spec.rb " ]
check "runner footprint stays out" [ -z "$(git log --format= --name-only | grep '^.specify' || true)" ]

head=$(git rev-parse HEAD)
check "a replay is skipped" [ "$(bash "$HERE/commit.sh" r1 apply)" = SKIPPED ]
check "a replay leaves HEAD alone" [ "$(git rev-parse HEAD)" = "$head" ]

[ "$fail" = 0 ] && echo "ok"
exit "$fail"
