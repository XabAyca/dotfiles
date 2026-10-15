# Spec: README formatting

## What and why

The owner wants `README.md` easier to read and scan: a cleaner layout, with
nothing new added and only corrections allowed. The README is the one page
someone reads to install these dotfiles on a new machine. Today its layout is
uneven:

- numbered steps are spaced and indented differently from one list to the next
  (some steps sit tight together and others are separated by blank lines;
  continuation lines are indented with 2, 3 or 4 spaces);
- one URL is pasted raw (`https://brew.sh/`) where every other one is a link;
- the server's step 5 crams nine checks into a single paragraph.

This feature improves the layout of `README.md`. It does not change what the
README tells the reader to do.

## Scope rule

Every change has to be one of these:

1. **Layout**: list spacing, indentation, code block placement, line wrapping,
   link syntax, emphasis, and splitting a long paragraph into a list. The
   wording stays the same.
2. **Correction**: a typo, a grammar mistake, a broken or inconsistent Markdown
   construct, or an instruction that is factually wrong about something the
   repository itself shows (a file name, a path, a package name).

Anything else is out of scope, whatever its merit.

## Acceptance scenarios

**Only the README changes**
- Given the branch `2026-10-15-readme-formatting`,
- when its pull request is compared with `master`,
- then the only file in the diff is `README.md`.
  [ASSUMPTION!: this spec and every other pipeline artifact under `specs/` stay
  out of the pull request's diff. The owner said the PR records nothing but the
  README, and that rule wins over keeping the spec next to the change.]

**No content added**
- Given the README before and after the change,
- when the two are compared section by section,
- then every section, step, command, link and fact in the new version was
  already in the old one. No new section, step, tip, badge, table of contents
  or explanation appears.
  [ASSUMPTION!: no table of contents and no badges. Both would be additions
  under the owner's rule, even though they are layout aids.]

**Nothing the reader runs changes**
- Given any shell block in the old README,
- when the reader copies the matching block from the new README,
- then the commands are character for character the same, in the same order,
  and stay under the same step, unless a correction fixes a command that is
  provably wrong.
  [ASSUMPTION: no command in the current README is provably wrong, so every
  shell block is expected to survive unchanged.]

**Lists render consistently**
- Given the macOS and Ubuntu numbered procedures,
- when the README is rendered on GitHub,
- then each procedure displays as one continuous numbered list (no restart at
  1, no step escaping the list), every code block shows inside the step it
  belongs to, and both procedures use the same spacing between steps.
  [ASSUMPTION: GitHub-flavoured Markdown as rendered on github.com is the
  reference renderer.]

**Links are links**
- Given a URL in the prose,
- when the README is rendered,
- then it shows as link text in the same style as the other links on the page,
  not as a raw pasted URL.

**Long checklists become lists**
- Given the server's "test before switching shells" step,
- when the README is rendered,
- then the checks to run show as a list of separate items rather than one long
  sentence, and each check keeps its original wording and order.
  [ASSUMPTION: this split is layout, not an addition, because no check is
  added, removed or reworded.]

**Structure is preserved**
- Given the headings of the old README (`dotfiles`, `macOS`,
  `Ubuntu server (headless, SSH)`, `Tests`, `Optional`),
- when the new README is read,
- then the same headings appear in the same order and at the same levels, and
  so do the packages table and the list of self-installing pieces.
  [ASSUMPTION!: no sections are reordered or renamed, and none are promoted or
  demoted. `Tests` and `Optional` stay under the Ubuntu section. Anchors other
  pages may link to keep working.]

**Corrections are justified**
- Given any change that alters the meaning of a sentence,
- when it is reviewed,
- then it fixes something the repository itself shows to be wrong, and the
  pull request description names it.

## Edge cases

- **The `:floppy_disk:` emoji shortcode in the title.** GitHub renders it, so it
  stays as it is.
- **The iTerm2 menu path ("Settings > Settings > Import").** It reads like a
  typo, but the repository cannot confirm the real menu path, so it is left as
  written. [ASSUMPTION: anything the repository cannot verify is not a
  correction.]
- **Line wrapping.** Prose is rewrapped only where a paragraph is already being
  touched. A paragraph changed only to reflow its lines is churn.
  [ASSUMPTION: no reflow-only changes.]
- **Trailing whitespace or a missing final newline.** Fixed if present. It is
  a correction that does not change the rendered output.
- **The `rm -f ~/.zshrc ~/.gitconfig` line, which only the Ubuntu procedure
  has.** This is a content difference between the two procedures, not a layout
  one, so it is left alone.
- **No mistake found.** If no correction is justified, the pull request
  contains only layout changes. That is a valid result.

## Out of scope

- Any file other than `README.md`, including the dotfiles the README
  describes.
- New content of any kind: sections, steps, explanations, troubleshooting,
  a table of contents, badges, images, translations.
- Rewording for style when the sentence is correct.
- Changing commands, versions, package lists or the order of installation
  steps.
- Adding a Markdown linter, a formatter config or a CI check for the README.
