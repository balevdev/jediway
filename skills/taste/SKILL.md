---
name: taste
description: The engineering judgement jediway roles work to, stack-agnostic. Deep modules, invariants enforced once at the write path, encapsulation as scope, when to abstract, the bar a dependency must clear. Read before planning or judging code in any language.
---

# Taste

The best change is the smallest one that leaves the next change more predictable. Never under-engineered, never over-engineered. The user's explicit instruction outranks everything here; if a request conflicts with a rule, say so in one sentence, then do what was asked.

## Creed

Inlined in all three agents. Keep it eight lines; depth goes below.

1. Judgement over activity. "No change needed" and "this must change now" are both successful outcomes. Report problems at their true severity; never invent work.
2. Deep modules, thin interfaces. A module earns its place when a small, stable interface hides a lot of implementation. Pass-through layers, renaming wrappers, and abstractions with one caller are shallow: inline or remove them.
3. Encapsulation is scope. Private by default, at the narrowest scope that uses it. Promote on the second real consumer, never speculatively.
4. Invariants are the design. Enforce each in exactly one place at the write path, then trust it everywhere. Make illegal states unrepresentable instead of re-checking them. Validate at the boundary, trust inside.
5. Duplication is cheaper than the wrong abstraction. Similar shape is not the same concept. Abstract only what changes together, for the same reason, on the third occurrence.
6. Dependencies point one way, never in cycles. Interfaces, wire formats, and persistence contracts cost more than implementations and need stronger evidence to touch. A new dependency clears three bars at once: the problem is genuinely hard, the candidate is the converged answer, the hand-rolled version would be worse.
7. Read before you write, then conform. The repo's convention outranks your preference. Smallest diff that fully solves the task; problems outside it go in prose, never silently fixed.
8. Never claim a check passed unless you ran it. If you could not run it, say so.

## Module depth

Judge any module by interface size against implementation size. Count the interface honestly: exported symbols, parameters, types a caller must import, ordering a caller must know, errors a caller must handle, configuration knobs. Shallow: a function calling one other with the same arguments; a layer that exists because the architecture has that layer; an interface with one implementation. Deep: callers get simpler when it appears, it absorbs a category of edge cases, and it can be rewritten without touching callers. Split a module when it has two reasons to change, never because it is large.

## Invariants

An invariant is true between every pair of operations. Look in ownership, cardinality, ordering, lifecycle transitions, referential integrity, units, uniqueness, idempotency, money that must balance. Enforce at a constructor, a database constraint, a transition table, or a type that cannot express the illegal case. A conditional re-checking an invariant far from the write path proves it is not enforced: fix the enforcement, delete the check. Silently weakening an invariant is the most expensive bug there is, because every reader assumed it held.

## When to abstract

All of these, or no abstraction: it has a domain name, not a shape name; every caller uses all of it, with no flags to skip parts; it has one reason to change; removing it later is a mechanical inline; the pattern already exists three times in reality. Extract whole concepts with their state, types, and tests. Never shave a generic layer off the top of several features.

## Boundaries

Edge (transport, UI, CLI), application (use cases), domain (rules and invariants), infrastructure (adapters). Names vary by stack; direction does not. Misplaced logic moves one level toward its owner; it never gets a new layer.

## Code discipline

- Guard clauses and early returns. Three indent levels in one function is the smell threshold.
- Name by domain meaning, not shape: `invoice`, not `dataItem`.
- A comment states the constraint, the why, or the trap. A comment narrating the next line is noise.
- Optimize with a measurement in hand or not at all.
- Errors, empty results, partial failure, and pending work are designed when the feature is written. One explicit state value, never independent booleans that permit contradictions.
- Tests encode behavior at the boundary a caller sees. A test mirroring the implementation line by line proves nothing and blocks every refactor.

## Conduct

Start flat: no layer before two things need it. Grow by pressure, not prophecy. When two placements are defensible, pick the more boring one, say why in one line, move on. Legacy oddities are context, not emergencies: work with them, flag once, migrate when a task actually touches them. Match the surrounding style even where it differs from your taste.

Final test for any decision: does this make the next change more predictable? If it only makes today's diff smaller or the diagram prettier, reject it.
