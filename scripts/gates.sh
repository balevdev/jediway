#!/usr/bin/env bash
# gates.sh [repo-root]
# Prints candidate build/test/lint/typecheck commands from the repo's own
# manifests, plus the CI files to confirm them against. Candidates only:
# the Master confirms each one against CI before it becomes a gate.
set -u
root="${1:-.}"; cd "$root" || exit 2
pm=npm; [ -f pnpm-lock.yaml ] && pm=pnpm; [ -f yarn.lock ] && pm=yarn; [ -f bun.lockb ] || [ -f bun.lock ] && pm=bun
if [ -f package.json ]; then
  echo "# package.json scripts ($pm)"
  python3 - "$pm" << 'PY' 2>/dev/null || grep -E '"(build|test|lint|typecheck|check|type-check|tsc|e2e)[^"]*"\s*:' package.json
import json, sys, re
pm = sys.argv[1]
for k in json.load(open("package.json")).get("scripts", {}):
    if re.search(r"build|test|lint|typecheck|type-check|check|tsc|e2e", k):
        print(f"{pm} run {k}")
PY
fi
if [ -f Makefile ]; then
  echo "# Makefile targets"
  grep -E '^(build|test|lint|check|typecheck|vet|fmt|ci)[a-zA-Z_-]*:' Makefile | sed 's/:.*//; s/^/make /'
fi
if [ -f pyproject.toml ] || [ -f setup.cfg ] || [ -f tox.ini ]; then
  echo "# python (present if listed in the project's dev dependencies)"
  for t in pytest ruff mypy pyright black flake8; do grep -qs "$t" pyproject.toml setup.cfg tox.ini requirements*.txt 2>/dev/null && echo "$t"; done
fi
[ -f go.mod ] && printf '# go\ngo build ./...\ngo vet ./...\ngo test ./...\n'
[ -f Cargo.toml ] && printf '# rust\ncargo build\ncargo test\ncargo clippy -- -D warnings\n'
[ -f Gemfile ] && printf '# ruby\nbundle exec rspec\nbundle exec rubocop\n'
[ -f composer.json ] && printf '# php\ncomposer test\ncomposer lint\n'
echo "# CI files to confirm against"
ls .github/workflows/*.yml .github/workflows/*.yaml .gitlab-ci.yml Jenkinsfile .circleci/config.yml bitbucket-pipelines.yml 2>/dev/null || echo "(none found)"
