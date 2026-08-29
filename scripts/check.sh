#!/usr/bin/env bash
# The plugin's only script. It runs at edit time, never in the pipeline, and
# guards the one duplication jediway accepts on purpose: the Creed lives in
# taste and is inlined in all three agents so a child needs no extra read.
# Duplication is fine; drift is not.
set -u
root="$(cd "$(dirname "$0")/.." && pwd)"
fail=0
ok()  { printf 'ok   %s\n' "$*"; }
bad() { printf 'FAIL %s\n' "$*"; fail=1; }
creed() { awk '/^## Creed$/{on=1;next} on&&/^## /{exit} on&&/^[1-8]\. /' "$1"; }

want="$(creed "$root/skills/taste/SKILL.md")"
[ "$(printf '%s\n' "$want" | wc -l)" -eq 8 ] || bad "taste: Creed is not 8 numbered lines"

for a in "$root"/agents/*.md; do
  n="$(basename "$a" .md)"
  grep -q "^name: $n$" "$a" || bad "$n: frontmatter name does not match filename"
  [ "$(creed "$a")" = "$want" ] || bad "$n: Creed has drifted from taste/SKILL.md"
  grep -q '.jediway/spec.md' "$a" || bad "$n: does not read the Spec"
done
[ $fail -eq 0 ] && ok "creed identical in all three agents"

for d in "$root"/skills/*/; do
  n="$(basename "$d")"
  grep -q "^name: $n$" "$d/SKILL.md" || bad "skill $n: frontmatter name does not match directory"
  l=$(wc -l < "$d/SKILL.md"); [ "$l" -le 90 ] || bad "skill $n: $l lines, cap is 90 (always-on cost)"
done

for r in planner implementer verifier; do
  grep -q "jediway:$r" "$root/skills/way/SKILL.md" || bad "way: does not dispatch jediway:$r"
  [ -f "$root/agents/$r.md" ] || bad "way dispatches jediway:$r but agents/$r.md is missing"
done
grep -qE 'parallel|work unit|merge point' "$root/skills/way/SKILL.md" || bad "way: lost the no-splitting rule"
ok "roles, skills, and dispatch names agree"

for m in "$root"/.claude-plugin/*.json "$root"/.codex-plugin/plugin.json; do
  python3 -c "import json,sys; json.load(open(sys.argv[1]))" "$m" 2>/dev/null || bad "invalid JSON: $m"
done
v1=$(python3 -c "import json;print(json.load(open('$root/.claude-plugin/plugin.json'))['version'])")
v2=$(python3 -c "import json;print(json.load(open('$root/.codex-plugin/plugin.json'))['version'])")
[ "$v1" = "$v2" ] || bad "manifest versions differ ($v1 vs $v2)"
ok "manifests ($v1)"

[ $fail -eq 0 ] && echo PASS || echo FAIL
exit $fail
