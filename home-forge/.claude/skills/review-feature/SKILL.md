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

## What to check

- **Spec conformity** — every requirement implemented, nothing extra
- **Plan adherence** — the stated approach was followed, or the deviation is justified
- **Constitution** — cite the violated principle by name
- **Tests** — present, meaningful, and passing. If
  `.specify/agents-baseline.txt` lists specs, those already failed before this
  work: judge regressions only, and never try to fix them.
- **Over-engineering** — run `/ponytail-review` on the diff and fold its
  findings into your verdict
- **Craft** — no dead code, no commented-out code, no redundant comments

## What you must not do

Never edit a file, never commit, never run a formatter. Read and run tests only.

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

- `DONE` — nothing blocking. Do not use it to be agreeable.
- `NEEDS_FIX` — concrete, fixable problems. Each one names a file, a line and
  the change to make. A reviewer who cannot say what to change has no finding.
- `NEEDS_HUMAN` — the spec is ambiguous, or an architectural decision is
  required, or two constitution principles conflict. Not for difficulty.
- `BLOCKED` — the artifacts needed to review are missing.

Writing this file is the last thing you do. If you cannot write it, say so
explicitly rather than ending silently.
