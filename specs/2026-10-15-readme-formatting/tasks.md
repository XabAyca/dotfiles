# Tasks: README formatting

- [ ] T001 [HUMAN] Will a person add `/specs/2026-10-15-readme-formatting/` to `main/.git/info/exclude` (outside this worktree, refused to the session twice), or should forgehub's commit step leave `specs/` out? [P] Add `/specs/2026-10-15-readme-formatting/` to `$(git rev-parse --git-common-dir)/info/exclude`, plus one exact line for every other untracked file the pipeline leaves outside `RUNNER_PATHS` (e.g. `/.specify/feature.json`), so `git status --porcelain` lists nothing but what `README.md` will change
- [x] T002 In the macOS procedure of `README.md`, insert one blank line between steps 1-2, 3-4 and 6-7 so every step is separated by one blank line, like the Ubuntu procedure
- [x] T003 In macOS step 1 of `README.md`, turn the raw `https://brew.sh/` into `[brew.sh](https://brew.sh/)`, wording unchanged; URLs inside shell blocks stay raw
- [x] T004 In Ubuntu step 2 of `README.md`, move the continuation lines from 3 to 4 spaces of indent, wording and wrapping unchanged
- [x] T005 In Ubuntu step 5 of `README.md`, keep the first two sentences with their wording and line breaks, re-indented to 4 spaces, end the lead-in with "Check:", then one blank line and a tight nested `- ` list of the nine checks at 4 spaces, in their original order and wording, joining commas and final "and" dropped, no trailing period (block in plan, change 4)
- [ ] T006 [P] Test "No content added": diff the sorted word lists of `git show master:README.md` and `README.md` (`tr -s '[:space:]' '\n' | sort`); the only differences are the dropped `and` and checklist punctuation of step 5 and the `[brew.sh](https://brew.sh/)` link; no new heading, step, table of contents or badge
- [ ] T007 [P] Test "Nothing the reader runs changes": extract every fenced `shell` block of both versions with its fence indent stripped and prefixed by its ordinal, then `diff` them; no output
- [x] T008 [P] Test "Lists render consistently": `grep -nE '^[0-9]+\. '` on both procedures shows steps 1-7 and 1-6 each preceded by one blank line, and no line inside a step is indented other than 4 spaces (6 for the `\` continuation inside the apt block)
- [x] T009 [P] Test "Links are links": `grep -nE '(^|[^(<])https?://' README.md` outside fenced blocks returns no hit in prose
- [ ] T010 [P] Test "Long checklists become lists": `sed -n '/^5\. Test/,/^6\./p' README.md` shows nine `- ` items in the order of the old sentence, each with its original wording
- [ ] T011 [P] Test "Structure is preserved": `diff` the `^#` lines, the `^|` table lines and the `^- ` lines of the intro and Optional between `master:README.md` and `README.md`; no output
- [ ] T012 [P] Test "Corrections are justified": read `git diff master -- README.md` hunk by hunk; every hunk is one of T002-T005, and any meaning change is a correction the repository proves and is named for the pull request description (none planned)
- [ ] T013 Commit `README.md` alone as `:memo: tidy the readme layout`
- [ ] T014 Test "Only the README changes": `git diff --name-only master...HEAD` prints exactly `README.md`
- [x] T016 [HUMAN] On the draft pull request, read the rendered README: both procedures show as one continuous numbered list and every code block sits inside its step; the description says no correction was made (or names each one) and pastes the outputs of T006-T012 and T014
- [x] T015 [HUMAN] Once the pull request is merged or abandoned, remove the T001 lines from the shared `info/exclude`
