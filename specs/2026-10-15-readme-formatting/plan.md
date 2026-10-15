# Plan: README formatting

Interface: yes
[ASSUMPTION: the rendered README on GitHub is a page a user reads, so a layout
change to it counts as an interface change.]

## Summary

One file changes: `README.md`. The work is a handful of Markdown edits to the
two numbered procedures and one link. No code, no data, no dependency. The
checks are shell one-liners run against `master:README.md` and the working
copy; none of them is committed, because the spec allows no file but the
README in the pull request (see Deviations).

## What the repository confirms

Every fact the README states was checked against the tree before planning:

| README claim | Checked in |
|---|---|
| `.zshrc` clones Powerlevel10k (server) and fzf-tab into `~/.local/share` | `home-forge/.zshrc:34-35`, `home/.zshrc:36` |
| `.tmux.conf` clones TPM and installs the plugins | `home-forge/.tmux.conf:5-8`, `home/.tmux.conf:5-8` |
| mise manages node, rust, claude, neovim, tree-sitter | `home-forge/.config/mise/config.toml` |
| `.p10k.zsh` runs in `nerdfont-complete` mode | `home-forge/.p10k.zsh:112` |
| the package ships `fd`, `bat`, `emojify`; `.gitconfig` pipes through `emojify` | `home-forge/.local/bin/`, `home-forge/.gitconfig:18` |
| `merge.conflictstyle` is `diff3`, a `[delta]` section exists | `home-forge/.gitconfig:43,56` |
| `ll` exists | `home-forge/.zshrc:65` |
| `rbenv`, `pyenv`, `nodenv`, `rustup`, `stow` come from the Brewfile | `Brewfile:26-40` |
| `iTerm2_State.itermexport`, `install-macos-settings.sh` exist | repository root |
| 14 `*.test.sh` files under `home-forge` for the Tests loop | `find home-forge -name '*.test.sh'` |

No claim is wrong, no trailing whitespace exists and the file ends with a
newline. **No correction is planned**; the change is layout only, which the
spec's edge case "No mistake found" accepts. [ASSUMPTION: a correction the
implementer finds later is applied only if it meets the spec's scope rule 2
and is named in the pull request description.]

## Changes to `README.md`

Line numbers refer to `README.md` on `master` (122 lines).

1. **macOS spacing (lines 19-20, 27-28, 44-45).** Insert a blank line between
   steps 1 and 2, 3 and 4, 6 and 7, so every step of the macOS list is
   separated by one blank line, as every step of the Ubuntu list already is.
   [ASSUMPTION: the loose style (blank line between steps) wins over the tight
   one, because the Ubuntu list and every step holding a code block already
   use it; going tight is impossible around code blocks anyway.]
2. **Raw URL (line 19).** `Install Homebrew from https://brew.sh/` becomes
   `Install Homebrew from [brew.sh](https://brew.sh/)`. The wording stays; the
   link text is the host name, like `[mise](https://mise.jdx.dev)`.
   URLs inside shell blocks (`git clone https://github.com/...`) are commands,
   not prose, and stay raw.
3. **Continuation indent (lines 65-68).** Step 2's continuation lines go from
   3 to 4 spaces. [ASSUMPTION: 4 spaces is the one indent for everything inside
   a numbered step — continuation lines, paragraphs, fences, nested lists —
   because 4 is what 41 of the 50 indented lines already use; normalising to 3
   would rewrite every code block for no rendered difference.] The 2-space
   continuations of the bullet lists (lines 15, 122) are correct for a `- `
   marker and stay.
4. **Step 5 checklist (lines 95-100).** The first two sentences keep their
   wording and line breaks and are re-indented to 4 spaces. The third sentence becomes
   a lead-in and a nested bullet list, one item per check, original wording and
   order, nothing added:

   ```markdown
   5. Test before switching shells. Keep **two** SSH sessions open and, in one of them,
       run `zsh -l` — a child process you leave with `exit`, never `source ~/.zshrc`,
       which asks bash to read zsh. Check:

       - the p10k prompt and its glyphs
       - `node -v`, `cargo -V` and `which claude` (the mise test)
       - `git diff` rendered by delta
       - `git log` with its gitmoji
       - `Ctrl-T` / `Ctrl-R` / `Alt-C`
       - `cd <Tab>`
       - `ll`
       - `nvim`
       - `C-hjkl` across tmux panes and nvim splits
   ```

   [ASSUMPTION: "Check the p10k prompt…" becomes "Check:" followed by items
   that drop the joining commas and the final "and" — punctuation only, no word
   of a check changes.] [ASSUMPTION: `node -v`, `cargo -V` and `which claude`
   stay one item, since "(the mise test)" qualifies the three together.]
   [ASSUMPTION: items carry no trailing period, like the list under
   "Some pieces install themselves", which ends each item with one only because
   each is a sentence.]

Nothing else moves: headings, table, the self-installing list, every shell
block, step 3's `rm -f` line, the iTerm2 menu path, the `:floppy_disk:`
shortcode, and paragraphs not listed above (no reflow-only change).

## Tests

Each acceptance scenario gets one check, run from the worktree root after the
edit. `old` is `<(git show master:README.md)`. None is kept in the repo (see
Deviations); their output goes in the pull request description.

| Scenario | Check | Passes when |
|---|---|---|
| Only the README changes | `git diff --name-only master...HEAD` after the commit | prints exactly `README.md` |
| No content added | the sorted word lists of both versions, `tr -s '[:space:]' '\n' \| sort`, compared with `diff` | the only words that differ are the lost `and` and the punctuation of the step 5 checklist, and the added `[brew.sh](https://brew.sh/)`; each one is named in the PR |
| Nothing the reader runs changes | extract every fenced `shell` block with its fence indent stripped (`awk` keeping the fence's leading-space count and `substr`-ing it off each body line, prefixed by the block's ordinal), on both versions, then `diff` | no output |
| Lists render consistently | `grep -nE '^[0-9]+\. ' README.md` and `grep -nE '^ {1,3}[^ ]\|^ {5,}[^ ]' README.md` limited to the two procedures | numbers run 1-7 and 1-6 with one blank line before each step; no line inside a step is indented other than 4 spaces (or 6 for the `\` continuation inside the apt block, which is block content) |
| Links are links | `grep -nE '(^\|[^(<])https?://' README.md` outside fenced blocks | no hit in prose |
| Long checklists become lists | `sed -n '/^5\. Test/,/^6\./p' README.md` on the Ubuntu section | nine `- ` items, in the order of the old sentence |
| Structure is preserved | `diff <(git show master:README.md \| grep '^#') <(grep '^#' README.md)`, same for `grep '^|'` and the `^- ` lines of the intro | no output |
| Corrections are justified | `git diff master -- README.md` read hunk by hunk | every hunk is one of changes 1-4 above |

The GitHub rendering itself is checked on the draft pull request the pipeline
opens: both procedures show as one continuous numbered list, every code block
sits inside its step. [ASSUMPTION: no local GFM renderer is relied on — none
is known to be installed, and installing one is a dependency; sending the
README to `gh api markdown` before the push would publish repository content
early.]

The repository's own suite (`find home-forge -name '*.test.sh' …` from the
README) is untouched by this change and is not part of the proof.

## Keeping `specs/` out of the pull request

`commit.sh list` runs `git add -A` and excludes only `RUNNER_PATHS`
(`home-forge/agents/feature/scripts/runner-paths.sh`), which does not cover
`specs/`. Left alone, `split-commits` would commit this spec and plan, and the
first scenario would fail.

Before the commit step, add one line to the repository's shared exclude file
(`$(git rev-parse --git-common-dir)/info/exclude`):

```
/specs/2026-10-15-readme-formatting/
```

plus one exact line for any other file the pipeline leaves untracked outside
`RUNNER_PATHS` (for instance `/.specify/feature.json`), found with
`git status --porcelain`. Check: `git status --porcelain` lists only
`README.md`. [ASSUMPTION: a local, path-exact exclude entry is the way to keep
the artifacts out, since changing `commit.sh` or `.gitignore` would put a
second file in the diff; the entry names this feature only, so other
worktrees' specs are unaffected, and it is removed once the PR is merged or
abandoned.]

## Order of work

1. Add the exclude entries. Check: `git status --porcelain` shows nothing but
   what step 2 will change.
2. Apply changes 1-4 to `README.md`. Check: the "Nothing the reader runs
   changes", "Structure is preserved" and "Links are links" rows pass.
3. Run the remaining checks of the Tests table. Check: every row passes.
4. Commit: one commit, `:memo: tidy the readme layout`, `README.md` only.
   [ASSUMPTION: one topic, so one commit.] Check: `git diff --name-only
   master...HEAD` prints `README.md`.
5. On the draft PR, read the rendered README. Check: the "Lists render
   consistently" scenario holds on github.com. The PR description says no
   correction was made (or names each one) and pastes the check outputs.

## Deviations

- **Tests are not kept in the repository.** The constitution says a test
  worth writing to check the work goes in the repo. The spec allows no file
  but `README.md` in the diff, and the change adds no logic (it is a document
  edit, which the constitution exempts as "config and one-line edits"), so the
  checks are run, their output is recorded in the pull request, and nothing is
  committed beside the README.
- **The Spec Kit documents are not committed.** The pipeline's split step
  commits them apart; the spec's first scenario excludes them from the pull
  request, and the spec says that rule wins. They are kept out by a local
  exclude entry, not by a change to the pipeline, which is out of scope.
- **No diff shown for approval before editing.** The constitution asks for
  approval before changing an existing file; this run is headless, so the
  approval point is the pipeline's decision gate before code and the draft
  pull request after it.
