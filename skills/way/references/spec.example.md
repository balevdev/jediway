## Mission
Adding a cart line with quantity <= 0 must fail at the write path with a domain error, so that no cart can ever persist a non-positive quantity. Done means the existing add-line flow rejects the value before persistence and the rest of the cart behaves as today.

## Non-goals
- Do not touch quantity updates on existing lines.
- Do not change the HTTP status mapping module.
- Do not reformat cart/service.ts.

## Domain
- Invariants that concern data go in the database first; the domain type mirrors the constraint so the application fails fast, but the constraint is what makes the invariant true.

## Invariants
- cart_lines.quantity > 0 for every persisted row (enforced at db/migrations/0012_cart_lines.sql CHECK constraint; this change mirrors it at src/cart/line.ts createLine so the constraint is never the first line of defense).
- CartService.addLine keeps its signature (src/cart/service.ts:41).

## Acceptance criteria
- AC1 (proof of effect): npm test -- line.test, test "rejects quantity 0" passes. Baseline: exit 1, test does not exist yet; Plan step 1 adds it.
- AC2 (scope): git diff --name-only, every path is in Scope.
- AC3: npm run typecheck, exit 0. Baseline: exit 0.
- AC4: npm run lint, exit 0. Baseline: exit 0.
- AC5: npm test, no worse than baseline. Baseline: exit 1, 1 pre-existing failure in payments/refund.test.ts.

## Match
- src/cart/line.ts:12
  export function createLine(input: LineInput): Line {
    if (!input.sku) throw new DomainError("line.sku.required");
- src/cart/errors.ts:4
  export class DomainError extends Error { constructor(readonly code: string) { super(code); } }

## Scope
- src/cart/line.ts
- src/cart/line.test.ts
- read-only: existing tests, package-lock.json

## Plan
1. [src/cart/line.test.ts:1] Add test "rejects quantity 0" calling createLine with quantity 0 and expecting DomainError code "line.quantity.positive"; run it and confirm it fails.
2. [src/cart/line.ts:12] In createLine, after the sku guard, throw DomainError("line.quantity.positive") when input.quantity <= 0, matching the existing guard style.
