# mixedmodelplan

A [Claude Code skill](https://docs.claude.com/en/docs/claude-code/skills) that plans a large piece of work as ordered phases and gives each phase to the Claude model that suits it: Fable, Opus, Sonnet or Haiku, each at its own effort. It writes one self-contained prompt per phase, then runs the phases in order and switches models between them on its own.

Big jobs go better in passes. One pass finds out and decides: it reproduces the bugs, traces their causes, writes the spec and the failing tests. Another builds against what was decided until those tests pass, and another checks the result. The passes suit different models, and each starts with a fresh context, so the plan writes down everything a pass needs (paths, known facts, rules, the definition of done, where to put the report) where the next pass can read it.

## What it makes

```
plans/2026-11-05-ux-fixes/
  README.md                 goal, phase table (model, effort, why), gates, standing rules, how to run
  01-fable-audit.md         phase prompt; front matter holds model, effort, gate and report path
  02-opus-build.md
  03-haiku-check.md
  reports/                  each phase's report; line 1 is "Status: done | blocked | failed"
  RUN-LOG.md                which phase ran when, on which model, at what cost, and how it ended
```

## How it switches models

- **In a Claude Code session (the default).** The session acts as conductor. It starts one agent per phase with that phase's `model` and `effort`, waits for it to finish, checks its deliverables, and starts the next phase without asking. It stops only at a gate, at a phase that reports itself blocked, after a second failed check, or before an outward action (publishing, deploying, sending) that the plan doesn't authorize.
- **From a terminal, unattended.** `scripts/run-phases.sh` runs each phase as its own headless `claude -p --model … --effort …` session. It logs which model each session actually used, stops on the same conditions, and resumes where it left off when you run it again.
- **By hand.** The plan's README has one command per phase to paste into separate terminals.

## Which model for what

`references/routing.md` has the evidence: Anthropic's launch benchmarks and cost-per-task comparisons, the Artificial Analysis index by effort, Vals AI and a code-review test. It was last checked on 2026-11-09, the day Claude Fable 5.2 came out. In short:

| Phase | Default | Instead, when |
| --- | --- | --- |
| Audits, root causes, specs, failing tests | Fable 5.2, high | Opus 5.5 at xhigh when the problem is well understood or the budget is tight |
| Long builds across many files | Opus 5.5, xhigh | Fable 5.2 at high for the hardest long-horizon builds; Sonnet 5.5 at medium or high when the spec is precise and the changes are well scoped |
| Review of risky changes | Fable 5.2, high, when Opus built it | Opus 5.5 at high or max when Fable built it; Sonnet 5.5 for routine review |
| Running checks, collecting numbers | Sonnet 5.5, medium | Haiku 5.5 when it's mechanical |
| Inventories, classification, summaries | Haiku 5.5, medium | Sonnet 5.5 when each item needs judgment |

Fable 5.2 scores above Opus 5.5 on almost every benchmark Anthropic published for both models. It is also first on the Vals AI and Artificial Analysis indexes. It costs twice as much per token, but often not more per task. At high effort it reaches Opus 5.5's best FrontierCode score for about half the cost per task. On the Vals Index it cost $17.94 per test against Opus's $24.77. Anthropic still says most coding and knowledge work should start with Opus 5.5. So the skill gives Fable the short, high-leverage phases that everything else rests on: finding causes, writing the spec and tests, and reviewing the result. Opus keeps the long builds that a test suite checks anyway. Opus at high effort also outscores Sonnet at xhigh for less money, which is why the skill doesn't push Sonnet above high.

## Install

```bash
git clone https://github.com/kvngnsn/mixedmodelplan ~/.claude/skills/mixedmodelplan
```

Restart Claude Code. The skill loads when you ask for a multi-phase plan or a split across models, or when you type `/mixedmodelplan`.

The headless runner needs `bash`, `jq` and the `claude` CLI.

## Use

- "mixedmodelplan: fix the six bugs in issues.md. Fable finds the causes and writes failing tests, Opus fixes them. You can push to main after the suites pass."
- "Plan the migration from REST to GraphQL across these three services and run it."
- "Just write the prompts. I'll run each phase in its own terminal."
- "Continue the plan in plans/2026-11-05-ux-fixes."

## Files

| Path | What it is |
| --- | --- |
| `SKILL.md` | The workflow: gather, cut into phases, route, write, run, report |
| `references/routing.md` | Which model and effort for which phase, with evidence and sources |
| `references/phase-prompts.md` | How to write a phase prompt an agent can run cold, plus per-model additions for unattended runs |
| `references/running.md` | The three ways to run, status lines, gates, permissions, costs |
| `templates/` | Plan README, phase prompt and run log templates |
| `scripts/run-phases.sh` | Headless runner |
| `evals/` | Test cases in the layout `claude plugin eval` reads |

## Sources

The prompt guidance follows Anthropic's [prompting best practices](https://platform.claude.com/docs/en/build-with-claude/prompt-engineering/claude-prompting-best-practices) and model migration guide. The model routing cites Anthropic's launch pages for [Fable 5.2](https://www.anthropic.com/claude-fable-and-mythos-5-2), [Opus 5.5](https://www.anthropic.com/claude-opus-5-5), [Sonnet 5.5](https://www.anthropic.com/claude-sonnet-5-5) and [Haiku 5.5](https://www.anthropic.com/claude-haiku-5-5), the [Choosing a model](https://platform.claude.com/docs/en/about-claude/models/choosing-a-model) guide, [Prompting Claude Fable 5.2](https://platform.claude.com/docs/en/build-with-claude/prompt-engineering/prompting-claude-fable-5-2), [Artificial Analysis](https://artificialanalysis.ai/leaderboards/models), [Vals AI](https://www.vals.ai/benchmarks) and [CodeRabbit](https://www.coderabbit.ai/blog/sonnet-5-5-model-review). Model lineups change every few months, so re-check `references/routing.md` when new models ship.

## License

[CC0 1.0](LICENSE): public domain.
