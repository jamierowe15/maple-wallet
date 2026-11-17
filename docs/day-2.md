# Day 2: Networking, Swift Concurrency, Combine and offline cache

The Accounts screen loads from a REST API, keeps working offline with cached data, and cancels work cleanly when you leave a screen.

## Recording: offline cache
<!-- auto:recording-offline -->
_Generated automatically by `bash maple-wallet-lab.sh evidence` (runs on GitHub's Macs)._
<!-- /auto:recording-offline -->

## How a request flows
`AccountsViewModel` -> `RemoteAccountsService` -> `APIClient` (retry, 401 refresh) -> `HTTPTransport` (real `URLSession`, or `LocalFixtureTransport` in the Simulator).

## Concurrency choices
- `APIClient` is a `Sendable` struct, not an actor: it holds only immutable values, so it's thread-safe without making every request queue behind one actor.
- Account detail loads balance and transactions with `async let`; recent activity uses `withThrowingTaskGroup`.
- Screens load in `.task {}` so SwiftUI cancels work when you leave. `CancellationError` never reaches the UI.
- Mutable shared state (the disk cache) lives in an actor.

## Combine vs AsyncSequence
Combine is the better fit for streams of UI events that need timing operators, like the debounced, de-duplicated transaction search.
For one request, or a sequence of steps, async/await is simpler to read and cancel.
New code here uses async/await by default and Combine only where its operators earn their place.

## Retry policy
Offline and 5xx: retry 3 times after 0.5 s, 1 s, 2 s (exponential backoff). 4xx: never retry, because the request itself is wrong. See `RetryPolicyTests`.

## Proof
`APIErrorTests` (every error mapping), `RetryPolicyTests` (backoff, give-up, no 4xx retry, cancellation), `AccountsViewModelTests.fallsBackToCacheWhenOffline`, `RecentActivityTests`.
