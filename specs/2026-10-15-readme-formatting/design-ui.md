# Design: README formatting

The interface is `README.md` itself, read in two places: rendered on github.com
(the spec's reference renderer) and as raw Markdown in a terminal, over SSH, on
the machine being set up (`less README.md` from the fresh clone). Both views
are designed below. No other screen exists or is added.

There is no other page to borrow a visual language from: the only other
Markdown in the tree is agent instructions (`home-forge/.claude/**`). The
README is its own reference, and every rule below is a pattern it already
uses in most places, extended to the few places it does not.

## Placement

Unchanged. Same file, same headings, same levels, same order (spec,
"Structure is preserved"). Heading anchors (`#macos`,
`#ubuntu-server-headless-ssh`, `#tests`, `#optional`) keep working.

## The visual language already in the README

| Element | Existing rule | Where it already holds |
|---|---|---|
| Step separation | one blank line between numbered steps | every Ubuntu step; macOS steps 2-3, 4-5, 5-6 |
| Step body indent | 4 spaces for everything inside a numbered step | 41 of 50 indented lines (plan, change 3) |
| Bullet continuation | 2 spaces under `- ` | lines 15, 122 |
| Commands to run | fenced ` ```shell ` block, inside its step | every multi-line command |
| One short command | inline code after a colon, on the step line | macOS 3, 7; Ubuntu 4 |
| Link text | the name of the thing, never the raw URL | `[stow]`, `[mise]`, `[MesloLGS NF]` |
| Emphasis | `**bold**` on one word that must not be missed | **from**, **two**, **new** |
| Lists of facts | `- ` items, sentence case, no trailing period unless a sentence | "Some pieces install themselves" |
| Prose width | wrapped by hand, no prose line longer than the current longest (~92 columns) | whole file |

Nothing new is introduced. The feature applies these rules where they are
broken (plan, changes 1-4).

## Regions

```
┌──────────────────────────────────────────────────────────────┐
│ 💾 dotfiles                                          (h1)    │  unchanged
│ intro · packages table · self-installing list                │  unchanged
├──────────────────────────────────────────────────────────────┤
│ macOS                                                (h2)    │  steps 1-7: spacing,
│   numbered procedure                                         │  brew.sh link
├──────────────────────────────────────────────────────────────┤
│ Ubuntu server (headless, SSH)                        (h2)    │  step 2 indent,
│   intro · prerequisite · numbered procedure                  │  step 5 checklist
│   Tests                                              (h3)    │  unchanged
│   Optional                                           (h3)    │  unchanged
└──────────────────────────────────────────────────────────────┘
```

Width is governed by the renderer (github.com column) or the terminal. The
README sets no width of its own; the raw view stays readable at 92 columns
and wraps naturally below that.

## Component 1: macOS procedure (changed)

Rendered on GitHub, after:

```
1. Install Homebrew from brew.sh            ← underlined link, theme link colour
                                            ← same gap as every other step
2. Clone this repository:
   ┌───────────────────────────────────────────────────── [⧉] ┐
   │ git clone https://github.com/XabAyca/dotfiles ~/.dotfiles│
   │ cd ~/.dotfiles                                           │
   └──────────────────────────────────────────────────────────┘

3. Install the CLI tools, apps and fonts: brew bundle

4. Link the dotfiles. A ~/.zshrc or ~/.gitconfig already in place …
   ┌─ code ─ [⧉] ┐
   …
7. macOS settings: source install-macos-settings.sh
```

Raw, after:

```
1. Install Homebrew from [brew.sh](https://brew.sh/)

2. Clone this repository:

    ```shell
    …
```

The gap between 1-2, 3-4 and 6-7 becomes the one the rest of the page uses.
On GitHub this turns the list "loose": every step becomes a paragraph with
the same top margin, so the eye no longer reads 1-2 or 6-7 as a pair. This is
the whole visible change for macOS.

## Component 2: Ubuntu step 2 (changed in raw view only)

Continuation lines move from 3 to 4 spaces. GitHub renders it identically;
the change is for the raw view, where the left edge of step 2's text now
lines up with the code blocks of steps 1 and 3 instead of sitting one column
off.

```
2. Font, on the machine you connect **from**: install
    [MesloLGS NF](https://github.com/romkatv/powerlevel10k#manual-font-installation)
    and select it in the terminal. …
```

[DESIGN DECISION: the raw view's first line (`2. Font…`) keeps its text at
column 4 while continuations sit at column 5. Markdown cannot align both
without a 3-space indent, which the plan rejects; the one-column offset is
accepted because every other step already has it.]

## Component 3: Ubuntu step 5 checklist (changed)

Rendered on GitHub, after:

```
5. Test before switching shells. Keep two SSH sessions open and, in one
   of them, run zsh -l — a child process you leave with exit, never
   source ~/.zshrc, which asks bash to read zsh. Check:

     • the p10k prompt and its glyphs
     • node -v, cargo -V and which claude (the mise test)
     • git diff rendered by delta
     • git log with its gitmoji
     • Ctrl-T / Ctrl-R / Alt-C
     • cd <Tab>
     • ll
     • nvim
     • C-hjkl across tmux panes and nvim splits

6. Only once that is reliable, several sessions in a row:
```

Raw view: exactly the block in the plan (change 4): two re-wrapped sentences
at 4 spaces, one blank line, nine `- ` items at 4 spaces.

- The warning sentence (`never source ~/.zshrc`) stays in the lead-in prose,
  above the list, so it is read before the checks, as it is today.
- The list sits one blank line under "Check:", the same gap as a code block
  under its step, so it reads as part of step 5 and not as a new step.
- A nested bullet inside a numbered step is new to this README but uses the
  page's own bullet style (component "Lists of facts" above); no other
  structure was considered, since a table would add column headers, which is
  content.

[DESIGN DECISION: the nested list is tight — no blank line between items.
Nine one-line items with gaps would be taller than the paragraph they
replace, and the outer list's gaps already separate steps.]

## Controls

The page has no control of its own. The ones the reader uses are GitHub's:

| Control | Does | Change |
|---|---|---|
| Link | opens the target | `brew.sh` becomes one; others unchanged |
| Copy button on a code block | copies the block's content without its 4-space indent | none — every block keeps its content (spec, "Nothing the reader runs changes") |
| Heading anchor (hover `#`) | links to the section | none, headings unchanged |

## States

A static document has no loading, empty or error state of its own. The
states that matter are the ones the reader's view puts it in:

| State | What the reader sees |
|---|---|
| Full (github.com, desktop) | the mock-ups above |
| Narrow (github.com mobile, ~360 px) | prose and bullets reflow; code blocks keep their lines and scroll horizontally inside the block, never the page (GitHub default, unchanged). The checklist items are short enough not to wrap except the last one, which wraps under its own text |
| Raw, terminal ≥ 92 columns | every line fits, indents line up as described |
| Raw, terminal < 92 columns | the terminal wraps long lines; the 4-space indent and the `- ` markers still mark where each step and check starts |
| Dark / high-contrast theme | colour is GitHub's own; the README carries no colour, so nothing to check beyond the defaults |
| Broken render (a step escaping the list, a code block outside its step) | the failure this feature exists to prevent; checked on the draft PR (plan, Tests) |

## Tokens

None. Markdown carries no colour, size or spacing value; GitHub's theme does.
The only "tokens" are the indents and blank lines in the table above.

## Text and translation

English only, as today; no translation keys. Every word stays (spec, scope
rule 1). The only text-level changes are those the plan names: the link text
`brew.sh`, and in step 5 "Check the p10k prompt…" becoming "Check:" with the
joining commas and final "and" dropped.

## Accessibility

- **Structure carries meaning, not looks.** Steps are a real ordered list;
  the checks become a real nested unordered list, so a screen reader announces
  "list, 9 items" inside step 5 instead of one 60-word sentence.
- **Link text** names the destination (`brew.sh`) instead of reading out
  `h t t p s colon slash slash…`.
- **Keyboard.** Tab order follows reading order because it is document order:
  `stow`, `brew.sh`, then the copy buttons and links of each step, top to
  bottom. The new link adds one tab stop between the intro links and step 2's
  copy button. Focus styling is GitHub's.
- **Never colour alone.** Links are underlined on GitHub; emphasis is weight
  (`**two**`) and the word itself; code is a monospace box, not just a tint.
- **Code blocks** keep their `shell` language tag, so highlighting stays and
  assistive tech is told it is code.
- The `:floppy_disk:` in the title is announced as "floppy disk" — left as is
  (spec, edge cases).

## What this is not

- Not a restyle: no GitHub alert boxes (`> [!WARNING]`) on steps 5 or 6,
  though they would draw the eye — they add structure the README never had.
- Not a table of contents, badges, images or a collapsible section (spec,
  out of scope).
- Not a reflow of untouched paragraphs, and not a change to the raw
  terminal width.
- Not a rendering setup for the server (`glow`, `mdcat`): the raw view is
  designed to read well as plain text instead.
