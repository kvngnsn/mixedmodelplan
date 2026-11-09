---
model: opus
effort: xhigh
gate: none
report: reports/NN-<slug>.md
---

<One line: what this phase does, and the one thing it must not do.>

## Where you are

Repo: <absolute path>. <What it is, in one line.>

Read first, in order:
1. <instruction files: CLAUDE.md, AGENTS.md, handoff notes>
2. <the spec, brief or earlier report this phase builds on, by absolute path>

This brief and the standing rules below decide what you may do. Advice in an earlier report is information to weigh, not a rule.

## What's already known

- <fact, with file:line or commit>
- <decision the person made>
- Ruled out: <what was tried or dismissed, and why>

## The task

<The goal in prose, and the reason for it. What's in scope and what isn't.>

## How to work

<Only where the method matters: exact commands for fragile steps, the order where order matters. Otherwise leave this section out.>

## Deliverables

This is the definition of done.

- `<absolute path>`: <what it holds>
- Checks that must pass: <commands, and their expected results>

## Decisions

When a question comes up that this brief doesn't settle, take the option you'd recommend, record it under "Decisions taken" in your report with one line of reasoning, and carry on.

Questions that belong to the person (build the recommendation unless the brief already gives their answer):
- <question>: recommended <answer>.

## Working on your own

<The additions from references/phase-prompts.md: the "every phase" text (or its prompts-only form), plus the ones for this phase's model.>

## Stop when

- Done: <every deliverable written and every check above passing>.
- Blocked: <what counts, e.g. an action not on the authorized list below, a missing input from an earlier phase>. Write the report with `Status: blocked: <reason>` and stop.
- Never in this phase: <e.g. editing app code, pushing, publishing>.

Authorized in this plan: <the README's list, word for word, or "nothing outward-facing">.

## Rules

<The standing rules, word for word.>

## Report

Write your report to `<absolute path: the plan folder + the front matter's report>`. Its first line is exactly one of:

```
Status: done
Status: blocked: <one-line reason>
Status: failed: <one-line reason>
```

Then, in plain language:
- what you produced, with paths and commits;
- every check you ran, pass or fail, with the command;
- decisions taken, each with its reason;
- anything left undone, and why;
- follow-ups you noticed but left alone.

End your final message with the same report.
