#!/usr/bin/env bash
# jediway self-check: the plugin's own acceptance criteria. Exit 0 when all pass.
set -u
root="$(cd "$(dirname "$0")/.." && pwd)"
fail=0
ok()  { printf 'ok   %s\n' "$*"; }
bad() { printf 'FAIL %s\n' "$*"; fail=1; }
dash=$'\xe2\x80\x94\|\xe2\x80\x93'

# 1. No em or en dashes in any text file.
if grep -rIn --include='*.md' --include='*.json' --include='*.sh' "$dash" "$root" >/dev/null; then
  bad "dashes"; grep -rIn --include='*.md' --include='*.json' --include='*.sh' "$dash" "$root"
else ok "no em or en dashes"; fi

# 2. Skills: frontmatter name matches directory, description present and short, body capped.
for d in "$root"/skills/*/; do
  n="$(basename "$d")"; f="$d/SKILL.md"
  [ -f "$f" ] || { bad "$n: missing SKILL.md"; continue; }
  head -1 "$f" | grep -q '^---$' || bad "$n: no frontmatter"
  grep -q "^name: $n$" "$f" || bad "$n: frontmatter name != directory"
  dw=$(awk '/^description:/{print NF-1; exit}' "$f")
  [ "${dw:-0}" -ge 15 ] || bad "$n: description too short"
  [ "${dw:-0}" -le 70 ] || bad "$n: description is $dw words, cap is 70 (always-on cost)"
  lines=$(wc -l < "$f"); [ "$lines" -le 120 ] || bad "$n: $lines lines, cap is 120"
done
ok "skills frontmatter and size"

# 3. One Creed, in taste only; every role has exactly one fenced Role block and no other instruction source for children.
[ "$(grep -l '^## Creed$' "$root"/skills/*/SKILL.md | wc -l)" -eq 1 ] || bad "Creed must be defined exactly once, in taste"
grep -q '^## Creed$' "$root/skills/taste/SKILL.md" || bad "taste: no Creed section"
for r in scout implementer verifier auditor; do
  f="$root/skills/$r/SKILL.md"
  [ "$(grep -c '^## Role block$' "$f")" -eq 1 ] || bad "$r: needs exactly one Role block section"
  grep -qi 'craft' "$f" && bad "$r: children get the Role block only; no Craft sections"
done
ok "single sources: creed and role blocks"

# 4. Compose every role against the example spec; output must be complete with no unfilled slots.
ex="$root/skills/way/references/spec.example.md"
[ -f "$ex" ] || bad "missing spec.example.md"
for r in scout implementer verifier auditor; do
  out="$("$root/scripts/compose.sh" "$r" "$ex" 2>&1)" || bad "compose $r: $out"
  printf '%s' "$out" | grep -q '{[A-Z_]*}' && bad "compose $r: unfilled slot"
  printf '%s' "$out" | grep -q '^1\. Judgement over activity' || bad "compose $r: creed missing"
  printf '%s' "$out" | grep -q '^## Mission' || bad "compose $r: spec missing"
  printf '%s' "$out" | grep -q '^Result: PASS | PARTIAL | BLOCKED' || bad "compose $r: report shape missing"
done
ok "compose produces complete prompts for every role"

# 4b. The spec lint accepts the example Spec it composes from.
if "$root/scripts/lint-spec.sh" "$ex" >/dev/null 2>&1; then ok "lint-spec accepts spec.example.md"
else bad "lint-spec rejects spec.example.md"; fi

# 5. Agents: each wraps an existing role; read-only roles are locked out of edit tools.
for a in "$root"/agents/*.md; do
  n="$(basename "$a" .md)"
  [ -d "$root/skills/$n" ] || bad "agent $n: no matching skill"
  case $n in scout|verifier|auditor) grep -q '^disallowedTools: .*Edit' "$a" || bad "agent $n: read-only role can edit";; esac
done
ok "agents"

# 6. Manifests parse and agree on version.
for m in "$root/.claude-plugin/plugin.json" "$root/.codex-plugin/plugin.json" "$root/.claude-plugin/marketplace.json"; do
  python3 -c "import json,sys; json.load(open(sys.argv[1]))" "$m" 2>/dev/null || bad "manifest: $m is not valid JSON"
done
v1=$(python3 -c "import json; print(json.load(open('$root/.claude-plugin/plugin.json'))['version'])")
v2=$(python3 -c "import json; print(json.load(open('$root/.codex-plugin/plugin.json'))['version'])")
[ "$v1" = "$v2" ] || bad "manifest: versions differ ($v1 vs $v2)"
ok "manifests ($v1)"

# 7. Commands load the way skill, pass arguments, and compose mechanically.
for c in "$root"/commands/*.md; do
  b="$(basename "$c")"
  grep -q '`way`' "$c" || bad "command $b: does not load the way skill"
  grep -q '\$ARGUMENTS' "$c" || bad "command $b: no \$ARGUMENTS"
  grep -q 'compose.sh' "$c" || bad "command $b: does not compose mechanically"
done
ok "commands"

[ $fail -eq 0 ] && echo PASS || echo FAIL
exit $fail
