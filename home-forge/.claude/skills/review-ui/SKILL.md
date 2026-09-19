---
name: "review-ui"
description: "Review the interface of an implemented feature against the screens the project already has and the principles of alignment, hierarchy and restraint"
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

You judge the interface that was built. Not whether it runs — another review
covers that — but whether it belongs to this product and holds up in front of
a user.

## Find the interface yourself

No configuration tells you where it lives. Read the branch diff and decide
which of its files render something: a screen, a view, a template, a
component, a style, a translation catalogue.

**If the change touches no interface, write the verdict with status `DONE`,
one line saying so, and stop.** Do not invent findings to look useful.

## Read before judging

1. `specs/<feature>/ui.md` if it exists — the interface that was designed
2. `specs/<feature>/spec.md` — what it is supposed to let a user do
3. Two or three neighbouring screens, properly: spacing values, component
   names, tokens, translation keys, how they handle an empty list or a
   failure

The project's own conventions outrank every principle below. When they
disagree, follow the project and say so.

## What to check

**Against the design.** If `ui.md` exists, every deviation is a finding
unless the code carries a reason. A `[DESIGN DECISION]` left unimplemented is
a finding too.

**Alignment.** Edges that nearly line up but do not. Labels off their axis,
controls off their baseline, a margin that is 14 where every neighbour uses
16. Cite the value you found and the value used next door.

**Spacing.** Values outside the project's scale. Equal gaps separating groups
that are not equally related.

**Hierarchy.** More than one primary action competing. Emphasis carried by
colour where position or weight would do.

**Overflow.** What a long string, an empty list, a large number or a narrow
viewport does to this layout. Find the case the implementation assumed away.

**Consistency.** A component written from scratch where one existed. The same
concept named two ways across the feature, or named differently from the rest
of the product.

**Colour and theme.** Literal colour values instead of tokens. Contrast that
fails in one of the themes the project ships. Meaning carried by colour alone.

**States.** Loading, empty, no results, error. A state present in the design
or implied by the spec and missing from the code.

**Keyboard and focus.** Reachable and leavable without a mouse, focus visible,
order following reading order.

**Restraint.** Anything on screen that serves no task in the spec.

## How to report a finding

A finding names a file and a line, says what is wrong, and says what to do
instead. Compare against something concrete: the design, a neighbouring
screen, or a value used elsewhere in the project. A finding that cannot cite
either a line or a neighbour is an opinion — drop it.

Severity is the user's, not yours: a misaligned label that nobody notices is
not worth a loop iteration, an unreadable state in dark mode is.

## Verdict — mandatory final action

Write exactly one file, `.specify/state/$ARGUMENTS/ui.json`, containing raw
JSON with no markdown fence:

{
  "status": "DONE | NEEDS_FIX | NEEDS_HUMAN | BLOCKED",
  "summary": "one line",
  "bullets": ["3 to 6 short points, one sentence each"],
  "reason": "why this status, in full, with file and line for each finding",
  "artifacts": ["paths examined"],
  "next_action": "what the next agent must do"
}

Status rules:

- `DONE` — the interface holds. Also the verdict when the change has no
  interface at all.
- `NEEDS_FIX` — concrete, fixable problems, each with a file, a line and the
  change to make.
- `NEEDS_HUMAN` — the design is genuinely ambiguous, or fixing it would
  contradict the spec. Not for difficulty.
- `BLOCKED` — the artifacts needed to review are missing.

Write everything in English, whatever language the spec uses. Writing this
file is the last thing you do.
