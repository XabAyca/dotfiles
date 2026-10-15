# Feature: a simpler README that shows the whole procedure

**Branch**: `2026-10-15-improve-readme`
**Created**: 2026-10-15
**Request**: "je veux que le read me soit plus simple et décrive mieux toute la procédure avec des graph ou autre"

## What and why

`README.md` is the only entry point to the repository. Today it is 122 lines of
numbered prose, and it is hard to follow for three reasons:

- **No overview.** Nothing shows how the parts fit together: two stow packages,
  two machines, where each one's tools come from, what installs itself on first
  launch, and how the laptop reaches the server. The reader has to piece that
  together from the steps.
- **Each step mixes its command with its explanation.** The command to type sits
  among caveats about Nerd Font versions, Debian binary names, the `AGENTS.md`
  link and the `chsh` rollback. Someone who only wants the procedure still has
  to read all of it.
- **Half of the server package is missing.** The README says nothing about the
  agent tooling `home-forge` ships: `agent`, the feature workflow, the gateway
  and its timer, `record`, `retro` and its weekly timer, the Claude skills, and
  `forge` on the laptop. Their procedure exists only in the scripts' usage text.

After this feature, a reader opening the README:

1. sees in one diagram what the repository holds and where each part goes;
2. follows each machine's setup as a short list of steps, each step starting
   with the command to run;
3. sees in a diagram how a feature moves through the agent workflow, and where
   a person has to step in;
4. can find the details of a step (why it exists, how to check it, how to undo
   it) without having to read them to finish the procedure.

[ASSUMPTION!: "toute la procédure" covers both the machine setup and the agent
workflow on the server. The workflow is the part the README leaves out
entirely, so a README that describes "the whole procedure" without it would
still be incomplete.]

## Users

- **The owner, setting up a new machine.** They copy commands in order and
  want a working shell without missing a step.
- **The owner, months later, coming back to the agent tooling.** They want to
  remember how a run goes, where it waits for them, and which command answers.
- **An agent working in this repository.** It reads the README to learn the
  layout before changing anything.

## Decisions

- [ASSUMPTION!: "graph ou autre" means diagrams drawn as text inside the
  README, in a format GitHub renders as a picture (Mermaid). They live in the
  same file, git diffs them as text, and keeping them current needs no image,
  no generated asset and no extra tool.]
- [ASSUMPTION!: the README stays in English, like the README, the commit
  history and the agent constitution today, even though the request is in
  French.]
- [ASSUMPTION!: the README stays a single file. "Plus simple" means less to
  read before reaching the command, not more files to open. Details stay under
  the step they belong to and are folded away by default where the viewer
  supports it.]
- [ASSUMPTION!: on the server, the clone path shown is
  `~/projects/dotfiles/main`, not `~/.dotfiles` as today. That is the path the
  agent tooling expects (`retro` reads it by default, the constitution says
  "edit it there"), and it is why every server stow command carries `-t ~`.
  The `~/.dotfiles` form is still mentioned as the alternative for a machine
  that only wants the shell setup. The macOS path stays `~/.dotfiles`.]
- [ASSUMPTION: the top-level structure stays one section per machine (macOS
  laptop, Ubuntu server), because a reader sets up one machine at a time. The
  agent tooling is part of the server section.]
- [ASSUMPTION: the README says what each part of the agent tooling is for and
  how to operate it. It does not copy the scripts' full usage text or every
  step of `workflow.yml`; it points to `agent` run without arguments for the
  complete list.]
- [ASSUMPTION: risky steps get a visible warning placed before their command,
  not just a note after it.]

## Required content

### R1: Overview

- At the top, before any install step, a diagram shows the two stow packages,
  the machine each targets, and where their tools come from: Homebrew and
  `Brewfile` for `home`, apt and mise for `home-forge`.
- The same diagram shows how the laptop reaches the server: SSH, and `forge`
  attaching to the server's tmux sessions.
- One short paragraph says what stow does here: it links each file of a package
  into `$HOME`, so changing a dotfile means changing it in the repository.

### R2: What installs itself

- The pieces that install themselves (Powerlevel10k, fzf-tab, TPM and its
  plugins, lazy.nvim, the treesitter parsers) are listed with what triggers
  each one, so the reader does not install them by hand. The treesitter line
  keeps its requirement: the `tree-sitter` CLI and a C compiler.

### R3: Setup procedure, per machine

- Each machine's procedure opens with a diagram of its steps in order, then the
  numbered steps.
- Each step starts with a one-line goal and the command block to copy. The
  explanations, caveats and alternatives that today's README mixes into the
  steps come after the command, as the step's details.
- Every command and every caveat in today's README is still in the new one,
  in a step or in its details. The rewrite reorganises; it loses nothing.
- On the server, the two risky steps carry a warning before their command:
  removing `~/.zshrc` and `~/.gitconfig` before stow, and `chsh`. Each one says
  how to check the result and how to roll back, next to the command, not
  folded away.
- A step that runs on another machine than the one being set up says so. The
  font step runs on the client the reader connects from.

### R4: Agent tooling on the server

- A short list says what each part is for, one line each: `agent`, the feature
  workflow, the gateway, `record`, `retro`, the Claude skills, `forge` on the
  laptop.
- A diagram shows the life of a run: started by `agent start`, the phases it
  goes through (specify, plan, tasks, implement, converge, review, commit), the
  two gates where it waits for a person (decision before the code, ship before
  the push), how the person learns of a pause (a gateway notification), how
  they answer (`agent menu`), and how the run ends (a draft pull request, or a
  branch that stays on the machine when the person rejects).
- The one-time setup is part of the procedure: the gateway configuration made
  from `config.env.example`, and the two systemd user timers enabled. It ends
  with the check that proves it worked.
- What the tooling needs before a first run is stated: a project checked out
  under `~/projects/<project>/main` that holds Spec Kit's `.specify/`, and a
  logged-in `gh` for the pull request.
- The everyday commands appear as a short table of command and purpose, with no
  copy of their full usage text.
- The rule that the workflow, its scripts and the skills must not change while
  a run is running or paused is stated, with the command that shows it
  (`agent list`).

### R5: Tests

- The command that runs the shell tests stays as it is, and the README says it
  covers the agent scripts too.

### R6: Readability

- The headings alone tell where each machine's procedure starts and ends.
- Steps both machines share (clone, stow dry run) are written in each machine's
  procedure, since a reader follows only one. They are not moved to a shared
  section the reader has to jump to.
- Every diagram has a sentence next to it saying what it shows, so the
  procedure can be followed without seeing the diagram rendered.

## Acceptance scenarios

1. **Given** a reader who has never seen the repository, **when** they open
   the README on GitHub, **then** the first thing under the title is a rendered
   diagram of the two packages and their machines, before any install step.
2. **Given** a fresh Ubuntu server, **when** the owner runs only the command
   blocks of the server procedure, in order, without reading any details,
   **then** they reach a zsh login shell with the p10k prompt, the mise
   runtimes on `PATH` and the dotfiles linked into `$HOME`.
3. **Given** a fresh Mac, **when** the owner runs only the command blocks of
   the macOS procedure, in order, **then** the Homebrew tools are installed,
   the dotfiles are linked, and the iTerm2 profile and macOS settings are
   applied.
4. **Given** today's README, **when** each of its commands and caveats is
   looked up in the new one, **then** each is found, in a step or in its
   details.
5. **Given** a reader about to remove `~/.zshrc` and `~/.gitconfig`, or to run
   `chsh`, **when** they reach that step, **then** a warning comes before the
   command, and the check and the rollback are in the same step, visible
   without unfolding anything.
6. **Given** the owner coming back to the agent tooling, **when** they read
   the agent section, **then** the run diagram tells them where a run waits
   for them, how they are told, and which command answers, without opening a
   script.
7. **Given** a server with the dotfiles linked, **when** the owner follows the
   agent setup steps, **then** the gateway has its configuration, both timers
   show in the list of user timers, and the README names that list as the
   check.
8. **Given** the README opened where diagrams do not render (`less`, `nvim`),
   **when** the reader reaches a diagram, **then** the sentence next to it says
   what it shows, and every step still reads in order.
9. **Given** an agent asked to change something in this repository, **when**
   it reads the README, **then** it learns which package targets which
   machine, that dotfiles are edited in the repository, and that the workflow
   is frozen while a run is in flight.

## Edge cases

- **Diagrams not rendered.** Outside GitHub a diagram shows as its source.
  Each diagram stays small enough to read as text, and no step depends on a
  diagram alone (scenario 8).
- **Folded details not supported.** In a plain-text viewer the details show
  inline. The command of each step still comes before its details.
- **Repository cloned somewhere else.** The note that `-t ~` is needed when the
  repository is not directly under `$HOME` stays with the server stow step.
- **Gate skipped.** A run with nothing to decide, or a summary that is ready to
  ship, goes past a gate without stopping. The run diagram shows each gate as
  a pause that may not happen, so a run that never stops does not look broken.
- **Notification channel.** The gateway can notify through a local file or
  Slack. The README says the file channel works with no account, and where its
  inbox is read. [ASSUMPTION: `file` is presented as the default, matching
  `config.env.example`.]
- **Workflow and README drift apart.** The run diagram names phases and gates,
  not every step of `workflow.yml`, so most workflow changes leave it right.
  [ASSUMPTION: only a gate or a phase added or removed calls for a README
  change.]
- **README edited during a run.** The README is not part of the workflow, so
  editing it while a run is in flight is safe. The freeze applies to the
  workflow, its scripts and the skills.
- **Secrets in examples.** The gateway setup refers to `config.env.example`
  and never shows a real conversation id, token, or the content of a local
  `.env` file.

## Out of scope

- Any change to the dotfiles, scripts, workflow, timers or skills. This feature
  only rewrites the README.
- The scripts' own usage text and comments.
- Images, screenshots, generated diagrams, a documentation site, or a tool that
  builds the README.
- A French README, or a translation alongside the English one.
- Splitting the README into several files.
- An install script that automates the procedure.
- Documenting Spec Kit itself beyond what a run shows the owner.
- New optional tweaks. The existing "Optional" delta and merge settings may be
  reworded, not extended.
