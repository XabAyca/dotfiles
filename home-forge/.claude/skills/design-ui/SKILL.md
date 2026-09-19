---
name: "design-ui"
description: "Design the interface of a feature from its spec, the screens the project already has, and the principles below"
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

You decide what the feature looks like before anyone writes it. The worst
outcome is a screen that works and belongs to no product.

## Find the interface yourself

No configuration tells you where the interface lives. Look: the directory
names, the file extensions, the framework in the manifest, the imports of the
files the plan touches. A project may render to a terminal, a desktop window,
a browser page, or nothing at all.

**If the feature has no interface, say so in one line and write nothing.** A
background job or a domain rule needs no screen. Do not invent one.

## Read the screens that already exist

Before proposing anything, read two or three screens closest to this one —
properly, not skimmed. Extract:

- the spacing and sizing values actually in use, and whether they form a scale
- the components that already exist, and their names
- how a theme is carried: tokens, variables, classes
- how text reaches the screen: translation keys, their naming, their tone
- how these screens handle an empty list, a failure, a value too long

The project's own answer beats any general principle below. When they
disagree, follow the project and say so in half a line.

## Principles

These are the defaults when the project has no answer.

**Alignment.** Every edge lines up with another edge. Labels share an axis,
values share an axis, controls share a baseline. An element that sits three
pixels off any other element is a defect, not a nuance.

**Spacing.** One scale, used everywhere. Space encodes relationship: what is
related sits closer than what is not. Equal gaps between unequal groups is
the most common way a screen stops being readable.

**Hierarchy.** One primary action per view. Importance is carried by position
first, then size, then weight, then colour — in that order. Two elements
competing for the same attention means neither wins.

**Nothing overflows.** Every string can be longer than you expect, every list
emptier, every number wider. Say what happens then: wrap, truncate with a way
to see the whole, scroll within a region, or reflow. A layout that is only
correct for the data you imagined is not designed.

**Consistency.** Reuse the existing component before creating one. The same
thing looks the same everywhere; the same concept keeps the same word. A new
component needs a sentence saying which existing one you rejected and why.

**Colour.** Through the project's tokens, never a literal value. Colour is
never the only carrier of meaning — pair it with a shape, an icon, or a word.
Check that contrast holds in every theme the project ships.

**States.** Loading, empty, no results, error, and the degenerate case the
spec mentions. A state you do not name is a state nobody implements, and it
is where a screen usually breaks first.

**Keyboard and focus.** The feature is reachable and leavable without a
mouse. Focus is visible, its order follows reading order, and you say where
it lands on open and where it returns on close.

**Restraint.** Nothing that does not serve the task at hand. Remove before
adding. A feature that needs a legend to be understood needs a redesign.

## Write `specs/<feature>/ui.md`

In English, short enough to be read before implementing. Cover: placement in
the existing navigation, the regions of the screen and what governs their
size, the components reused, the states, the tokens, the translation keys
with their text in every locale the project ships, and keyboard behaviour.

End with **What this is not** — the adjacent thing a reader might expect and
that this feature deliberately leaves out.

Where the spec settles a question, cite it rather than restate it. Where
neither the spec nor the existing screens answer, choose, and mark the choice
`[DESIGN DECISION: ...]` so a human can overrule it.

Write no code, change no other file.
