# Which model for which phase

Checked on 2026-11-09, the day Claude Fable 5.2 was released, against Anthropic's launch pages and docs and two independent evaluators (sources at the end). Models change every few months. If the session's model list names models newer than these, or this date is more than about three months old, check the sources again before you trust the defaults.

In Claude Code the aliases `fable`, `opus`, `sonnet` and `haiku` mean the newest model of each line. In Claude Code 2.1.321, `fable` runs `claude-fable-5-2`. This was checked on 2026-11-09 from the `modelUsage` of a headless run. An older Claude Code may still map `fable` to Fable 5.1, so check `claude --version`, or read the "Models used" column that `scripts/run-phases.sh` writes.

## Contents

- The short version
- What each model is for
- The evidence
- Effort
- Behaviour to plan around
- Sources

## The short version

- **Fable 5.2 changed the picture.** It scores above Opus 5.5 on almost every benchmark Anthropic published for both. It is also first on the two independent indexes this file uses (Vals AI and Artificial Analysis). Per token it costs twice as much as Opus 5.5 ($8 / $40 against $4 / $20). Per task it is often no more expensive. On the Vals Index it cost $17.94 per test against Opus 5.5's $24.77, and it finished in about half the time. Anthropic reports that Fable 5.2 at `high` reaches Opus 5.5's best FrontierCode score at about half the cost per task.
- **Anthropic still says to start with Opus 5.5** for most coding and knowledge work. It suggests moving up to Fable 5.2 when Opus at `xhigh` or `max` still falls short, and it calls Fable "best for the most ambitious, open-ended technical work".
- **So Fable 5.2 at `high` is the default for find-out-and-decide phases**: audits, root causes, specs, failing tests and briefs. It is also the default for reviewing a risky change that Opus built. Every later phase depends on these phases, which are short compared with a build, so the best model is worth its price here. Fable is also a different model from the builder, so the builder's blind spots aren't the reviewer's.
- **Opus 5.5 stays the default builder.** It is Anthropic's recommended starting point, it costs half as much per token, and the phase's tests check its work anyway. Move a build to Fable 5.2 at `high` when the work is the hardest kind of long-horizon work, or when Opus has already fallen short on it. When Fable writes the code, Opus reviews it.
- **Sonnet 5.5 is for well-scoped work at medium or high effort**: bug fixes with a known cause, building to a precise spec or a settled design, documents, slides and spreadsheets, and routine review. Above `high` it costs more than Opus at `high` and scores lower.
- **Haiku 5.5 is for narrow, high-volume work that can be checked**: inventories, classification, summaries, log triage, collecting numbers, and fast sub-tasks inside a bigger phase. It isn't for complex agentic coding.
- **Effort changes results as much as the choice of model does.** Set it on every phase. Run Fable 5.2 at `high`, and raise it to `xhigh` only where you know it gains.

## What each model is for

**Claude Fable 5.2** (`fable`, $8 / $40 per million input / output tokens; released 2026-11-09). Anthropic calls it "best for the most ambitious, open-ended technical work". Its model guide names "agent sessions that run for hours, multistep deep research, analysis carried through to a finished document, spreadsheet, or deck". Anthropic says it generates output up to 30% faster than Fable 5.1, and that testers found it communicates more clearly. On the independent indexes it is first on Vals and first on Artificial Analysis. On Vals it is first on Finance Agent, Excel Modeling, ProofBench, Vibe Code Bench, ProgramBench and BioMysteryBench, and tied first with Opus 5.5 on Terminal-Bench 4.0. Anthropic also says early testers did well with it as the planner and orchestrator for other models.

It is weaker in a few places:
- Opus 5.5 leads on Vals's SWE-bench Multimodal (70.2% against 62.3%) and keeps a small lead in Elo on AA-Briefcase, a knowledge-work evaluation.
- On Vals's legal and tax work it ranks well down: 20th of 37 on the Legal Index, 19th of 93 on Legal Research Bench and 27th of 84 on Tax Agent Bench.
- Anthropic deliberately held back its AI-research skills in training, such as accelerator kernel optimization and LLM architecture work. In those areas it performs at about Opus 5.5's level, so it isn't worth its price there.
- Its safeguards block most cybersecurity tasks. Claude Mythos 5.2, the same model without those blocks, is available only to organizations Anthropic has verified.
- It needs 30-day data retention. An organization on zero data retention can't use it unless Anthropic has authorized that, so route its phases to Opus 5.5 instead.

Good Fable phases:
- an audit or root-cause hunt across a large, unfamiliar codebase where nobody knows the cause yet;
- a spec, the failing tests and the build brief for a hard or open-ended problem;
- multi-hour research that reads and reconciles many sources;
- an independent review of a large or risky change that Opus made;
- a build that Opus at `xhigh` has already failed to finish.

**Claude Fable 5.1** is still served, but the `fable` alias now runs 5.2. Fable 5.2 costs less per token ($8 / $40 against $10 / $50) and scores higher on every benchmark Anthropic published for both models. Pin 5.1 only if a plan has to reproduce an earlier run.

**Claude Opus 5.5** (`opus`, $4 / $20). Anthropic's model guide says "Most workloads start with Claude Opus 5.5", for "multihour autonomous coding agents, large-scale refactoring, complex systems engineering, vision-heavy workflows, computer use". On Vals it is first on SWE-bench Multimodal, MedScribe and SAGE, and tied first with Fable 5.2 on Terminal-Bench 4.0. In a small independent code-review test it caught the most planted bugs: 8 of 13 at standard effort and 10 of 13 at max, against Sonnet 5.5's 6 of 13. That test ran before Fable 5.2 was released.

Good Opus phases: long builds against a spec; audits and specs on problems that are well understood or of moderate size, or when the budget is tight; review of a change that Fable made; research and writing.

**Claude Sonnet 5.5** (`sonnet`, $2 / $10). Anthropic: "strongest at well-scoped everyday tasks, fixing bugs, and creating polished documents, slides, and spreadsheets", "a faster, lower-cost complement to Claude Opus 5.5", and "Opus 5.5 remains clearly stronger at complex, open-ended work requiring sustained judgment." It complements Opus best "at lower effort settings, where it costs less per task." It is second on the Vals Index, half a point behind Fable 5.2 and ahead of Opus 5.5, and first on Vals's Code Migration. CodeRabbit would use it to review every pull request, but not the high-risk ones.

Good Sonnet phases: implementing a settled design or a precise spec; bug fixes whose cause is known; docs, slides and spreadsheets; routine review; running a test suite and fixing what fails.

**Claude Haiku 5.5** (`haiku`, $0.10 / $0.50 for prompts up to 100K tokens; $0.50 / $2.50 above that). Anthropic: "designed for high-volume, cost-sensitive tasks", "quick and repetitive workloads (like summaries, compactions, database queries, and classification requests)", and "It pairs well with Opus 5.5 and Sonnet 5.5 as a subagent on coding work." Also: "Sonnet 5.5 and Opus 5.5 remain better choices for complex agentic coding tasks."

Good Haiku phases: listing every place a pattern occurs; classifying a backlog; summarizing logs or transcripts; checking that files, links or numbers exist and match; collecting the measurements a script prints. Keep its prompts under 100K tokens, where the price is five times lower.

## The evidence

### Anthropic's Fable 5.2 launch benchmarks

These are vendor-run. Some scores come from Mythos 5.2 or from runs without safeguards, so read them as a ranking, not as exact gaps.

| Benchmark (what it tests) | Fable 5.2 | Fable 5.1 | Opus 5.5 |
| --- | --- | --- | --- |
| FrontierCode 2.0 (hard agentic coding; xhigh) | 49.1% | 32.4% | 45.5% |
| FrontierSWE v2 (agentic coding) | 69.9% | 56.3% | 62.3% |
| AutomationBench (business workflows) | 51.4% | 31.4% | 42.5% |
| Terminal-Bench-Science 0.1 (agentic science) | 74.6% | 52.6% | 58.7% |
| WANDR, relaxed (agentic search) | 82.1% | 68.7% | 72.3% |
| OSWorld 2.1, partial (computer use) | 89.3% | 83.5% | 87.2% |
| AA-Briefcase v1.1 (knowledge work), rubric / Elo | 66.1% / 1785 | 61.5% / 1669 | 61.2% / 1800 |
| Remote Labor Index (knowledge work; high) | 41.3% | 17.9% | 21.3% |
| Humanity's Last Exam, with tools (reasoning) | 74.2% | 65.6% | 67.7% |
| Chartography, no tools (reading charts) | 73.4% | 44.8% | 64.4% |

Anthropic's comparisons of cost per task, at matching quality:
- FrontierCode 2.0: Fable 5.2 at `high` (about 45.3%) roughly matches Opus 5.5's best (45.5%) at about half the cost per task.
- WANDR: Fable 5.2 at `medium` matches Opus 5.5's best at about 40% of the cost per task.
- Humanity's Last Exam: Fable 5.2 at `low` matches Opus 5.5's best at less than a tenth of the cost per task.
- Chartography: Fable 5.2 at `medium` (66.4%) beats Opus 5.5 at `max` (64.4%) at less than a tenth of the cost per task.

### Anthropic's Opus, Sonnet and Haiku 5.5 launch benchmarks

These come from the September and October 2026 launch pages. They are the evidence for where Sonnet and Haiku fit. Most were run at max effort.

| Benchmark (what it tests) | Opus 5.5 | Sonnet 5.5 | Haiku 5.5 |
| --- | --- | --- | --- |
| Terminal-Bench 4.0 (agentic coding in a terminal) | 66.4% (xhigh) | 70.6% | 39.2% |
| CursorBench 4.0 (agentic coding in an editor) | 57.8% | 55.5% | not published |
| FrontierCode v1.1 Main (hard coding) | 54.4% | 52.1% (xhigh) | 46.4% |
| GDPval-AA v2.1 (knowledge work, Elo) | 1846 | 1844 | 1620 |
| Humanity's Last Exam, with tools (reasoning) | 67.7% | 64.5% | 57.4% |
| OSWorld 2.1, partial (computer use) | 81.8% | 80.1% | 72.4% on the offline subset, where Sonnet scored 83.9% |

Sonnet 5.5 scored lower on FrontierCode at max than at xhigh. At max it split the work across subagents, then timed out or edited out of scope.

### Artificial Analysis: Intelligence Index by effort

This is an independent run of nine evaluations (index v5.0.1). The table shows index score / cost per task in USD / minutes per task. Artificial Analysis hadn't yet published cost or time for Fable 5.2 on 2026-11-09.

| Effort | Fable 5.2 | Opus 5.5 | Sonnet 5.5 | Haiku 5.5 |
| --- | --- | --- | --- | --- |
| low | 54 / n/a / n/a | 35 / $0.98 / 3.0 | 26 / $0.51 / 2.6 | 19 / $0.04 / 2.1 |
| medium | 56 / n/a / n/a | 48 / $2.45 / 7.1 | 31 / $0.78 / 3.7 | 25 / $0.09 / 4.1 |
| high | 62 / n/a / n/a | 52 / $3.46 / 9.6 | 42 / $1.64 / 7.1 | 30 / $0.16 / 6.5 |
| xhigh | 62 / n/a / n/a | 57 / $6.05 / 16.3 | 50 / $4.09 / 15.3 | 35 / $0.25 / 9.7 |
| max | 65 / n/a / n/a | 59 / $10.04 / 25.2 | 55 / $10.02 / 31.4 | 36 / $0.41 / 15.8 |

What this table shows:
- Fable 5.2 at `low` (54) scores above Opus 5.5 at `high` (52). Fable at `high` (62) scores above Opus at `max` (59). On the 2026-11-05 check, Fable 5.1 scored 50 at `xhigh`.
- Fable 5.2 scores the same at `xhigh` as at `high`. At `max` it gains 3 points, but it used 275M output tokens to run the index, against a median of 77.7M for reasoning models.
- Opus at `high` (52, $3.46) still beats Sonnet at `xhigh` (50, $4.09). Sonnet only nears Opus at `max`, where it costs the same and takes longer.
- At `max`, the first answer token took 3 to 5.5 minutes on every model checked on 2026-11-05, Haiku included.

### Vals AI (as of 2026-11-09)

| Model | Vals Index | Rank | Cost per test | Latency |
| --- | --- | --- | --- | --- |
| Fable 5.2 | 71.31% | 1 of 36 | $17.94 | 43 min 42 s |
| Sonnet 5.5 | 70.85% | 2 | not checked | not checked |
| Gemini 4 Carbon | 70.45% | 3 | not checked | not checked |
| Opus 5.5 | 70.14% | 4 | $24.77 | 84 min 31 s |

- The Vals Index covers finance, coding, legal and tax agent tasks.
- Firsts:
  - Fable 5.2: Finance Agent v2.1, Excel Modeling, ProofBench, Vibe Code Bench, ProgramBench (19.0% against Opus's 18.5%), BioMysteryBench, and Terminal-Bench 4.0 (tied with Opus 5.5 at 65.15%).
  - Opus 5.5: SWE-bench Multimodal (70.2% against Fable 5.2's 62.3%), MedScribe and SAGE.
  - Sonnet 5.5: Code Migration.
  - Fable 5.1: Immigration Bench.
- Haiku 5.5, as of 2026-11-05: 58.73% on the Vals Index (15th of 34), third on Vibe Code Bench, 36.36% on Terminal-Bench 4.0, and weak on SRE Bench.

### CodeRabbit code review (13 PRs with planted bugs; vendor-run, small set)

| Model | Bugs caught | Precision | Cost per review |
| --- | --- | --- | --- |
| Opus 5.5, max | 10 / 13 | 52.0% | not given |
| Opus 5.5, standard | 8 / 13 | 66.7% | not given |
| Sonnet 5.5, thinking on | 6 / 13 | 41.2% | $0.47 |

CodeRabbit's conclusion: "If missing a bug on a high-risk change is the expensive failure, Opus 5.5 is worth its extra tokens." On one build task, Sonnet 5.5 took 29 minutes against Opus's 45, with "close to identical" results. No independent code-review test of Fable 5.2 had been published by 2026-11-09. The choice of Fable 5.2 for review rests on Anthropic's benchmarks, on Vals, and on its being a different model from the builder.

## Effort

- **Defaults.** On the API, Fable 5.2 and Sonnet 5.5 default to `high`, and Opus 5.5 and Haiku 5.5 default to `medium`. Claude Code and the Claude apps run Fable 5.2 and Sonnet 5.5 at `medium`. Set effort explicitly on every phase rather than relying on a default.
- **Fable 5.2: start at `high`.** Anthropic says "most of the gain in capability is already present at `high`". Above `high`, gains are "uneven and depend on the task", and on Artificial Analysis `xhigh` gained nothing. Use `xhigh` only for the hardest long-running coding and agentic phases where you have measured a gain. Keep `max` for the rare phase where time and tokens don't matter, such as open-ended maths or science. Anthropic found that Fable 5.2 at `low` scores close to Fable 5.1 at higher efforts, so `low` or `medium` suits a well-specified Fable sub-task. But Fable stops early more often at those levels (see below).
- **Others.** Above `high`, cost and time per task roughly double with each step (see the Artificial Analysis table). Use Opus at `xhigh` for long builds and hard audits. Use `max` only where correctness matters more than time and cost. Sonnet stays at `medium` or `high`.
- **Effort is the depth control.** Don't write "think hard" or "take your time" into prompts; raise the effort instead. Don't write "answer directly without deliberating" either: at `medium` and above, Fable 5.2 thinks anyway. Lower the effort instead.

## Behaviour to plan around

These come from Anthropic's prompting guides and migration guides. `references/phase-prompts.md` turns them into prompt additions.

- **Fable 5.2**
  - On long, multistep tasks it sometimes ends a turn before the work is done. It ends with a list of what remains, an offer to continue, or a stop at an ordinary obstacle such as a timeout. This happens more often at `low` and `medium` effort.
  - It applies approval rules and cautions exactly as written. Cautions also pile up wherever context carries over: notes, memory, instruction files, and messages between agents. In one Anthropic test, a reviewer agent's "stop at the first error" kept Fable 5.2 from retrying in about a third of tries, where Fable 5.1 and Opus 5.5 retried. In a similar test, a general instruction to "act more freely" changed nothing. What worked was naming the steps that need no approval, and writing the exception into the rule itself.
  - It responds to what the prompt says about who owns the code. When the prompt doesn't say, it adds to the existing structure, even if that repeats code, and it reports nearby problems instead of fixing them. When told "this codebase is yours", it merges repeated code and makes related fixes. It then uses about 1.5 times the output tokens, adds tests and docs nobody asked for, and changes how an existing feature behaves in one try in six to ten.
  - It starts subagents readily when the prompt invites it. At `xhigh` and `max`, it uses them to review its own work. Subagents can be a large part of what a session costs.
  - It follows style rules closely. A hard limit on sentence length makes its prose choppy.
  - It can run many tool calls in a row with little visible text. That matters only when someone is watching.
- **Opus 5.5** runs long turns at `xhigh` and `max`, so allow for them. Its default effort is `medium`, one level below the previous Opus.
- **Sonnet 5.5**, mostly at `low` effort, sometimes reports code as done without running a check that exercises it. On knowledge work it sometimes answers from memory where reading a file or searching would serve better.
- **Haiku 5.5**, at `low` effort with a long prompt, sometimes stops early and hands the task back. At `low` and `medium` it sometimes skips verification.

## Sources

- Anthropic, Introducing Claude Fable 5.2 and Claude Mythos 5.2 (2026-11-09): https://www.anthropic.com/claude-fable-and-mythos-5-2
- Anthropic, What's new in Claude Fable 5.2: https://platform.claude.com/docs/en/models/fable-5-2/whats-new-fable-5-2
- Anthropic, Prompting Claude Fable 5.2: https://platform.claude.com/docs/en/build-with-claude/prompt-engineering/prompting-claude-fable-5-2
- Anthropic, Effort: https://platform.claude.com/docs/en/build-with-claude/effort
- Anthropic, Choosing a model: https://platform.claude.com/docs/en/about-claude/models/choosing-a-model
- Anthropic, Introducing Claude Opus 5.5 (2026-09-22): https://www.anthropic.com/claude-opus-5-5
- Anthropic, Introducing Claude Sonnet 5.5 (2026-09-28): https://www.anthropic.com/claude-sonnet-5-5
- Anthropic, Introducing Claude Haiku 5.5 (2026-10-07): https://www.anthropic.com/claude-haiku-5-5
- Anthropic, Prompting best practices: https://platform.claude.com/docs/en/build-with-claude/prompt-engineering/claude-prompting-best-practices
- Artificial Analysis leaderboard: https://artificialanalysis.ai/leaderboards/models and https://artificialanalysis.ai/models/claude-fable-5-2
- Vals AI: https://www.vals.ai/benchmarks, https://www.vals.ai/models/anthropic_claude-fable-5-2, https://www.vals.ai/models/anthropic_claude-opus-5-5 and https://www.vals.ai/models/anthropic_claude-haiku-5-5
- CodeRabbit, Sonnet 5.5 code review benchmarks (2026-09-28): https://www.coderabbit.ai/blog/sonnet-5-5-model-review
