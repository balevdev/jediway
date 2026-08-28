# jediway

One way of working for coding agents. Taste lives in skills. Roles are skills. One workflow composes them, mechanically, into every prompt a child agent ever sees.

Works in Claude Code and Codex, on any language and any stack, from a one-file fix to a repository audit. It chooses simplicity by default and creates an abstraction only when evidence demands one.

## The idea

Separated, a taste document is advice nobody follows and an orchestration prompt is a process with no opinions. jediway binds them with three moving parts and one script:

- **taste** carries the judgement: deep modules, thin interfaces, invariants enforced once at the write path, encapsulation as scope, abstraction on the third occurrence, three bars for a dependency. Its ten-line Creed is what travels.
- **frontend** and **backend** add only what is specific to each side and feed the Spec one to three lines. They never become a role.
- **way** is the Master in the main session: ground the repo in facts, write a Spec a shell can judge, write the Plan, compose each child, dispatch, judge. The Master never writes code.
- **scripts/compose.sh** assembles every child prompt from the Creed, the Spec file, the handoff, and the role's Role block. No model retypes anything, so every child for a task gets a byte-identical Creed and Spec and only its own role.

Roles: **implementer** (writes inside Scope, proves with the acceptance criteria), **verifier** (reproduces every criterion, reads the real diff, returns Approved and Rejected findings), **auditor** (Staff+ architecture audit), **scout** (grounds and plans only when the repo is too large for the Master to read in one pass).

## Layout

```
jediway/
  .claude-plugin/plugin.json        Claude Code manifest
  .claude-plugin/marketplace.json   Claude Code single-plugin marketplace
  .codex-plugin/plugin.json         Codex manifest
  skills/
    way/           the workflow: modes, Ground, Spec and Plan, Compose, Dispatch, Judge
      references/template.md        the one child template, raw, four slots
      references/spec.md            Spec format and rules
      references/spec.example.md    a complete Spec; lint composes every role against it
    taste/         universal judgement; section "Creed" is pasted into every child
    frontend/      UI placement ladder, taxonomy, rendering, styling, accessibility
    backend/       schema as deepest module, logic ladder, transactions, errors, testing
    implementer/   role block + notes for the Master
    verifier/      role block + notes for the Master
    auditor/       role block + notes for the Master
    scout/         role block + notes for the Master
  agents/          Claude Code subagent wrappers; read-only roles cannot edit
  commands/        /jediway:build, /jediway:review, /jediway:audit
  scripts/
    compose.sh     <role> <spec.md> [handoff.md]  prints the dispatch message
    gates.sh       [repo]  prints candidate build/test/lint commands and CI files
    lint-spec.sh   <spec.md>  judges a Spec's shape before compose
    lint.sh        the plugin's own acceptance criteria
```

Plain Markdown and two small shell scripts. No runtime, no MCP server, no hooks.

## Install

### Claude Code

```
claude --plugin-dir /path/to/jediway            # one session
claude plugin marketplace add balevdev/jediway   # every session
claude plugin install jediway@jediway
cp -r jediway ~/.claude/skills/jediway           # or: skills-dir plugin, no install step
claude plugin validate ./jediway --strict        # before publishing
```

### Codex

Codex reads `.codex-plugin/plugin.json` and the same `skills/`. This repo carries its own `.agents/plugins/marketplace.json`, so any Codex user installs it straight from git:

```
codex plugin marketplace add balevdev/jediway
/plugin install jediway@jediway        # inside Codex, then /reload-plugins
```

For a local checkout instead, register it in `~/.agents/plugins/marketplace.json` (personal) or `<repo>/.agents/plugins/marketplace.json` (team) and install from the Plugins directory:

```json
{
  "name": "personal",
  "interface": { "displayName": "Personal" },
  "plugins": [{
    "name": "jediway",
    "source": { "source": "local", "path": "./plugins/jediway" },
    "policy": { "installation": "AVAILABLE", "authentication": "ON_INSTALL" },
    "category": "Developer Tools"
  }]
}
```

With the personal marketplace, `./plugins/jediway` resolves to `~/plugins/jediway`. Without the plugin wrapper, copy `skills/*` into `~/.codex/skills/` and the `scripts/` folder next to them; `compose.sh` locates skills relative to itself.

One honest limit: Claude Code locks read-only roles out of edit tools through the `agents/` wrappers; Codex has no equivalent, so read-only there is convention. Run those roles in a read-only sandbox when the guarantee matters.

## Use

```
/jediway:build add rate limiting to POST /login, 5 attempts per minute per IP
/jediway:review the diff on branch feat/rate-limit against main
/jediway:audit src/billing, answer: is the invoice state machine enforced once?
```

Codex: `$way build: <task>`, `$way review: <subject>`, `$way audit: <path>`. The skill also triggers on its own for any request to build, fix, refactor, migrate, harden, review, or audit code. Say "inline" for the one-line edits where the workflow would be ceremony.

### A build run

1. Mode, one line.
2. Ground: `gates.sh` candidates confirmed against CI, baseline results, matching snippets with `path:line`, blast radius, invariants with enforcement points, domain lines.
3. `.jediway/spec.md`: Mission, Non-goals, Domain, Invariants, Acceptance criteria (each a command, a pass condition, and a baseline), Match, Scope, Plan. Proof of effect (red before, green after) and Scope (`git diff --name-only`) are always criteria. `lint-spec.sh` judges the shape; then the Master argues the strongest case the criteria miss the Mission, and fixes what survives.
4. `compose.sh implementer .jediway/spec.md`, shown, then sent. The Implementer confirms the proof-of-effect check is red before fixing, runs the fastest gate after each step, runs every criterion at the end, returns the full diff.
5. `compose.sh verifier .jediway/spec.md .jediway/handoff.md`, shown, then sent. The Verifier runs Scope and proof of effect first, reads the whole diff before the slow gates, checks Match and Invariants, and argues against each of its own findings.
6. Judgement: the Master re-runs the two decisive criteria, reads the diff, re-runs everything only if the two reports disagree, adjudicates Approved and Rejected, and decides ACCEPT, RE-BRIEF, RE-PLAN, or ESCALATE. Three rounds maximum.

### The rules that do the work

- A child's report is a claim until reproduced; reproduction is targeted, not repeated.
- Retries are fresh children with the corrected Spec and the failing evidence in `handoff.md`.
- Existing tests and lockfiles are read-only for children. Adding a test that encodes a criterion is expected; weakening one is a High finding.
- Invariants name their enforcement point: once, at the write path, trusted everywhere else.
- The Handoff section is five lines; `.jediway/handoff.md` carries the full previous report (evidence, diff, Handoff). `.jediway/` is the only state; a fresh session resumes from it.
- A small task keeps the whole chain and shrinks only the Spec: sections read `none`, the Plan is a step or two, only the gates that bear on the change are baselined.

## Extend

**A domain**: `skills/<domain>/SKILL.md` with a trigger-rich description under 70 words, a "Directive zero" listing what to discover in the repo first, and the domain's placement ladder. Universal rules stay in `taste`. The Master picks it up by description. Candidates: `data`, `infra`, `mobile`.

**A role**: `skills/<role>/SKILL.md` with one fenced `## Role block` (compose.sh extracts it) and a `## Master notes` section. No other instruction source for children. Add a mode row in `way` if the chain changes and an `agents/<role>.md` wrapper with `disallowedTools` if read-only.

**The taste**: edit the deep sections freely; edit the Creed rarely, because it is pasted into every child prompt and its stability is what makes child behavior predictable.

**Keep it honest**: `scripts/lint.sh` is the plugin's acceptance criteria: no em or en dashes, frontmatter names match directories, descriptions under 70 words, skills under 120 lines, exactly one Creed, exactly one Role block per role and no second instruction source, compose succeeds for every role against the example Spec with no unfilled slots, the example Spec passes `lint-spec.sh`, read-only agents cannot edit, manifests agree on version, commands compose mechanically. Run it before every commit.

## Why it is built this way

- Composition is a script, not an instruction. "Paste verbatim" is where a model's paraphrase enters; a script has no opinion.
- The Master writes the Plan. It already read the files in Ground; a Planner child would re-read them and lose the context.
- Verification is isolated, implementation is isolated, planning is not. Isolation buys fresh eyes and a clean main context; those two roles are where it pays.
- The Judge reproduces the two criteria that decide the task and trusts agreeing evidence for the rest. Three full gate runs per round was cost without information.
- One rule lives in one file. Duplicated rules drift into contradictions; the lint checks the two that matter most.
- The Spec is the one artifact a model writes freely, so it is the one artifact a script judges. lint-spec holds the Spec to the bar the Spec holds code to, and the Master then argues against its own Spec the way the Verifier argues against its own findings.
- Build, review, and audit are one pipeline cut at different points. The pipeline also scales down: a small task shrinks the Spec, never the chain.

## License

MIT
