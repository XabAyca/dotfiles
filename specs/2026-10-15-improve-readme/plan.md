# Plan: a simpler README that shows the whole procedure

Interface: no

[ASSUMPTION: the README is documentation, not a screen, a form or a terminal UI.
The repository has no interface for `design-ui` or `review-ui` to measure it
against; the layout is checked by the acceptance scenarios below instead.]

**Spec**: `specs/2026-10-15-improve-readme/spec.md`
**Branch**: `2026-10-15-improve-readme`

## Summary

One file changes: `README.md` at the repository root, rewritten in place. No
dotfile, script, workflow, unit or skill is touched, and no data changes: the
repository has no data model, and the README is read by nothing but people and
agents. Diagrams are Mermaid code blocks, risky steps get a GitHub
`> [!WARNING]` alert, details sit in `<details><summary>` blocks. All three read
as plain text where GitHub's rendering is missing.

## Facts the plan rests on

Read from the repository on 2026-10-15, not assumed:

- `home` → macOS laptop, tools from Homebrew and `Brewfile`. `home-forge` →
  Ubuntu server, tools from apt (README step 1) and mise
  (`home-forge/.config/mise/config.toml`: claude, gh, neovim 0.12, node 22,
  tree-sitter, uv, rust).
- `home/bin/forge` runs on the laptop: `ssh forge`, lists the worktrees under
  `~/projects/*/*` and their tmux sessions in fzf, then
  `tmux new-session -A -s <project>/<worktree>`.
- `agent` (`home-forge/.local/bin/agent`) runs the feature workflow in a
  detached tmux session on its own worktree. Subcommands: `start`, `answer`,
  `resume`, `retry`, `stop`, `list`, `menu`, `preview`, `done`; no argument
  prints the usage. `start` refuses a project whose
  `~/projects/<project>/main` has no `.specify/`, then calls
  `gh repo view` and `git fetch origin` (so `gh` must be logged in before the
  first start, not only for the pull request), `jq`, and Spec Kit's `specify`
  CLI. Neither `jq` nor `specify` is installed by today's README.
- `home-forge/agents/feature/workflow.yml`, phases in order: specify (+ clarify),
  plan (+ design-ui), tasks, analyze → **decision gate** (`approve`, `reject`,
  or free text; skipped when `decision.sh` finds nothing to decide; `reject`
  ends the run) → implement → converge loop → review loop (`review-feature` and
  `review-ui`, then a fix) → commit split → **ship gate** (`push` or `reject`;
  skipped when the summary is "Prêt à livrer"; `reject` leaves the commits on
  the branch, on the machine) → draft pull request. Both gates say to answer
  with `agent menu`.
- `home-forge/agents/gateway/gateway`: `scan` notifies once per pause, failure
  or end; `reply` answers a gate (`agent menu` calls it); `say` sends a free
  message. Channels: `file`, which appends to
  `~/.local/state/agent-gateway/inbox.md` with no network and no account, and
  `slack`. `config.env.example` defaults to `file`.
- The gateway reads `config.env` next to **the resolved script**
  (`readlink -f "$0"`). Stow links files one by one (`--no-folding`), so
  `~/agents/gateway/` is a real directory: a `config.env` copied there is never
  read. The file must be
  `~/projects/dotfiles/main/home-forge/agents/gateway/config.env`, which
  `.gitignore` already ignores.
- `agent-gateway.timer` fires every 60 s; `agent-retro.timer` on Mondays at
  08:00 and announces the retro through `gateway say`. Both services run with
  `WorkingDirectory=%h/projects/dotfiles/main`, and `retro` defaults
  `AGENT_DOTFILES` to that path.
- `record` keeps the lasting record of each run (`run`, `scan`, `log`, `show`);
  `retro [--if-new] [n]` reads those records and proposes workflow changes, and
  only proposes.
- Skills shipped: `design-ui`, `review-feature`, `review-ui` under
  `home-forge/.claude/skills/`, called by the workflow's plan and review steps.
- Tests: every `*.test.sh` under `home-forge`, the agent ones included
  (`agent.test.sh`, `record.test.sh`, `retro.test.sh`, `gateway.test.sh`,
  `slack.test.sh`, `agents/feature/scripts/*.test.sh`).

## Decisions

- [ASSUMPTION: each step is a heading (`### 3. Clone the repository`), not a
  numbered list item. GitHub does not render an alert nested in a list item,
  and the headings make each machine's procedure visible in the outline (R6).
  The list indentation today's README uses for its code blocks goes away with
  it.]
- [ASSUMPTION: a step whose action is not a shell command — install Homebrew
  from its site, import the iTerm2 profile, install the font on the client —
  shows that action as its one line in place of the command block. The
  Homebrew and mise installers stay links, as today: their official form is a
  `curl | sh` the README should not freeze a copy of.]
- [ASSUMPTION: the server clone and every server stow command use
  `~/projects/dotfiles/main` and `-t ~` in the command block itself, so that
  scenario 2 holds for someone who reads no details. The `~/.dotfiles` clone
  moves to step 3's details, and the "add `-t ~` when the repository is not
  directly under `$HOME`" note to step 4's details, the first stow step (spec
  edge case "Repository cloned somewhere else"), as the shell-only alternative
  (spec Decisions). The macOS procedure keeps `~/.dotfiles` unchanged.]
- [ASSUMPTION: today's server step 3 splits into three steps — clone, dry run,
  link — so the warning sits right before the only block that removes files.]
- [ASSUMPTION: the link step's block gains a backup before the removal:
  `cp -n ~/.zshrc ~/.zshrc.bak 2>/dev/null; cp -n ~/.gitconfig ~/.gitconfig.bak 2>/dev/null`.
  The spec asks for a rollback next to the command, and `rm -f` has none
  without a copy; `cp -n` keeps the first backup on a second run, when the
  files are already links.] Its check: `ls -l ~/.zshrc ~/.gitconfig` shows links
  into the repository. Its rollback: `stow -D --no-folding -t ~ home-forge`,
  then move the `.bak` files back.
- [ASSUMPTION: the `chsh` warning keeps today's check (a **new** SSH connection
  reaches the prompt before the others close) and rollback
  (`chsh -s /bin/bash` from a live session), moved right under the block and
  outside any `<details>`.]
- [ASSUMPTION: Mermaid `flowchart` only, labels of one to three words, so the
  source reads as text in `less` (scenario 8). Four diagrams: overview (R1),
  macOS steps, server steps (R3), life of a run (R4). The agent setup is three
  steps and gets no diagram of its own.]
- [ASSUMPTION: the life-of-a-run diagram draws both gates as dashed decision
  nodes, each with a "nothing to decide" / "ready to ship" edge that goes
  straight on, so a run that never stops does not look broken (edge case).]
- [ASSUMPTION: the agent tooling is a `### Agent tooling` section closing
  `## Ubuntu server`, with `####` subsections; `## Tests` and `## Optional`
  become top-level sections after it, so the server procedure visibly ends
  before them. Both were `###` under the server today; their content is
  unchanged apart from R5's sentence.]
- [ASSUMPTION: the agent prerequisites are stated in one visible list before
  its setup: `jq` (`sudo apt install -y jq`), Spec Kit's `specify` CLI (link
  only, Spec Kit itself is out of scope), `gh auth login` (needed by
  `agent start` itself, and for the pull request), and a project cloned as
  `~/projects/<project>/main` with an `origin` remote and `.specify/`. `jq` is
  not added to the shell setup's apt block: the shell does not need it.]
- [ASSUMPTION: the config step copies with `cp -n`, so running the procedure a
  second time never overwrites a configured `config.env`.]
- [ASSUMPTION: the check after the timers is `systemctl --user list-timers
  'agent-*'`, which must list both, then `~/agents/gateway/gateway say test` and
  a look at the inbox for the `file` channel. No caveat on user lingering: the
  spec does not ask for it and it was not verified on the machine.]
- [ASSUMPTION: the everyday table lists `agent start`, `agent list`,
  `agent menu`, `agent stop`, `agent done`, `forge` (on the laptop),
  `record log`, `retro`, and `bat ~/.local/state/agent-gateway/inbox.md`.
  `answer`, `resume`, `retry` and `preview` are named in one sentence pointing
  to `agent` without arguments.]
- [ASSUMPTION: the freeze rule names what is frozen as `home-forge/agents/`
  (the workflow and its scripts) and `home-forge/.claude/skills/`, and says
  editing the README stays safe.]
- [ASSUMPTION: nothing in the README is run during implementation or review:
  `sudo`, `apt`, `stow`, `chsh` and `systemctl` would change this machine, and
  the constitution forbids `chsh` to an agent. Scenarios 2, 3 and 7 are checked
  by walking the blocks against the facts above.]

## Target structure of `README.md`

```
# :floppy_disk: dotfiles
  sentence + overview diagram, package table, what stow does    R1
## What installs itself                                         R2
  table: piece | installed by | when
## macOS laptop                                                 R3, R6
  sentence + steps diagram
  ### 1. Install Homebrew     ### 2. Clone the repository
  ### 3. Install the tools    ### 4. Check the links (dry run)
  ### 5. Link the dotfiles    ### 6. Install the runtimes
  ### 7. Import the iTerm2 profile   ### 8. Apply the macOS settings
## Ubuntu server                                                R3, R6
  intro (Ubuntu 26.04, mise prerequisite) + sentence + steps diagram
  ### 1. Install the packages
  ### 2. Install the font — on the machine you connect from
  ### 3. Clone the repository
  ### 4. Check the links (dry run)
  ### 5. Link the dotfiles                    [!WARNING]
  ### 6. Point AGENTS.md at the constitution
  ### 7. Install the runtimes
  ### 8. Test in a child zsh
  ### 9. Make zsh the login shell             [!WARNING]
  ### Agent tooling                                             R4
    #### What each part is for      (one line each)
    #### Life of a run              sentence + diagram
    #### Before a first run         prerequisites
    #### Set it up                  1. config  2. timers  3. check
    #### Every day                  command | purpose table
    #### Do not change it during a run   freeze rule + agent list
## Tests                                                        R5
## Optional
```

Each step: one-line goal, command block, then a `<details><summary>` with the
why, the caveats and the alternatives — except the two warned steps, whose
check and rollback stay visible under the block (R3, scenario 5). A blank line
follows each `<summary>` line so the Markdown inside the details renders.

## Content mapping (today's README → new)

Every command and caveat of `git show master:README.md` lands in one place
(scenario 4):

| Today (lines) | New place |
|---|---|
| package table (3-8) | under the overview diagram |
| self-installing pieces (10-15) | What installs itself: p10k (server) and fzf-tab → cloned into `~/.local/share` by `.zshrc` on the first shell; TPM and plugins → `.tmux.conf` on the first tmux start; lazy.nvim → first `nvim`; treesitter parsers → first `nvim`, needs the `tree-sitter` CLI and a C compiler |
| macOS 1 Homebrew (19) | macOS 1, link unchanged |
| macOS 2 clone (20-25) | macOS 2, block unchanged |
| macOS 3 `brew bundle` (27) | macOS 3, now a block |
| macOS 4 stow + "existing files block stow" (28-33) | macOS 4 dry run, macOS 5 link; the caveat in 5's details |
| macOS 5 runtimes (35-42) | macOS 6, block unchanged, `<version>` kept |
| macOS 6 iTerm2 (44) | macOS 7 |
| macOS 7 settings (45) | macOS 8, now a block |
| server intro + Ubuntu 26.04 + mise prerequisite (49-53) | Ubuntu server intro |
| apt block + "often already installed" (55-62) | server 1, block unchanged; the note in details |
| font + glyphs drawn by the client + Nerd Fonts v3 (64-68) | server 2, "on the machine you connect **from**" in the heading; caveats in details |
| clone + stow + `rm -f` (70-78) | server 3, 4, 5 per Decisions; `rm -f` and stow kept in 5; the old `~/.dotfiles` clone lines in 3's details, the old stow lines without `-t ~` in 4's details |
| "a `~/.zshrc` or `~/.gitconfig` already in place would block stow" (70) | server 4 and 5, visible above the block in 5 |
| `-t ~` note (80) | server 4 details |
| fd / bat / emojify (82-83) | server 5 details |
| CLAUDE.md / AGENTS.md (85-91) | server 6, `ln -sfn` unchanged; why in details |
| `mise install` (93) | server 7 |
| test in `zsh -l` (95-100) | server 8: "two SSH sessions" and "never `source ~/.zshrc`" one visible line above the block, the check list in details |
| `chsh` + reliable several sessions in a row + check + rollback (102-109) | server 9, all visible |
| Tests (111-117) | Tests, command byte-identical, plus "covers the agent scripts too" |
| Optional (119-122) | Optional, unchanged |

## Agent tooling, content

- **What each part is for**: `agent` starts and drives runs; the feature
  workflow is what a run executes; the gateway says when a run waits, fails or
  ends; `record` keeps what each run cost and decided; `retro` reads the
  records every Monday and proposes workflow changes; the Claude skills are
  the UI design and review steps the workflow calls; `forge`, on the laptop,
  attaches to a run's tmux session.
- **Life of a run**, sentence first, then: `agent start` → specify → plan →
  tasks → ⟨decision gate⟩ → implement → converge → review → commit →
  ⟨ship gate⟩ → draft PR. Each gate → "gateway notifies" → "`agent menu`" →
  back into the run; decision `reject` → "run stops"; ship `reject` →
  "branch stays on the machine".
- **Set it up**:
  1. `cd ~/projects/dotfiles/main/home-forge/agents/gateway && cp -n config.env.example config.env`,
     then edit it. Details: `file` needs no account and writes to the inbox;
     `slack` needs the two values the example names; why the file lives in the
     repository and why git ignores it. No real token or conversation id.
  2. `systemctl --user daemon-reload` then
     `systemctl --user enable --now agent-gateway.timer agent-retro.timer`.
  3. Check, named as such: `systemctl --user list-timers 'agent-*'` lists both,
     then `~/agents/gateway/gateway say test` and
     `tail ~/.local/state/agent-gateway/inbox.md`.
- **Do not change it during a run**: no change to the workflow, its scripts or
  the skills while `agent list` shows a run running or paused.

## Tests

The feature adds no logic, so no test file (constitution: config and
one-line edits are not logic; prose even less). Each scenario is proven by a
check run during implementation and again by `review-feature`:

| Scenario | Check |
|---|---|
| 1 | In `README.md`, the first block after the title's sentence is ` ```mermaid `, before any `## ` heading. |
| 2 | Extract the fenced blocks of `## Ubuntu server` outside `<details>`, in order: clone into `~/projects/dotfiles/main`, `-t ~` on every `stow`, `mise install` before `zsh -l`, `chsh` last. Walked, not run; mise itself is the intro's prerequisite link, installed before step 1. |
| 3 | Same for `## macOS laptop`: clone, `brew bundle`, `stow --no-folding home`, runtimes, iTerm2 import line, `source install-macos-settings.sh`. |
| 4 | Every fenced block line and every caveat of `git show master:README.md` found in the new file with `grep -F`, per the mapping table; the old server clone lines found in step 3's details, the old stow lines and the `-t ~` note in step 4's details. |
| 5 | `grep -n -B8 -A8` on `rm -f ~/.zshrc` and `chsh -s`: `[!WARNING]` before each, check and rollback after, no `<details>` in between. |
| 6 | The run diagram holds both gates, the gateway node and `agent menu`, and the sentence before it says the same. |
| 7 | The setup blocks use the resolved `config.env` path, unit names match `home-forge/.config/systemd/user/`, and `systemctl --user list-timers` is named as the check. |
| 8 | Read in `less`: each ` ```mermaid ` block has a sentence next to it, every `<details>` follows its step's command. |
| 9 | The overview names the package per machine and says dotfiles are edited in the repository; the freeze rule names `agent list`. |
| R5 | The test command is byte-identical to today's and runs green: `find home-forge -name '*.test.sh' \| while read -r t; do echo "== $t"; bash "$t" \|\| break; done`. |
| Secrets | `grep -nE 'xox[bp]-[0-9A-Za-z]\|D0[0-9A-Z]{8}' README.md` finds nothing. |

## Order of work

1. Write the heading skeleton above in `README.md`. Check: `grep -n '^#' README.md`
   matches the target structure.
2. Move today's content in per the mapping table, command first, details after.
   Check: scenario 4.
3. Split server step 3, add the backup line, the two warnings with their checks
   and rollbacks. Check: scenarios 2 and 5.
4. Write the overview diagram, its sentence, the stow paragraph and the "What
   installs itself" table. Check: scenarios 1 and 9 (first half).
5. Add the macOS and server step diagrams with their sentences. Check: scenarios
   3 and 8.
6. Write the agent tooling section. Check: scenarios 6, 7, 9; every subcommand,
   unit and path against the facts above.
7. Update Tests and move Tests and Optional to `##`. Check: R5 runs green.
8. Read the whole file in `less`, then the secrets grep. Check: scenario 8,
   secrets.

The workflow's commit step splits the commits; this feature expects one:
`:memo: rewrite the readme around diagrams and the agent workflow`, with the
Spec Kit documents apart.

## Deviations

- **"Show the diff and wait for approval before changing an existing file."**
  The run is headless and nobody approves mid-run. The decision gate shows this
  plan before the README is touched; the diff is read at the ship gate and in
  the draft pull request.
- **"A test worth writing to check the work is worth keeping."** The checks
  above are not kept as a test file. The one that matters most, scenario 4,
  compares the new README to `master:README.md`; once merged, master is the new
  README and the check compares the file with itself. The others assert prose
  wording, which a test would freeze against every later edit of the README.
