# ADR 0002: Concurrency model

- **Status:** Accepted
- **Date:** 2026-11-16

## Context
Swift 6 strict concurrency turns data races into compile errors. We need a clear rule for where mutable state lives so the compiler can prove the app is safe.

## Decision
- View models are `@Observable @MainActor` classes: all UI state changes happen on the main actor.
- `APIClient` is an immutable `Sendable` struct.
- Shared mutable state (token refresh, the disk cache, test fakes) lives in actors.
- Cancellation is cooperative: `.task {}` in views, `Task.checkCancellation()` in loops, and `CancellationError` is never shown.

## Consequences
- Easier: no locks or dispatch queues anywhere; the compiler checks thread-safety.
- Easier: view model tests are plain `async` tests on the main actor.
- Harder: every protocol crossing an actor boundary must be `Sendable`, and closures passed to views need `@MainActor` types.
- Harder: actor reentrancy has to be considered whenever an actor method awaits (see `TokenProvider`).

## Alternatives considered
- GCD queues and locks: easy to get wrong and invisible to the compiler.
- Combine everywhere: powerful but harder to read and to cancel for simple requests.
- Making `APIClient` an actor: unnecessary serialisation, because it has no mutable state.
