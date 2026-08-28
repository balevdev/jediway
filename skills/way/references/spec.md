# Spec format

Written once by the Master after Ground, saved to `.jediway/spec.md`, pasted verbatim into every child by `scripts/compose.sh`. A complete example is in `spec.example.md` next to this file; `scripts/lint.sh` composes every role against it.

```
## Mission
<one paragraph: what, why, what done looks like>

## Non-goals
- <what a well-meaning agent would also fix but must not>

## Domain
- <one to three verbatim lines from the matching domain skill, or the word none>

## Invariants
- <statement that must hold after the change> (enforced at <path:line or constraint name>)

## Acceptance criteria
- AC1 (proof of effect): <command>, <pass condition>. Baseline: <exit code and tail before the change>.
- AC2 (scope): git diff --name-only, every path is in Scope.
- AC3: <gate command>, exit 0. Baseline: exit 0.
- AC4: <gate already red at baseline>, no worse than baseline. Baseline: <exit code, failing tests>.

## Match
- <path:line>
  <verbatim snippet the change must resemble>

## Scope
- <allowed file or directory>
- read-only: existing tests, lockfiles

## Plan
1. [<path>:<line>] <change in one sentence>
```

Rules:

- Every acceptance criterion is a command and a pass condition. "Works correctly" and "handles errors" are not criteria. Rewrite until a shell could judge it, or drop it.
- Proof of effect carries its baseline. The Verifier proves red to green by comparing its run against that baseline, never by reverting or stashing.
- Invariants name their enforcement point. One with no enforcement point is a wish: either the Plan adds the enforcement, or the invariant leaves the Spec and the user is told.
- Scope is an allow-list. A fix that needs a path outside it is BLOCKED, and the Master decides whether to widen.
- Plan is present only in build mode, at most eight steps, each citing a line the Master read in Ground.
- Every section is present in every mode. A section with nothing to say reads `none`, never disappears, so the Verifier knows nothing was expected. A small task (one or two files, no shared interface change) may say `none` in Non-goals, Domain, Invariants, and Match; the two mandatory criteria and Scope never shrink.
- `scripts/lint-spec.sh <spec.md>` judges the shape mechanically: sections present, criteria with baselines, Plan steps cited. Run it before compose; a Spec it rejects is not dispatched.
