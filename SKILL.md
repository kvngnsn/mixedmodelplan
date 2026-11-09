---
name: mixedmodelplan
description: Plans a large piece of work as ordered phases, gives each phase to the Claude model that suits it (Fable, Opus, Sonnet or Haiku) at a set effort, writes one self-contained prompt per phase, then runs the phases in order and switches models between them without stopping to ask. Use it whenever someone wants a multi-phase or multi-pass plan, wants to split work across models (one model audits or specs, another builds), asks which model should do which part of a job, wants prompts to paste into separate terminals in order, or says "mixedmodelplan", even if they don't name the skill.
---

# mixedmodelplan

Large jobs go better in passes: one pass finds out and decides, another builds against what was decided, another checks the result. Each pass suits a different model and effort, and each starts with a fresh context, so everything a pass needs has to be written down where the next one can read it. This skill writes that plan as a folder of prompts and then runs it, phase after phase, on the right model each time.

## What you produce

```
<plans dir>/<YYYY-MM-DD>-<slug>/
  README.md              the plan: goal, phase table, gates, standing rules, how to run it
  01-<model>-<slug>.md   one self-contained prompt per phase; model and effort in its front matter
  02-<model>-<slug>.md
  reports/               each phase writes its report here; line 1 is its status
  RUN-LOG.md             what ran, when, on which model, and how it ended
```

Then, unless the person asked only for the prompts, you run it.

## Modes

- **Run** (the default): write the folder, show the phase table, start phase 1 in the same turn and carry on to the end. Between phases, post one line ("Phase 1 (Fable, high) done: spec and 9 failing tests written. Starting phase 2 on Opus.") and keep going.
- **Prompts only**: when the person will run the phases themselves (separate terminals, another machine, later), write the folder and give them the commands from its README. Leave gates at `none`, since the person reads each report before starting the next phase anyway. Use the interactive wording in `references/phase-prompts.md` in place of the unattended one, and keep all three ways to run in the README so the person can switch later.
- **Review between phases**: when the person wants to read each report before the next phase starts, set `gate: after` on every phase.
- **Resume**: "continue the plan in <folder>". Read RUN-LOG.md and reports/, then start at the first phase whose report doesn't begin `Status: done`.

## 1. Gather what every phase will need

Read the repo's instruction files (CLAUDE.md, AGENTS.md, any handoff or memory file, contributing and rules docs), `git status` and the recent log, and any existing plans or specs for this work. From those and from the conversation, collect:

- **The goal and what done looks like**, in terms someone else could check.
- **Standing rules** that every phase must obey: data the agent must not read or leak, commands it must not run, the test, commit, push and deploy procedure, style rules, speed or cost budgets. Keep the person's own words, because you will copy them into every phase.
- **Authorizations**: which outward or hard-to-reverse actions the person has approved in advance (pushing, deploying, publishing, sending messages, spending money, deleting data). Anything not approved becomes a gate.
- **What is already known**: causes found, decisions made, options ruled out, so that phases don't spend time rediscovering them. When the person has deliberately given discovery to a phase ("one model finds the causes"), pass on the reports, symptoms and where the code lives, but not your own guesses at causes, or label them clearly as unconfirmed leads. Otherwise the phase isn't independent.
- **Whether the rules' commands run here**: run the cheap ones the plan depends on (the test command, the build) once. If one fails, fix the setup when that's trivial and safe; otherwise put it at the top of the README and in the phase that needs it, so the phase doesn't find out halfway.

Ask only when the answer changes the shape of the plan or the plan needs an authorization the person hasn't given. Otherwise choose, and write the assumption into the README.

## 2. Cut the work into phases

Split by the kind of thinking, not by file or component:

1. **Find out and decide**: reproduce, trace causes, compare options, write the spec, write failing tests that define done, write the brief for the build.
2. **Build**: implement against the spec until the tests pass, in value order, committing as it goes.
3. **Check**: run the full suites, measure, review the diff with fresh eyes.
4. **Wrap up**: docs, handoff notes, the final report.

Not every job needs all four, and a big job may need several build phases. Some guidelines:

- Each phase ends with files on disk at exact paths, and the next phase reads those files. Nothing passes through memory or chat.
- Each phase has a definition of done that someone else can check: these files exist, these tests fail before and pass after, these suites pass, these numbers were measured.
- When a later phase's instructions depend on what an earlier phase finds, make the later phase a short launcher: it reads the brief the earlier phase writes at an exact path, and stops if that file is missing. Copy the standing rules into the launcher anyway.
- Fewer phases are better. Every handoff costs a fresh context that has to re-read the repo. Merge neighbouring phases that use the same model unless a gate or a natural review point sits between them. Two to five phases covers most jobs.
- A phase that writes failing tests leaves them uncommitted, because "tests pass before any commit" rules can't hold for them. The build phase commits them together with the fix.
- Open questions don't stop the run. The phase that meets one takes the recommended answer, records it under "Decisions taken" in its report, and carries on. Only a decision with no safe default becomes a gate.

## 3. Choose a model and effort for each phase

Read `references/routing.md` before choosing. It has the evidence, with sources and the date it was checked. In short:

| Phase | Default | Use instead when |
| --- | --- | --- |
| Find out and decide: audits, root causes, specs, failing tests, briefs | Fable 5.2, high | Opus 5.5, xhigh: the problem is well understood or moderate in size, the budget is tight, the organization runs zero data retention, or the work is AI-research work (kernels, model architecture) where Fable is no stronger than Opus |
| Build across many files over a long run | Opus 5.5, xhigh (high for moderate jobs) | Fable 5.2, high: the hardest long-horizon builds, or Opus has already fallen short. Sonnet 5.5, medium or high: the spec is precise and the changes are well scoped (bug fixes, a settled design, documents, slides, spreadsheets) |
| Review a risky diff | Fable 5.2, high, when Opus or Sonnet wrote the code | Opus 5.5, high or max, when Fable wrote it; Sonnet 5.5 for routine review |
| Check and measure: run suites, collect numbers | Sonnet 5.5, medium | Haiku 5.5 when the check is purely mechanical |
| Sweep and summarize: inventories, classification, log triage, summaries | Haiku 5.5, medium | Sonnet 5.5 when each item needs judgment |

Pick the cheapest model that will get the phase right the first time, because a redo costs more than the price difference. Spend more on phases whose output others build on (specs, tests) and less on phases a test suite checks anyway. Fable 5.2 costs twice as much as Opus 5.5 per token, but at `high` it often matches Opus at `max` for less per task. That is why it takes the deciding and reviewing phases, while Opus keeps the long builds. Run Fable at `high`, and use `xhigh` only where a gain is known. Don't run Sonnet at xhigh or max: Opus at high scores higher for less. Put the reason for each choice in the README's table, so the person can overrule it.

## 4. Write the plan folder

Put it in the repo's existing plans folder if there is one; otherwise use `plans/` at the repo root. Keep it out of commits unless the person wants it tracked: an ignored folder works, and so does adding the plan folder to `.git/info/exclude`, which ignores it locally without changing any tracked file. Phases that commit should stage files by name. Tell the person where the folder is and whether git sees it.

- `README.md` from `templates/plan-README.md`.
- One phase file per phase from `templates/phase.md`. Read `references/phase-prompts.md` first: it covers how to make a prompt self-contained and the additions each model needs when it runs unattended.
- `RUN-LOG.md` from `templates/RUN-LOG.md`, and an empty `reports/`.

Each phase file starts with front matter that the runner reads:

```yaml
---
model: opus     # fable | opus | sonnet | haiku
effort: xhigh   # low | medium | high | xhigh | max
gate: none      # none | after (stop for the person once this phase ends)
report: reports/01-audit.md
---
```

Below the front matter is the prompt itself, written for a reader who knows nothing except what it says. The report path in the body is the front matter's `report` made absolute; when you reread the phases, check that the two match.

Before running anything, reread each phase file as its agent will: could it start work without asking a question? Does it know where its inputs are, what to produce, where to write it, what it must not do, and when to stop?

## 5. Run

Read `references/running.md` for the details. By default the phases run in this session, as one agent per phase:

1. Start an agent with `subagent_type: "general-purpose"`, the `model` and `effort` from the phase's front matter, and the body of the phase file as its prompt. A fork can't change model, so don't use one. Invoking this skill is the person asking for these agents; don't start others.
2. Wait for its completion notification. Never guess what a running phase found.
3. Check the phase yourself: the first line of its report, each deliverable path, and any quick check the phase lists. If a check fails, send the same agent one follow-up that names the failure (SendMessage keeps its context). If it fails again, stop.
4. Add a row to RUN-LOG.md, post the one-line update, and start the next phase in the same turn.

Stop and ask the person only when:

- the phase's front matter says `gate: after`;
- a report says `Status: blocked` (a decision with no safe default, or an action nobody authorized);
- a phase has failed its checks twice;
- the next step is an outward or hard-to-reverse action that the plan doesn't authorize.

For phases that will run for hours, or when the person wants to start the plan from a terminal and leave it, use `scripts/run-phases.sh`. It runs each phase as its own headless Claude Code session on that phase's model and effort, and stops on the same conditions.

## 6. Final report

When the last phase ends, or the run stops, tell the person in plain language:

- what each phase produced, with paths and commits, and which model ran it;
- every check that ran, pass or fail;
- the decisions phases took on their own, so the person can overrule them;
- anything left undone, and why;
- if the run stopped early, where it stopped and what it needs to continue.
