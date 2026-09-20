# The runner's own footprint in a worktree: never part of a feature commit,
# and never a reason to keep a finished worktree alive.
RUNNER_PATHS=(
  '.specify/workflows'
  '.specify/state'
  '.specify/.workflow-install.lock'
  '.specify/agents-*'
)

RUNNER_PATHSPEC=()
RUNNER_EXCLUDE=()
for _path in "${RUNNER_PATHS[@]}"; do
  RUNNER_PATHSPEC+=(":(glob)${_path}")
  RUNNER_EXCLUDE+=(":(exclude,glob)${_path}")
done
unset _path
