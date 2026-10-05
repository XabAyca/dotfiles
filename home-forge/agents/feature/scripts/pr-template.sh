#!/usr/bin/env bash
# Prints the pull request template the repository keeps, or nothing. GitHub
# looks in .github, the root and docs, in any case. Of a directory of several
# templates the first is taken: which one fits is not written anywhere.
set -euo pipefail

found=$( { find .github . docs -maxdepth 1 -iname pull_request_template.md
           find .github . docs -maxdepth 2 -ipath '*/pull_request_template/*.md' | sort
         } 2>/dev/null | head -1 || true)
printf %s "${found#./}"
