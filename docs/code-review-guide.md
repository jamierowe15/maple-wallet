# Code review guide

What I check, in order, and why.

1. **Does it do what the PR says?** Run it, or read the test that proves it.
2. **Correctness under concurrency.** Shared mutable state outside an actor? A `Task {}` that outlives its screen? Cancellation handled?
3. **Security.** Secrets or tokens in code, logs or URLs? Web views restricted? Input validated?
4. **Accessibility.** Labels, Dynamic Type, colour-only meaning, identifiers for UI tests.
5. **Tests.** Do they fail if the code is wrong? Edge cases (zero, negative, empty, offline)?
6. **Design.** Right module? New dependency between features? Could a protocol keep it testable?
7. **Readability.** Names, size of functions, comments that explain *why*.

## How I write comments
- Ask, don't order: "What happens if this is cancelled mid-way?"
- Label weight: **blocking**, **suggestion**, **nit**.
- Praise specific good things too.
- If it takes more than three comments to explain, offer a call.

## Reviews given
Every pull request in this repo was reviewed line by line before merging. Reviews of other people's code are listed in [LAB-CHECKLIST.md](LAB-CHECKLIST.md).
