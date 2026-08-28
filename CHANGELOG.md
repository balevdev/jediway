# Changelog

## 0.3.0

- lint-spec.sh: the Spec is judged by a shell before compose, the same bar the Spec applies to code. lint.sh runs it against the example Spec.
- The Master argues the strongest case its own Spec misses the Mission before composing; the Spec now has an adversary.
- The Spec scales down: a small task writes `none` in Non-goals, Domain, Invariants, and Match and plans in a step or two. The chain never shrinks.
- Ground baselines only the gates cited as acceptance criteria.
- Verifier: review mode (no proof-of-effect criterion) asks whether the diff carries a check that would fail without it; fresh installs only when the diff touches dependency or build manifests.
- Auditor: a Scope too large for one child splits into units, one Auditor each.
- Honest about Codex: read-only roles are convention there, not enforcement; the README and way say so.
- Handoff naming fixed: the Handoff section is five lines, `.jediway/handoff.md` carries the full previous report.
- taste: comments state what the code cannot show; optimize with a measurement in hand or not at all.

## 0.2.0

- compose.sh: child prompts are assembled mechanically from taste's Creed, the Spec file, the handoff, and the role's fenced Role block. No model retypes any of it.
- gates.sh: candidate gate commands and CI files for Ground.
- Planner child removed; the Master writes the Plan into the Spec with the Ground context it already has. Scout added for repos too large to ground in one pass.
- Judge reproduces the Scope and proof-of-effect criteria and reads the diff; full re-run only on disagreement or UNVERIFIED.
- Roles carry a single fenced Role block plus Master notes; no second instruction source for children.
- Creed reduced to ten lines. Placement ladders, discovery questions, and error-state rules each live in exactly one skill.
- Descriptions capped at 70 words, skills at 120 lines; lint composes every role against spec.example.md as proof of effect.

## 0.1.0

First cut.
