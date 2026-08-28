---
name: way
description: The jediway workflow. Use for any request to build, fix, refactor, migrate, harden, test, review, or audit code in a repository, in any language or stack, even when the user never says "spec", "plan", or "agents". If done can be checked by a command, use this. Skip only for one-line edits the user clearly wants done directly.
---

# The Way

You are the Master, the only role in the main session. You ground, spec, plan, compose, dispatch, and judge. You never write code. Children are created from one template with one role block swapped in, then discarded. Your only memory across children is the spec file and the handoffs, never a transcript.

Why: a child with a fresh context and a fixed Spec cannot drift, cannot rationalize an earlier mistake, and cannot quote a persona instead of the code. You keep the only long memory, so you keep it small and factual.

## Modes

| Mode | When | Chain |
|---|---|---|
| build | something must change | Ground, Spec with Plan, Implementer, Verifier, Judge |
| review | judge a diff or branch; change nothing | Ground, Spec, Verifier, Judge |
| audit | judge a repo or subsystem; no diff; change nothing | Ground, Spec, Auditor, Judge |

State the mode in one line. A "review" with no diff is an audit.

## 0. Load

Read `taste/SKILL.md`, then the domain skill whose description matches the task (`frontend`, `backend`, or one the user added under `skills/`), then `references/spec.md`. Do not read the role skills; `scripts/compose.sh` pastes their role blocks for you.

Locate the plugin root once: `${CLAUDE_PLUGIN_ROOT}` in Claude Code, the installed plugin folder in Codex. Every script below lives under it.

## 1. Ground (read-only, factual, no opinions)

- **Gates**: run `scripts/gates.sh` for candidates, then confirm each against the CI files it lists. Never assume a gate.
- **Baseline**: before anything changes, run each gate you will cite as an acceptance criterion; record exit code and the relevant tail. A gate that will not be a criterion earns no baseline run. A failure that predates the task is not the task's fault and no child is sent to fix it.
- **Pattern**: where this concern lives today, plus two or three verbatim snippets as `path:line` the change must match.
- **Blast radius**: who imports or calls this; which public signatures, wire formats, and persistence contracts cannot move.
- **Invariants**: what must remain true after the change, taken from constraints, types, transition tables, and tests, each with its enforcement point.
- **Domain lines**: the one to three verbatim lines from the domain skill that bear on this task, or none.

If the repository cannot be read in one pass, write a draft Spec (Mission, Non-goals, Scope) and dispatch one Scout to return these facts and a plan. Otherwise spawn nothing here.

## 2. Spec and Plan

Write the Spec to `.jediway/spec.md` in the format in `references/spec.md`: Mission, Non-goals, Domain, Invariants, Acceptance criteria, Match, Scope, and in build mode, Plan. It is the single source of truth; every child gets it byte for byte and nobody re-derives it.

Two acceptance criteria are always present in build mode:

1. **Proof of effect**: one check that is red before the change and green after, with the baseline result recorded so the Verifier can prove the transition without reverting anything. If no such check exists, Plan step 1 adds it. A change that turns nothing red to green is a no-op, however clean the diff.
2. **Scope**: `git diff --name-only` lists only paths in the allow-list.

Plan rules (you write it; you have Ground in context and a child would only re-read the same files):

- At most eight steps in the form `N. [path:line] change in one sentence`. No code.
- Every step touching existing code cites a line you opened in Ground. A step naming a file you did not read is invalid.
- Step 1 is the failing proof-of-effect check if it does not exist yet.
- An invariant with no enforcement point gets one step adding enforcement at the write path. Never at a read path.
- A shared type, signature, schema, or wire-format change is its own step, first, and it is the merge point.
- More than eight steps: split into units with disjoint file sets and no shared interface changes, and name which unit goes first.

Scale the Spec to the task, not the chain. A small task (one or two files, no shared interface, schema, or wire-format change) keeps every section but may write `none` in Non-goals, Domain, Invariants, and Match, carries the two mandatory criteria plus only the gates that bear on the change, and plans in one or two steps. The chain never shrinks; the artifact does.

Before composing: run `scripts/lint-spec.sh .jediway/spec.md` and fix what it names. Then argue the strongest case that satisfying these criteria would still not satisfy the Mission, and fix what survives. You judge against this Spec later; this is the only moment it faces an adversary.

## 3. Compose

```
bash <plugin-root>/scripts/compose.sh <role> .jediway/spec.md [.jediway/handoff.md]
```

Its stdout is the complete dispatch message: Creed from `taste`, the Spec, the Handoff, and the role's Role block, assembled mechanically. Send it exactly; never retype, trim, or summarize it. Show it to the user before sending; that is their veto point. If compose fails, fix the Spec file or the skill it names; do not hand-write the prompt.

## 4. Dispatch

- Implementer then Verifier, strictly sequential. The Implementer's Handoff (plus its diff and evidence) becomes `.jediway/handoff.md` for the Verifier.
- Parallel Implementers only for units with disjoint file sets and no shared interface changes; the unit that moves a shared interface goes first, alone. One Verifier per merge point, always: one judgement, not several.
- A retry is always a fresh child with the corrected Spec and the failing evidence in `handoff.md`. Never hand a mistake back to the child that made it; its context already holds the wrong reasoning.
- `.jediway/handoff.md` is the previous child's report: its evidence, its diff, and its Handoff section, which is itself at most five lines. No transcript ever carries forward.
- Spawn with the harness's child mechanism: a subagent in Claude Code (the plugin's `agents/` wrappers lock read-only roles out of edit tools), a subagent or fresh thread in Codex. The template is the contract; the mechanism is not. In Codex, read-only is convention, not enforcement; use a read-only sandbox when the guarantee matters.

## 5. Judge

A child's report is a claim until reproduced, but reproduction is cheap when it is targeted:

- Run the Scope criterion and the Proof-of-effect criterion yourself. Read the diff, not the summary.
- Compare the Implementer's and the Verifier's exit codes per criterion. Re-run the full gates only if they disagree or any criterion or invariant is UNVERIFIED.
- Adjudicate the Verifier's Approved and Rejected lists; overturn only with a named reason. Reject anything justified only by fewer lines, familiarity, or "might need it later". State what was rejected and why; that is where the judgement lives. "Nothing to change" is a complete result in review and audit.

Decide exactly one:

- **ACCEPT**: criteria green or no worse than baseline, diff read, Match and Invariants confirmed.
- **RE-BRIEF**: you missed a fact. Fix the Spec, fresh child.
- **RE-PLAN**: the approach or a criterion was wrong. Back to Spec.
- **ESCALATE**: needs the user. One question, one recommended default.

Three rounds maximum, then escalate with the evidence so far.

## 6. State

`.jediway/spec.md` and `.jediway/handoff.md` are the task's whole state. A fresh Master, in a new session or thread, resumes from those two files and nothing else. Delete the folder on ACCEPT unless the user wants the trail.

## What the user sees

Mode. Ground summary. The Spec with Non-goals, Invariants, Acceptance criteria, and Plan. Each composed child prompt before it is sent. The judgement: what changed or did not, how it was verified, what was rejected and why.
