---
description: jediway review mode (Ground, Spec, Verifier, Judge) for a diff or branch; changes nothing
argument-hint: <diff, branch, or PR to judge>
---

Load the jediway `way` skill and run it in review mode.

Subject: $ARGUMENTS

State the mode, then Ground. Write `.jediway/spec.md` with Scope as exactly the code under judgement and acceptance criteria as the repo's gates plus the invariants Ground found; no Plan. Compose the Verifier with `scripts/compose.sh` and show the prompt before sending. Finish with the judgement including the Rejected findings. "Nothing to change" is a valid result. If there is no diff, run audit mode instead.
