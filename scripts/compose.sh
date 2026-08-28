#!/usr/bin/env bash
# compose.sh <role> <spec.md> [handoff.md]
# Prints the complete dispatch message for one child. The Creed comes from
# skills/taste/SKILL.md, the Role block from skills/<role>/SKILL.md, the Spec
# from the file you pass. Nothing is retyped by a model, so every child for a
# task receives a byte-identical Creed and Spec.
set -eu
root="$(cd "$(dirname "$0")/.." && pwd)"
usage="usage: compose.sh <scout|implementer|verifier|auditor> <spec.md> [handoff.md]"
role="${1:?$usage}"; spec="${2:?$usage}"; handoff="${3:-}"
rolefile="$root/skills/$role/SKILL.md"
[ -f "$rolefile" ] || { echo "compose: no such role: $role" >&2; exit 2; }
[ -f "$spec" ] || { echo "compose: no such spec: $spec" >&2; exit 2; }

# body of "## <heading>" up to the next "## " heading
section() { awk -v h="## $2" '$0==h{on=1;next} on&&/^## /{exit} on' "$1"; }
# contents of the first fenced block on stdin
fenced() { awk '/^```/{ if(on){exit} on=1; next } on'; }
trim() { awk 'NF{p=1} p{buf=buf $0 "\n"} END{sub(/\n+$/,"",buf); printf "%s", buf}'; }

creed="$(section "$root/skills/taste/SKILL.md" Creed | trim)"
block="$(section "$rolefile" "Role block" | fenced | trim)"
[ -n "$creed" ] || { echo "compose: taste has no Creed section" >&2; exit 2; }
[ -n "$block" ] || { echo "compose: $role has no fenced Role block" >&2; exit 2; }
specbody="$(trim < "$spec")"
hand="none"; [ -n "$handoff" ] && hand="$(trim < "$handoff")"
rolename="$(awk -F': ' '/^name: /{print $2; exit}' "$rolefile")"

while IFS= read -r line || [ -n "$line" ]; do
  case "$line" in
    '{CREED}')      printf '%s\n' "$creed" ;;
    '{SPEC}')       printf '%s\n' "$specbody" ;;
    '{HANDOFF}')    printf '%s\n' "$hand" ;;
    '{ROLE_BLOCK}') printf '%s\n' "$block" ;;
    *)              printf '%s\n' "${line//\{ROLE\}/$rolename}" ;;
  esac
done < "$root/skills/way/references/template.md"
