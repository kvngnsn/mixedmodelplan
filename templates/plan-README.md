# <Plan title>

<One paragraph: the goal, why it matters, and what done looks like.>

Written <YYYY-MM-DD> for <repo absolute path>. <Assumptions you made instead of asking, one line each.>

## Phases

Run in order. Each phase reads what the ones before it wrote.

| # | File | Model | Effort | Why this model | What it does | Ends with | Gate |
| --- | --- | --- | --- | --- | --- | --- | --- |
| 1 | `01-<model>-<slug>.md` | Fable 5.1 | high | <reason, from references/routing.md> | <one line> | <deliverables, report> | none |
| 2 | `02-<model>-<slug>.md` | Opus 5.5 | xhigh | <reason> | <one line> | <deliverables, report> | none |

## Authorized

The outward or hard-to-reverse actions the person approved before the run. Anything not listed is a gate: the phase stops with `Status: blocked`.

- <e.g. push to main after the suites pass, then check the production deploy>

## Standing rules

Copied word for word into every phase.

- <rule, in the person's words>

## Questions for the person

Each one has a recommendation. Phases build the recommendation unless the person answers first.

- <question>: recommended <answer>, because <reason>.

## How to run

In a Claude Code session: "run the plan in <this folder>" (mixedmodelplan runs it phase by phase and switches models on its own).

From a terminal, unattended, from the repo root:

```bash
<skill dir>/scripts/run-phases.sh <this folder> -- --permission-mode acceptEdits
```

By hand, one terminal per phase, in order:

```bash
cd <repo>
claude --model fable --effort high "$(sed '1,/^---$/d' <this folder>/01-<model>-<slug>.md)"
claude --model opus --effort xhigh "$(sed '1,/^---$/d' <this folder>/02-<model>-<slug>.md)"
```

Each phase writes its report to `reports/` (line 1 is its status), and RUN-LOG.md records every run.
