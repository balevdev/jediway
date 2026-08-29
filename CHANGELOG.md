# Changelog

## 0.4.0

The plugin does one thing now: brainstorm, plan, implement, verify, in that order.

- **The main session is a pure orchestrator.** It no longer grounds the repository, runs gates, records baselines, reads diffs, or judges. Grounding moved into the new Planner agent; judging ends with the Verifier. The orchestrator's context stays small, which is where most of the speed comes from.
- **One pipeline, no modes.** The build, review, and audit branches are gone, along with the Scout and Auditor roles. A review is a Verifier run; an audit is a question you ask directly.
- **The task is never split.** Work units, parallel Implementers, and merge points are removed. However large a task is, one Implementer does all of it.
- **Children are briefed, not templated.** Each dispatch is a four-line brief: phase, the Spec as contract, at most three carried facts the next child cannot read from disk, and what it must return. Facts carry; opinions, plan text, and diffs do not.
- **No prompt composition.** `scripts/compose.sh`, the dispatch template, and the Role block indirection are deleted. Children read `.jediway/spec.md` themselves; a dispatch message is one line. The "show the composed prompt" stop is gone with it.
- **No Judge round.** The Verifier is the last word, and one retry is the limit.
- Deleted: `scripts/` (compose, gates, lint, lint-spec), the `scout`, `auditor`, `implementer`, `verifier`, `frontend`, and `backend` skills, the `way/references/` specs and template, the `build`, `review`, and `audit` commands.
- Added: `agents/planner.md` and the single `/jedi` command.
- `taste` keeps its judgement and drops to an eight-line Creed, inlined in all three agents; the Planner and Verifier invoke the skill for the depth.
- **Every role has a reading budget.** The Planner locates with grep and opens only what it will cite; the Implementer's reading list is the plan's cited paths; the Verifier reads the diff and the files it touches. Repeated repository surveys were the largest remaining token cost.
- Plans must re-check each cited `path:line` before it is written. A stale line number was the pipeline's most common failure.
- Scope arrives coarse from the orchestrator, which cannot see the repository, and the Planner narrows it to real paths and reports what it narrowed to at the checkpoint.
- The Implementer rejects a defective Spec (no Plan, or no proof-of-effect criterion with a baseline) before its first edit, replacing the deleted spec lint with a check that costs one message instead of a round.
- Added `scripts/check.sh`: an edit-time guard that fails when the Creed drifts between `taste` and the three agents, when a dispatched role has no agent file, or when the manifests disagree. It never runs inside the pipeline.

## 0.3.0

- Roles as skills, composed mechanically into child prompts from one template.
- `way` skill with build, review, and audit modes.
- Spec lint and plugin self-check scripts.
