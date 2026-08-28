---
description: jediway audit mode (Ground, Spec, Auditor, Judge), a Staff+ architecture audit of a repo or subsystem; changes nothing
argument-hint: <repo root or subsystem path, optional questions>
---

Load the jediway `way` skill and run it in audit mode.

Subject: $ARGUMENTS

State the mode, then Ground; gates and baseline are mandatory even here. Write `.jediway/spec.md` with the user's questions in the Mission, Scope as the code under audit, Invariants as Ground found them, and acceptance criteria as the gates with baselines; no Plan. Compose the Auditor with `scripts/compose.sh` and show the prompt before sending. Finish by adjudicating the Auditor's approved and rejected lists, naming anything you overturn and why, and stating the verdict.
