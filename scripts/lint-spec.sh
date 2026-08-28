#!/usr/bin/env bash
# lint-spec.sh <spec.md>
# Mechanical validation of a Spec before compose: the workflow's own bar,
# "a shell could judge it", applied to its central artifact. Build rules
# apply when a Plan section is present. Exit 0 when the Spec is well formed.
set -u
spec="${1:?usage: lint-spec.sh <spec.md>}"
[ -f "$spec" ] || { echo "lint-spec: no such file: $spec" >&2; exit 2; }
fail=0
ok()  { printf 'ok   %s\n' "$*"; }
bad() { printf 'FAIL %s\n' "$*"; fail=1; }
section() { awk -v h="## $1" '$0==h{on=1;next} on&&/^## /{exit} on&&NF' "$spec"; }
has() { grep -q "^## $1\$" "$spec"; }

# Every section present and non-empty in every mode; nothing to say reads "none".
for s in Mission Non-goals Domain Invariants "Acceptance criteria" Match Scope; do
  if has "$s" && [ -n "$(section "$s")" ]; then :; else bad "missing or empty section: $s"; fi
done
[ $fail -eq 0 ] && ok "sections present and non-empty"

# Criteria: at least one, and each carries a Baseline except the scope criterion.
acs=$(section "Acceptance criteria" | grep -c '^- AC')
[ "$acs" -ge 1 ] || bad "no criterion of the form '- ACn ...'"
if section "Acceptance criteria" | grep '^- AC' | grep -v 'git diff --name-only' | grep -vq 'Baseline:'; then
  bad "a criterion has no Baseline (only the scope criterion may omit it)"
else ok "criteria carry baselines"; fi

# Build mode: Plan present means proof of effect, scope criterion, cited steps.
if has Plan; then
  section "Acceptance criteria" | grep '^- AC' | grep -i 'proof of effect' | grep -q 'Baseline:' \
    || bad "build spec: no proof-of-effect criterion with a Baseline"
  section "Acceptance criteria" | grep -q 'git diff --name-only' \
    || bad "build spec: no scope criterion (git diff --name-only)"
  steps=$(section Plan | grep -c '^[0-9]')
  { [ "$steps" -ge 1 ] && [ "$steps" -le 8 ]; } || bad "Plan has $steps steps; the cap is 8"
  if section Plan | grep '^[0-9]' | grep -vq '^[0-9][0-9]*\. \[[^]]*:[0-9][0-9]*\]'; then
    bad "a Plan step is not of the form 'N. [path:line] change in one sentence'"
  else ok "Plan: $steps cited steps"; fi
fi

[ $fail -eq 0 ] && echo PASS || echo FAIL
exit $fail
