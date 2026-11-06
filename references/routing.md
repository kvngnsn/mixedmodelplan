# Which model for which phase

Checked on 2026-11-05 against Anthropic's launch pages and docs and three independent evaluators (sources at the end). Models change every few months. If the session's model list names models newer than these, or this date is more than about three months old, check the sources again before you trust the defaults. In Claude Code the aliases `fable`, `opus`, `sonnet` and `haiku` always mean the newest model of each line.

## Contents

- The short version
- What each model is for
- The evidence
- Effort
- Behaviour to plan around
- Sources

## The short version

- **Opus 5.5 is the default for nearly every phase.** Anthropic's own advice is "Most workloads start with Claude Opus 5.5." It scores above Fable 5.1 on every benchmark Anthropic published for both, and costs 40% as much per token.
- **Fable 5.1 is the escalation and the second opinion.** Use it for the hardest open-ended problems, for research or agent sessions that run for hours, when Opus at xhigh or max still falls short, and when you want a different model to audit or spec work that Opus will build (or has built), so that the builder's blind spots aren't also the reviewer's.
- **Sonnet 5.5 is for well-scoped work at medium or high effort**: bug fixes with a known cause, building to a precise spec or a design Opus has set, documents, slides and spreadsheets, routine review. It's close to Opus on those tasks for about half the price per task. Above high effort it loses its price advantage.
- **Haiku 5.5 is for narrow, high-volume, checkable work**: inventories, classification, summaries, log triage, collecting numbers, and fast sub-tasks inside a bigger phase. It isn't for complex agentic coding.
- **Effort moves results as much as model choice does.** Set it on every phase.

## What each model is for

**Claude Fable 5.1** (`fable`, $10 / $50 per million input / output tokens). Anthropic calls it "the highest available capability" and suggests it for "agent sessions that run for hours, multistep deep research", and as the next step "if xhigh or max evals still fall short" on Opus 5.5. Anthropic's Opus 5.5 page says the two are closer than their benchmarks suggest and that Opus 5.5 "performs at the level of Claude Fable 5.1 on most work". Independent leaderboards don't put Fable ahead of Opus 5.5 overall. It ranks first on some domain tasks on Vals (Excel modelling, immigration law) and second on others (MedScribe, ProgramBench).

Good Fable phases:
- an audit or root-cause hunt across a large, unfamiliar codebase where nobody knows the cause yet;
- a spec or design for a hard, open-ended problem, especially one Opus will then build;
- multi-hour research that reads and reconciles many sources;
- an independent review of a large change Opus made.

**Claude Opus 5.5** (`opus`, $4 / $20). Anthropic: "Complex agentic coding and enterprise work", "multihour autonomous coding agents, large-scale refactoring, computer use, vision-heavy workflows", and "Opus 5.5 leads in agentic coding, computer use, and knowledge work". Ranked first on Vals for Terminal-Bench 4.0, ProgramBench, Finance Agent and SAGE. In a small independent code-review test it caught the most planted bugs (8 of 13 at standard effort, 10 of 13 at max, against Sonnet 5.5's 6 of 13).

Good Opus phases: almost all of them. Long builds against a spec, audits and specs when Fable isn't needed, test writing, review of risky changes, research, writing.

**Claude Sonnet 5.5** (`sonnet`, $2 / $10). Anthropic: "strongest at well-scoped everyday tasks, fixing bugs, and creating polished documents, slides, and spreadsheets", "a faster, lower-cost complement to Claude Opus 5.5", and "Opus 5.5 remains clearly stronger at complex, open-ended work requiring sustained judgment." It complements Opus best "at lower effort settings, where it costs less per task." It tops the Vals Index by less than a point over Opus 5.5, and it scored highest of all on Anthropic's Terminal-Bench 4.0 run, though Vals's own run of the same benchmark puts Opus first. CodeRabbit would use it for review of every pull request but not for the high-risk ones.

Good Sonnet phases: implementing a settled design or a precise spec; bug fixes whose cause is known; docs, slides, spreadsheets; routine review; running and fixing a test suite.

**Claude Haiku 5.5** (`haiku`, $0.10 / $0.50 for prompts up to 100K tokens; $0.50 / $2.50 above that). Anthropic: "designed for high-volume, cost-sensitive tasks", "quick and repetitive workloads (like summaries, compactions, database queries, and classification requests)", and "It pairs well with Opus 5.5 and Sonnet 5.5 as a subagent on coding work." Also: "Sonnet 5.5 and Opus 5.5 remain better choices for complex agentic coding tasks."

Good Haiku phases: listing every place a pattern occurs; classifying a backlog; summarizing logs or transcripts; checking that files, links or numbers exist and match; collecting measurements a script prints. Keep its prompts under 100K tokens, where the price is five times lower.

## The evidence

### Anthropic's published benchmarks

These are vendor-run, mostly at max effort, and Anthropic's pages compare against different rivals and settings, so read them as a ranking rather than exact gaps.

| Benchmark (what it tests) | Fable 5.1 | Opus 5.5 | Sonnet 5.5 | Haiku 5.5 |
| --- | --- | --- | --- | --- |
| Terminal-Bench 4.0 (agentic coding in a terminal) | 55.8% | 66.4% (xhigh) | 70.6% | 39.2% |
| CursorBench 4.0 (agentic coding in an editor) | 51.8% | 57.8% | 55.5% | not published |
| FrontierCode v1.1 Main (hard coding) | 50.3% | 54.4% | 52.1% (xhigh) | 46.4% |
| GDPval-AA v2.1 (knowledge work, Elo) | 1735 | 1846 | 1844 | 1620 |
| Humanity's Last Exam, with tools (reasoning) | 65.6% | 67.7% | 64.5% | 57.4% |
| OSWorld 2.1, partial (computer use) | 80.7% | 81.8% | 80.1% | 72.4% on the offline subset, where Sonnet scored 83.9% |
| Terminal-Bench-Science 0.1 (agentic science) | 52.6% | 58.7% | not published | not published |

Anthropic's caveats: "the gap between Opus 5.5 and Claude Fable 5.1 is narrower than these scores suggest", and "benchmark margins have become a less reliable guide to real-world differences". Sonnet 5.5 scored lower on FrontierCode at max than at xhigh, because at max it spread the work across subagents and timed out or edited out of scope. In one customer migration (C to Rust), Opus 5.5 finished in 9.5 hours against Fable 5.1's 12, at 51% less cost.

### Artificial Analysis: Intelligence Index v5 by effort

This is an independent run of nine evaluations. The table shows index score / cost per task in USD / minutes per task.

| Effort | Fable 5.1 | Opus 5.5 | Sonnet 5.5 | Haiku 5.5 |
| --- | --- | --- | --- | --- |
| low | 39 / $4.47 / 7.3 | 35 / $0.98 / 3.0 | 26 / $0.51 / 2.6 | 19 / $0.04 / 2.2 |
| medium | 43 / $5.56 / 9.4 | 48 / $2.45 / 6.8 | 31 / $0.78 / 3.7 | 25 / $0.09 / 4.1 |
| high | 47 / $7.54 / 12.6 | 52 / $3.46 / 9.3 | 42 / $1.64 / 7.0 | 30 / $0.16 / 6.7 |
| xhigh | 50 / $10.85 / 18.7 | 57 / $6.05 / 16.1 | 50 / $4.09 / 14.9 | 35 / $0.25 / 9.7 |
| max | 49 / $12.99 / 22.4 | 59 / $10.04 / 27.1 | 55 / $10.02 / 31.1 | 36 / $0.41 / 16.0 |

What this table shows:
- Opus at high (52, $3.46) beats Sonnet at xhigh (50, $4.09). Sonnet only nears Opus at max, where it costs the same and takes longer.
- Fable 5.1 doesn't improve from xhigh to max on this index, and costs the most at every level.
- At max, the first answer token takes 3 to 5.5 minutes on every model, Haiku included.

### Vals AI (as of 2026-11-05)

- Vals Index (finance, coding, legal and tax agent tasks): Sonnet 5.5 70.85%, then Gemini 4 Carbon 70.45%, then Opus 5.5 70.18%.
- Firsts: Opus 5.5 on Terminal-Bench 4.0, ProgramBench, Finance Agent v2.1, SAGE and MedScribe; Sonnet 5.5 on Vibe Code Bench and ProofBench; Fable 5.1 on Excel Modeling and Immigration Bench.
- Haiku 5.5: 58.73% on the Vals Index (15th of 34), third on Vibe Code Bench, 36.36% on Terminal-Bench 4.0, weak on SRE Bench.

### CodeRabbit code review (13 PRs with planted bugs; vendor-run, small set)

| Model | Bugs caught | Precision | Cost per review |
| --- | --- | --- | --- |
| Opus 5.5, max | 10 / 13 | 52.0% | not given |
| Opus 5.5, standard | 8 / 13 | 66.7% | not given |
| Sonnet 5.5, thinking on | 6 / 13 | 41.2% | $0.47 |

Their conclusion: "If missing a bug on a high-risk change is the expensive failure, Opus 5.5 is worth its extra tokens." On one build task Sonnet 5.5 took 29 minutes against Opus's 45, with "close to identical" results.

## Effort

- Anthropic's defaults: Fable 5.1 and Sonnet 5.5 default to `high` on the API, and Opus 5.5 and Haiku 5.5 to `medium`. Claude Code and the Claude apps run Sonnet 5.5 at `medium`. Set effort explicitly on every phase rather than relying on a default.
- Above `high`, cost and time per task roughly double with each step (see the Artificial Analysis table). Use `xhigh` for long builds and hard audits, and `max` only where correctness matters more than time and cost, such as reviewing a risky change.
- For long written deliverables (a full spec, a big rewrite), prefer `high` on Fable 5.1. At `xhigh` and `max` it may draft the whole thing in its thinking and then write it again.
- Effort is the depth control. Don't write "think hard" or "take your time" into prompts; raise the effort instead.

## Behaviour to plan around

These come from Anthropic's model migration guide and prompting guide. `references/phase-prompts.md` turns them into prompt additions.

- **Fable 5.1** can run for very long stretches, but when nobody is watching it sometimes stops at describing the next step or asks permission for a step its brief already covers. It tends to add extras nobody asked for (fixing nearby code, extra tests, scratch checks committed as tests), sometimes rewrites a whole file where a small edit would do, and says less between tool calls.
- **Opus 5.5** runs long turns at `xhigh` and `max`, so allow for them. Its default effort is `medium`, one level below the previous Opus.
- **Sonnet 5.5**, mostly at `low` effort, sometimes reports code as done without running a check that exercises it. On knowledge work it sometimes answers from memory where reading a file or searching would serve better.
- **Haiku 5.5**, at `low` effort with a long prompt, sometimes stops early and hands the task back. At `low` and `medium` it sometimes skips verification.

## Sources

- Anthropic, Introducing Claude Opus 5.5 (2026-09-22): https://www.anthropic.com/claude-opus-5-5
- Anthropic, Introducing Claude Sonnet 5.5 (2026-09-28): https://www.anthropic.com/claude-sonnet-5-5
- Anthropic, Introducing Claude Haiku 5.5 (2026-10-07): https://www.anthropic.com/claude-haiku-5-5
- Anthropic, Choosing a model: https://platform.claude.com/docs/en/about-claude/models/choosing-a-model
- Anthropic, Prompting best practices: https://platform.claude.com/docs/en/build-with-claude/prompt-engineering/claude-prompting-best-practices
- Artificial Analysis leaderboard: https://artificialanalysis.ai/leaderboards/models
- Vals AI benchmarks: https://www.vals.ai/benchmarks and https://www.vals.ai/models/anthropic_claude-haiku-5-5
- CodeRabbit, Sonnet 5.5 code review benchmarks (2026-09-28): https://www.coderabbit.ai/blog/sonnet-5-5-model-review
- VentureBeat on Opus 5.5 against Fable 5.1 (2026-09-22): https://venturebeat.com/technology/anthropic-releases-claude-opus-5-5-beating-fable-5-1-on-key-agentic-benchmarks-at-60-cheaper-api-price
