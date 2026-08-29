# jediway

One way of working for coding agents, and only one.

The main session brainstorms the task with you, writes a short spec, and dispatches three children in a fixed order:

```
you  ->  brainstorm  ->  spec  ->  Planner  ->  [your go]  ->  Implementer  ->  Verifier  ->  verdict
```

The orchestrator never reads the repository, never verifies, and never splits the task. That is what makes it fast: the long context lives in the children, which are discarded, while the main session holds a four-section spec and three short reports. Its only work between children is briefing the next one, in four lines:

```
Phase: implementer
Contract: read .jediway/spec.md at the repo root. It is your brief; nothing else was said to you.
Carry: AC1 is `pytest -k rate_limit`, exit 1 at baseline.
Return: Result plus one line per criterion with its exit code.
```

Carry facts, never instructions, and never what the child can read from disk itself.

## Install

Claude Code:

```
/plugin marketplace add balevdev/jediway
/plugin install jediway
```

## Use

```
/jedi add rate limiting to the login endpoint
```

Or just describe the work; the `way` skill triggers on any request to build, fix, refactor, migrate, harden, or test code.

## What each role does

| Role | Access | Job |
|---|---|---|
| Orchestrator (main session) | no repo access | brainstorm, spec, dispatch, report |
| Planner | read, plus `.jediway/spec.md` | confirm the gates, record the baseline, append acceptance criteria and a cited plan |
| Implementer | write inside Scope | execute the whole plan, run every criterion, write `.jediway/report.md` |
| Verifier | read-only | re-run the criteria, read the real diff, return Approved and Rejected findings |

The Verifier is the last word. The orchestrator relays its verdict and does not re-check it.

## Rules the pipeline is built on

- **One unit of work.** However large the task, it goes down the pipeline once. No parallel children, no work units, no merge points.
- **One stop.** After the plan, you approve. Nothing else interrupts the run.
- **One retry.** A failed verification buys one fresh Implementer and one fresh Verifier. A retry is always a new child; failing evidence never goes back to the agent that produced it.
- **Proof of effect.** Every build carries one check that is red before the change and green after, with its baseline recorded. A change that turns nothing red to green is a no-op however clean the diff.
- **Scope is an allow-list.** `git diff --name-only` is an acceptance criterion. A fix outside Scope is BLOCKED, and you decide whether to widen it.
- **Every role has a reading budget.** The Planner locates with grep and reads only what it will cite. The Implementer's reading list is the plan's cited paths. The Verifier reads the diff and what it touches. Nobody surveys the repository twice, and no diff or transcript is ever pasted between children.

## Taste

`skills/taste/SKILL.md` holds the engineering judgement: deep modules and thin interfaces, invariants enforced once at the write path, encapsulation as scope, when to abstract, the bar a dependency must clear. Its eight-line Creed is inlined in all three agents, so every child works to the same standard; the Planner and the Verifier invoke the skill itself for the depth. Edit it and the pipeline's taste changes.

## State

`.jediway/spec.md`, `.jediway/report.md`, and `.jediway/review.md` are a run's entire state. A fresh session resumes from those three files. Delete the folder when you are done, or keep it as the trail.

## Layout

```
skills/way/SKILL.md       the pipeline
skills/taste/SKILL.md     the judgement
agents/planner.md         grounds and plans
agents/implementer.md     executes and proves
agents/verifier.md        reproduces and judges
commands/jedi.md          the entry point
scripts/check.sh          edit-time guard, never runs in the pipeline
```

The Creed is inlined in all three agents on purpose: a child that must read another file to learn how to work is a child that can fail to. `scripts/check.sh` is what makes that duplication safe, by failing when the three copies drift from `taste`.

## The one thing nobody checks

The Verifier has the last word and the orchestrator relays it unchanged. That is deliberate: a second judge in the main session doubled the cost of every run to catch a case the read-only Verifier rarely produces. The safeguard is that its verdict lists every command with its exit code, so re-running one line is yours to do when a change matters enough.

MIT.
