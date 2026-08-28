---
name: backend
description: Backend domain judgement for jediway, independent of language, framework, or database. Where logic and invariants live, persistence contracts, transactions, idempotency, errors, configuration, events versus commands, backend testing. Use for any task touching services, APIs, handlers, workers, schemas, migrations, queues, or CLIs, even "add an endpoint" or "fix this query". Feeds Ground and the Spec; not a role.
---

# Backend

Adds to `taste` only what is specific to services and data. Names no frameworks; the repo's transport, persistence, and messaging are whatever they already are, and the Master records them in Ground.

## Directive zero: discover before writing

The five local answers to find first: how requests enter (transport, routing, middleware), how persistence works (schema, migrations, transaction scope), how errors are modeled and mapped to the wire, how configuration and secrets load, how services are tested. Then conform.

## The schema is the deepest module

The persistence contract outlives every service that reads it. It is public API with stronger evidence required to touch than any code.

- Data invariants go in the database first: NOT NULL, CHECK, UNIQUE, foreign keys, enums or lookup tables for finite sets. The domain type mirrors the constraint so the application fails fast, but the constraint is what makes the invariant true.
- Migrations are additive by default: expand, migrate data, switch readers, contract. A rename or drop in one step is a deploy that cannot roll back.
- One writer per table. Two services writing the same rows leave the invariant with no owner; one owns it, the other consumes an event or an API.
- Query shape is design. A question the domain asks every request that needs three joins is a schema decision, not a caching problem.

## Placement ladder for logic

Ask in order; the first yes wins.

1. A fact about the data that must always hold? Database constraint, mirrored by the domain type.
2. A rule the domain owns regardless of transport? Domain: a constructor, a transition function, a value object. No framework imports here.
3. Orchestration across domain, persistence, and other services? Application: one use case, one transaction boundary, one place that decides what happens on failure.
4. About the wire? Handler: parse, validate shape at the boundary, call one use case, map result and errors to the transport. Nothing else.
5. About one external system? Adapter, implementing an interface the inner layer defines.

## Transactions and consistency

- The transaction boundary is the use case. Open late, close early, never hold it across a network call to another service.
- The invariant check and the write happen in the same transaction. Check-then-write across two transactions is a race, however rare it looks locally.
- Idempotency is decided at the write path: a natural key, an idempotency key stored with the result, or an operation idempotent by construction (set, not increment). Every retryable handler and every queue consumer needs one.
- Commands ask one owner to do something and may be rejected; events state that something happened and cannot be. Publish events after commit, through an outbox or equivalent that survives a crash between commit and publish. Never publish inside the transaction.
- Work that can outlive a request timeout is a job, with its own retry policy and its own idempotency.

## Errors

- Errors are values or typed exceptions with a domain code. One mapping module turns codes into transport codes; nothing else knows the transport.
- Expected outcomes (not found, invalid, conflict) are part of the interface and appear in tests. Faults (bug, dependency down) are logged with reproducing context and surfaced as one generic failure.
- Never swallow. An error caught and not re-raised, returned, or logged with enough context to reproduce is a bug paid for at 3 a.m.
- A batch that processes 9 of 10 items reports which one failed and why, and is safe to retry.

## Configuration and boundaries

- Validate configuration once at startup, fail fast, pass typed values inward. Code below the edge never reads environment variables.
- Validate inbound payloads once at the handler; inside, trust the types.
- Secrets never appear in logs, errors, or serialized objects. A correlation identifier from the first line of a request to the last is part of the feature.

## Testing

- Test behavior at the boundary a caller sees: the use case or the endpoint, with a real database where persistence is the thing under test. Mocking the database to test repository logic tests the mock.
- Test invariants by trying to break them: the test that inserts the illegal row and expects the constraint to refuse it is worth more than ten happy paths.
- Unit tests for domain rules with no I/O; integration tests for persistence, transactions, adapters; a few end-to-end tests for the operational paths that matter. A pyramid by what each layer can prove, not by count.
- Retry and idempotency get their own tests: the same request twice, the same message twice, the crash between commit and publish.

## Backend dependency policy

The three bars in `taste` apply. An ORM, a message client, or an HTTP client is an interface you will live behind for years: adopt it as a boundary decision and hide it behind the adapter the inner layers already expect. Prefer the database's own features (constraints, indexes, JSON operators, full-text search, row-level security) over application code or an extra service that reimplements them.
