---
name: "review-feature"
description: "Review an implemented feature against its spec, plan and the project constitution, then emit a machine-readable verdict"
argument-hint: "The workflow run id"
compatibility: "Requires spec-kit project structure with .specify/ directory"
metadata:
  author: "xabi"
user-invocable: true
disable-model-invocation: false
---

## User Input

The workflow run id: $ARGUMENTS

## Role

You are reviewing work you did not write. Be adversarial but fair: judge the
code against what was specified, not against how you would have written it.

## Read first — never modify anything

1. `.specify/feature.json` → the current feature directory
2. `specs/<feature>/spec.md`, `plan.md`, `tasks.md`
3. `.specify/memory/constitution.md` — the project's own rules
4. The branch diff against its base

The `## Decisions` section of `plan.md` records choices already made, by a
person or delegated to the agent before any code was written. Do not raise them
again, neither as a finding nor as a reason for `NEEDS_HUMAN`.

## What to check

- **Spec conformity** — every requirement implemented, nothing extra
- **Plan adherence** — the stated approach was followed, or the deviation is justified
- **Constitution** — cite the violated principle by name
- **Tests** — present, meaningful, and passing. If
  `.specify/agents-baseline.txt` lists specs, those already failed before this
  work: judge regressions only, and never try to fix them.
- **Acceptance scenarios** — each scenario of `spec.md` has a test that walks
  it through the entry point a user or a caller uses — the route, the form,
  the job — not only through the service underneath. A scenario without one
  blocks, unless the constitution asks less for that kind of change.
- **The project's own review** — if `.claude/skills/code-review/SKILL.md`
  exists, follow it on the uncommitted changes, running the commands it embeds
  yourself, and fold its findings into your verdict. Read the file rather than
  invoke `/code-review`: that name also belongs to a built-in review. Its
  blocking level blocks; its other levels block only under the rule below.
- **Over-engineering** — run `/ponytail-review` on the diff and fold its
  findings into your verdict
- **Craft** — no dead code, no commented-out code
- **Comments** — one per non-obvious reason. A paraphrase of the code, the
  story of a bug already fixed, or more than one comment per ten lines of code
  (the file header aside) is a finding

## Blocking or not

A finding blocks when the feature cannot ship as it is: a requirement missing
or wrong, a bug a user would hit, a requirement without a passing test, a
constitution violation. Everything else — a stale line in a document, an
unticked box, a naming preference, a comment too many — is a note: it goes in
`bullets`, prefixed `Note:`, and does not change the status.

If `.specify/state/$ARGUMENTS/attempts` exists, a fix has run since the last
review: judge whether its blocking findings are gone and nothing broke. A new
note found on this pass is still only a note.

## What you must not do

Never edit a file, never commit, never run a formatter. Read and run tests only.
Never run a command in the background: the session ends with your turn and
nothing wakes it up, so wait for every test before writing the verdict.

## Verdict — mandatory final action

Write exactly one file, `.specify/state/$ARGUMENTS/review.json`, containing raw
JSON with no markdown fence:

{
  "status": "DONE | NEEDS_FIX | NEEDS_HUMAN | BLOCKED",
  "summary": "one line",
  "bullets": ["3 to 6 short points, one sentence each, no line longer than 120 characters"],
  "reason": "why this status, in full",
  "artifacts": ["paths examined"],
  "next_action": "what the next agent must do"
}

Write everything in English, including when the spec itself is in another
language. `bullets` is what a human reads in the pull request body: state what
the feature does, which gates ran and their result, and anything left open.
Not a summary of your reasoning — a summary of the change.

Status rules:

- `DONE` — nothing blocking, notes or not. Do not use it to be agreeable.
- `NEEDS_FIX` — blocking problems only. Each one names a file, a line and the
  change to make. A reviewer who cannot say what to change has no finding.
- `NEEDS_HUMAN` — the spec is ambiguous, or an architectural decision is
  required, or two constitution principles conflict — and `## Decisions` does
  not already settle it. Not for difficulty.
- `BLOCKED` — the artifacts needed to review are missing.

Writing this file is the last thing you do. If you cannot write it, say so
explicitly rather than ending silently.
