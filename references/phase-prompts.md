# Writing a phase prompt

A phase prompt is read by an agent that starts with nothing: it hasn't seen the conversation, the earlier phases or the person's preferences, and it can't ask a question until the phase is over. Whatever it needs has to be in the prompt or in a file the prompt names. Test every phase file the way Anthropic suggests testing any prompt: would a capable colleague who knows nothing about this job be able to follow it?

## Contents

- The shape
- How to write it
- Additions for unattended runs, by model
- Launcher phases
- Example

## The shape

`templates/phase.md` has these sections in this order. Leave a section out only when it truly has nothing to say.

1. **One opening line**: what this phase does, and the one thing it must not do ("Find the causes and write the spec; don't change app code.").
2. **Where you are**: the repo's absolute path and what it is; the files to read first, in order; the earlier phases' reports and deliverables to build on.
3. **What's already known**: facts established so far (with file:line or commit where you have them), decisions the person has made, and what has been ruled out. This is the section that saves the most time, because without it the phase rediscovers everything. The exception is a phase whose job is discovery that the person wants done independently: give it the symptoms and where to look, and mark any suspicion of yours as an unconfirmed lead.
4. **The task**: the goal in prose, with the reason behind it; what's in scope and what isn't.
5. **How to work**: only where the method matters. Fragile operations (deploys, migrations, anything destructive) get exact commands. Judgment work gets the goal and its constraints, not a script, because the model's own plan is usually better than a hand-written one.
6. **Deliverables**: the definition of done. Give each file's exact path and what it holds, and the checks that must pass. Phrase done as things someone else can verify, not as qualities ("thorough", "clean").
7. **Decisions**: how open questions are handled (take the recommended answer, record it, carry on), and any questions that belong to the person, each with a recommendation.
8. **Working on your own**: the additions below for this phase's model.
9. **Stop when**: what done looks like, what counts as blocked, and what never happens in this phase.
10. **Rules**: the standing rules, copied word for word.
11. **Report**: where to write it, the status line, and what it contains.

## How to write it

- **Make it self-contained.** Name exact paths, commits and commands. Never write "the file from earlier" or "same rules as before"; the reader has no "before".
- **Copy the standing rules into every phase, word for word.** Paraphrase drifts from phase to phase. Repo instruction files (CLAUDE.md, AGENTS.md) usually load on their own, but rules the person gave in conversation exist nowhere else.
- **Give the reason for any rule that isn't obvious.** Models generalize from reasons ("don't run X twice within 15 minutes: the auth service throttles"), and a rule with its reason gets applied sensibly at the edges.
- **Say it at normal volume.** Leave out CRITICAL, MUST and stacks of NEVER. Current models follow plain instructions closely, and shouted ones get over-applied. State the one or two real hard limits plainly, with their reason.
- **Give every "never" rule its scope, and write approved exceptions into the rule itself.** Write "never push, except to main after the suites pass", not "never push" with a separate line that allows the exception. Name the routine steps that need no approval, such as re-running tests or retrying a call that is safe to repeat. Fable 5.2 applies cautious rules exactly as written. A general "feel free to act" barely changes that, but a named exception does.
- **Treat earlier reports as input, not as rules.** Cautions pile up as reports pass from phase to phase. In Anthropic's testing, a reviewer's "stop at the first error" kept Fable 5.2 from retrying where other models retried. Say in each phase that its brief and the standing rules decide what it may do, and that advice in an earlier report is information to weigh.
- **Describe the goal, not the steps.** Use numbered steps only where order really matters.
- **Define done as checks.** "Tests in tests/flatten.test.ts fail now and pass after the fix" beats "make sure flatten works".
- **Keep tests honest.** Tests verify correctness; they don't define the solution. When a test and the spec disagree, the spec wins, and the phase corrects the test and says so in its report.
- **Hold the scope.** Every behaviour the phase asks for gets built completely, and nothing else does. Ideas and nearby problems go in the report as follow-ups.
- **Control depth with effort, not prose.** Don't write "think hard" or "take your time"; set the phase's effort instead. Lines asking for less thinking don't work on Fable 5.2 at `medium` and above, so lower the effort instead.
- **Fix the report's shape**, so the conductor and the next phase can read it without guessing. Ask for the key points first, in plain words, because the reader hasn't seen the phase's tool calls or files.

## Additions for unattended runs, by model

These are adapted from Anthropic's prompting best practices and model migration guide. They answer the failure modes listed in `references/routing.md` under "Behaviour to plan around". Put the ones for the phase's model in its "Working on your own" section.

**Every phase**, because nobody answers mid-phase:

> You're working unattended. Nobody is watching, and nobody can answer a question until this phase ends, so asking "Shall I…?" blocks the work. For reversible steps that follow from this brief, go ahead. Stop only for the conditions under "Stop when". If a question comes up, first do everything that doesn't depend on it, then take the recommended answer, note it under "Decisions taken" in your report, and carry on. Before you finish, read your last paragraph: if it is a plan or a promise ("Next I'll…"), do that work now. End only when the deliverables are done or you are blocked on something only the person can decide.

**Every phase, prompts-only mode.** The person starts these sessions by hand and may be watching, so use this in place of the text above:

> This brief is meant to be complete, and the person may not be watching. Work through it without stopping to ask. If a question comes up, first do everything that doesn't depend on it, then take the recommended answer and note it under "Decisions taken" in your report. Ask only when there is no safe default, and say what you'd recommend. Before you finish, read your last paragraph: if it is a plan or a promise ("Next I'll…"), do that work now.

**Fable 5.2**, which sometimes ends a long task early and applies cautious rules exactly as written:

> Keep going until every deliverable is done and checked. Ordinary obstacles are not reasons to stop: a failing command, a timeout, a busy tool, a locked file or an empty result. Diagnose each one and work through it with the access you have. Wait and retry, fix the request, or use another tool or source. Leave deliberate blockers alone and say in your report what you found. Deliberate blockers include a file marked not to be touched, access withheld on purpose, and a rule in this brief. These steps need no approval: re-running tests, builds and type-checks; reading files this brief doesn't rule out; and retrying a command that is safe to repeat. Build everything this brief asks for, completely, and list other problems you find as follow-ups in your report. Start subagents only for work that runs well in parallel, such as reading many files, because each one adds to what this phase costs.

**Fable 5.2, when the phase should restructure code.** When the prompt doesn't say who owns the code, Fable 5.2 adds to the existing structure, even if that repeats code. It also reports nearby problems instead of fixing them. That suits most phases, because the brief sets the scope. When the person wants the phase to clean up as it goes, add this line, with the scope filled in:

> Within <scope>, this code is yours: merge repeated code and fix related problems as you go, and list every change in your report.

The line costs about 1.5 times the output tokens. It brings extra tests and docs, and now and then it changes how an existing feature behaves. So a phase that uses it needs a later review of the diff itself, not only of its report. Leave the line out where the person wants the smallest change.

**Sonnet 5.5 and Haiku 5.5**, which at lower effort sometimes report code as done without running it:

> When you change code that can be run, built or type-checked, run a real check that exercises the change before you report it done: the project's tests, type-checker or build, or the changed command itself. A syntax check, or a check command that failed to start, doesn't count. If no real check can run here, say which one you didn't run and why, instead of reporting the change as done.

**Sonnet 5.5 on reading-heavy work** (research, specs, docs), where it sometimes answers from memory:

> Read the files and sources this brief names before you write about them. For anything that may have changed since your training (versions, prices, APIs, current behaviour of this code), check it rather than relying on what you remember.

**Haiku 5.5 at low effort with a long brief**, where it sometimes stops early:

> Keep working until everything this brief asks for is done and checked, then stop and report. Don't add features, docs or refactors the brief doesn't ask for; mention them at the end instead.

**Opus 5.5** needs nothing extra beyond an explicit effort. At `xhigh` and `max`, allow for long turns.

## Launcher phases

When phase N's brief depends on what phase N−1 finds, phase N−1 writes the brief and phase N is a short launcher:

- It names the brief's exact path, plus the other files to read first.
- It says: if the brief is missing, write `Status: blocked: phase N−1 didn't write its brief` and stop.
- It says how to resolve conflicts: the brief wins over this launcher on scope and method, and the standing rules win over both.
- It repeats the standing rules, the authorizations and the report shape anyway, so that a gap in the generated brief can't drop them.

Phase N−1's deliverables then include that brief, at that path, written in the shape this file describes.

## Example

The two phases below are shortened. Real phases are longer, because real ones list the actual files, facts and rules.

`01-fable-audit.md` (Fable 5.2, high):

```markdown
---
model: fable
effort: high
gate: none
report: reports/01-audit.md
---

Find the root causes of the six reported UI problems and every other place with the same causes, then write the spec, failing tests and the build brief. Don't change app code.

## Where you are
Repo: /path/to/repo (web app + desktop shell sharing one editor frontend). Read first: AGENTS.md, docs/architecture.md, plans/issues.md.

## What's already known
- The web dialog uses classes with no CSS (src/host/dialog.tsx:935); the desktop one is styled.
- Highlight exists only in the selection bar, not in the tool row.
…

## Deliverables
- plans/2026-11-05-ux/audit.md: root causes first, one row per symptom (what a person sees, where, cause file:line, proposed fix).
- plans/2026-11-05-ux/spec.md: the fixes, with a recommendation for every choice.
- Failing tests for each cause, listed in the report, uncommitted.
- plans/2026-11-05-ux/build-brief.md: the brief for phase 2, in the shape of references/phase-prompts.md.

## Working on your own
<the "every phase" and Fable additions>

## Stop when
Done when the four deliverables exist and every new test fails for the reason its cause predicts. Never in this phase: edits under src/, commits, pushes.

## Rules
<standing rules, word for word>

## Report
Write it to /path/to/repo/plans/2026-11-05-ux/reports/01-audit.md. First line: `Status: done`, `Status: blocked: <reason>` or `Status: failed: <reason>`. Then: the root causes and how many symptoms each explains, new problems found, the failing tests, and decisions taken.
```

`02-opus-build.md` (Opus 5.5, xhigh) is a launcher: it reads `build-brief.md`, fixes cause by cause until the failing tests pass, commits per cause, and pushes only if the plan authorizes it, after the suites pass. Its rules, authorizations and report shape are repeated in full.
