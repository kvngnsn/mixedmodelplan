# Running a plan

There are three ways to run a plan folder. All three read the same phase files and write the same reports and log.

| Way | Use it when | Model switching |
| --- | --- | --- |
| In this session, one agent per phase (the default) | The person is in a Claude Code session and phases take minutes to an hour or two | The Agent tool's `model` and `effort` parameters |
| `scripts/run-phases.sh`, one headless session per phase | Phases run for hours, the person wants to start the plan from a terminal and leave it, or each phase needs a full context window of its own | `claude -p --model … --effort …` for each phase |
| Prompts only | The person will paste each phase into a terminal themselves | The person starts each terminal on the phase's model |

## In this session

You are the conductor. Your model is whatever the session runs. You only plan and check, so any model will do, though a strong one writes better plans. Anthropic reports that early testers did well with Fable 5.2 as the planner and orchestrator for other models.

For each phase, in order:

1. **Inputs.** If an earlier phase was supposed to write files this one reads, check that they exist. If one is missing, the earlier phase isn't really done: treat that as a failed check on the earlier phase.
2. **Start the agent.**
   - `subagent_type`: `"general-purpose"`, which has every tool. Don't use `"fork"`: a fork always runs on your own model.
   - `model`: the front matter's `model` (`fable`, `opus`, `sonnet` or `haiku`).
   - `effort`: the front matter's `effort`. This skill is the instruction that asks for a specific effort, so passing it is correct.
   - `description`: "Phase 01 (opus): audit", or similar.
   - `prompt`: the body of the phase file (everything after the front matter), unchanged. The phase file is the source of truth; don't paraphrase or shorten it.
3. **Wait.** The agent runs in the background and a notification arrives when it finishes. Don't poll, and never predict or summarize a phase's results before that notification arrives. If the person asks meanwhile, say which phase is running and on which model.
4. **Check.** Read the report's first line. Check that every deliverable path exists and that commits the phase claims are in `git log`. Run any quick check the phase lists, such as a single test command. Skip anything that takes long or touches the outside world; the phase itself ran those.
5. **On a failed check**, send the same agent one message with SendMessage that names exactly what failed ("reports/02-build.md says done, but tests/flatten.test.ts still fails: <output>"). It keeps its context. Check again when it finishes. If it fails a second time, stop.
6. **Log and continue.** Add a row to RUN-LOG.md. Post one line to the person: what finished, on which model, and what starts next. Then start the next phase in the same turn, without asking.

Agents in this session share its permission mode. If the session asks the person to approve tool calls, phases will wait on those approvals, so tell the person before starting a long run.

## Headless runner

```bash
# from the directory the phases work in (usually the repo root)
<skill dir>/scripts/run-phases.sh <plan folder> [--from N] [--only N] [--dry-run] [-- <extra claude flags>]
```

- Each phase runs as `claude -p --model <model> --effort <effort> --output-format json`, with the phase body on standard input and the session named "mmp <phase>". Its JSON result goes to `logs/<phase>.json` and its errors to `logs/<phase>.err`.
- After each phase the runner reads the report's first line, records which models the session actually used (from the JSON's `modelUsage`) and its list-price cost, and adds a row to RUN-LOG.md.
- It stops when `claude` exits with an error, when the report doesn't begin `Status: done`, or after a phase with `gate: after`. Run it again to resume: phases whose report already says done are skipped.
- `--dry-run` prints each command without running anything. Use it to check the front matter.
- **Permissions.** A headless session can't show approval prompts, so a tool call that would need one is refused. Pass a permission mode you'd trust unattended in this repo, plus a budget if you want one, after `--`. For example: `-- --permission-mode acceptEdits --allowedTools "Bash(npm *)" "Bash(git *)" --max-budget-usd 40`. Don't reach for `--dangerously-skip-permissions` outside a sandbox.
- Each headless phase gets a full context window with automatic compaction, and can start agents of its own if its prompt allows it.

## Prompts only

The plan's README lists one command per phase. Each opens an interactive session on the phase's model and effort, with the phase body as the first message:

```bash
cd <repo>
claude --model fable --effort high "$(sed '1,/^---$/d' <plan folder>/01-fable-audit.md)"
```

The `sed` drops the front matter. The person runs the phases in order and reads each report before starting the next. Nobody fills in RUN-LOG.md in this mode unless the person asks a session to; the reports are the record.

## Status lines

Every report starts with exactly one of these lines:

```
Status: done
Status: blocked: <one-line reason>
Status: failed: <one-line reason>
```

- `done`: every deliverable is written and every check the phase owns has passed.
- `blocked`: the phase needs something only the person can give, such as a decision with no safe default, an authorization, a credential, or a broken environment it can't fix.
- `failed`: the phase ran but couldn't meet its definition of done.

The conductor and the runner treat anything else, including a missing report, as not done.

## Gates and authorizations

The README's "Authorized" list says which outward or hard-to-reverse actions the person approved before the run, such as "push to main after the suites pass" or "deploy to staging". Every phase prompt repeats that list. Anything not on it, such as publishing a package, sending email, a production deploy, deleting data, a force-push, spending money or changing accounts, is a gate. The phase stops with `Status: blocked` and names the action, and the run waits for the person.

## Costs

Before a long run, tell the person in one line which models and efforts the plan uses, and point them at the cost-per-task figures in `references/routing.md`. A plan with Fable or Opus phases at `xhigh` or `max` is an expensive run. Fable 5.2 at `high` is usually the better buy: on Anthropic's figures it often matches Opus 5.5 at `max` for about half the cost per task. Fable phases that start many subagents can cost much more than their own tokens suggest. A headless run can be capped with `--max-budget-usd`.
