---
name: frontend
description: Frontend domain judgement for jediway, independent of any library. Where state lives, component taxonomy and scoping, one-way data flow, rendering, styling, accessibility, UI dependency policy. Use for any task touching UI code in any component framework, even "add a button" or "should I use X". Feeds Ground and the Spec; not a role.
---

# Frontend

Adds to `taste` only what is specific to user interfaces. Names no libraries; the repo's data layer, router, store, and styling system are whatever they already are, and the Master records them in Ground.

## Directive zero: discover before writing

The five local answers to find first: how data arrives (the data layer), where shared state lives, how components are organized, how styling is done, how UI is tested. Then conform. Defaults below apply only when the repo is greenfield or has no discernible convention.

## Data flows one direction

Server, then data layer, then feature, then view. Typed or validated edge to edge. A view never reaches around its feature to touch transport; a shared primitive never knows the domain exists.

## State: the placement ladder

Ask in order; the first yes wins. Most frontend bugs are state placed one level too high; most performance problems are state placed too globally.

1. Does the server own it? Fetched data, mutations, caching, invalidation belong to the data-fetching layer, and its cache is the single source of truth for server data. Never mirror server data into stores, context, or local state; a mirror is a second source of truth. Deliberately derived copies (a draft being edited, an optimistic overlay) are transformations with an owner, not mirrors.
2. Should a URL reproduce it? Filters, tabs, pagination, sort, anything a user might share or return to, belongs in the router. If losing it on refresh would annoy the user, it belongs here.
3. Does one component or one small subtree own it? Local state. Passing props one or two levels is honest and keeps the flow visible. Use a reducer-style pattern when the transitions between states, not the values, are the complexity.
4. Do distant parts of the tree share it and does it change often? Orchestration, optimistic UI, undo, cross-panel selection belong in the client-state store, scoped per feature, never one god store, subscribed as narrowly as it allows. A slice that only holds server data is a mirror; retire it.
5. Is it injected rather than changed? Theme, session, flags, environment, services belong in context or dependency injection, which distributes stable values downward and is not a change-propagation mechanism. An injected value that updates often was misfiled; return to rung 3 or 4.

Custom hooks are the encapsulation tool, not a state tier. Extract when stateful logic is reused or a component's logic drowns its markup. A hook used once that merely renames a primitive is indirection without a concept; inline it.

## Component taxonomy and scoping

Five roles, one rule each; map them onto the repo's own vocabulary.

- Atom: one interface concept, zero business meaning. Props are visual variants only.
- Molecule: a few atoms plus interaction glue, still domain-free. For both: if a prop name contains a domain word, it is not one.
- Feature component: where the domain lives. Uses its own feature's hooks, contracts, and state. Private by default behind one small entry module.
- View: composes features into a screen region. Wiring and layout only.
- Page or route: binds URL to view; reads params, sets layout and metadata, renders one view. A business-rule conditional here is a misplaced feature.

Scoping: everything starts colocated at its use site. Second consumer within the feature: the feature's shared internals. Second consumer across features: promote to the shared layer only if the component can shed all domain meaning; otherwise duplicate it and let the copies diverge, which is the proof they were never one thing. Cross-feature imports go only through public surfaces; a deep import into another feature's internals silently converts private code into unbreakable API.

## Rendering

- Derive, do not sync. A value computable from props or from the data layer is computed at render, never copied into state and kept in step by effects.
- Effects synchronize with things outside the render tree: subscriptions, focus, timers, imperative libraries. An effect that sets state from other state is a derived value in disguise.
- Every async boundary renders something deliberate for pending, empty, and failed, modeled as one state value.

## Styling

- Colocation over ceremony; styles live as close to the component as the system allows. Greppability is a feature.
- Platform first: prefer what CSS and HTML do natively (layout primitives, parent-aware selectors, container-relative sizing) over JavaScript recreations.
- Tokens when the palette has a second consumer (theming, dark mode, multiple surfaces). A single-theme internal tool gets consistency from restraint, not infrastructure.
- Extract a shared style on the third occurrence of the same concept.

## Accessibility is structural

Semantic elements first, ARIA only where semantics run out, focus managed on every dialog and route change, contrast and keyboard paths verified as part of the work. A UI acceptance criterion includes the keyboard path where one exists.

## UI dependency policy

The three bars in `taste` apply. A dependency that owns rendering (component libraries, animation, virtualization) also owns your accessibility and your bundle: treat it as an interface, not an implementation. Prefer the data layer, router, and store the repo already has. Each maintenance cycle, ask which libraries CSS and the platform have absorbed, and retire them.
