# Contributing to Maple Wallet

## Getting set up
- **Mac:** `scripts/bootstrap.sh` installs XcodeGen + SwiftLint, generates the project and opens Xcode.
- **Windows/Linux:** install Swift, then `scripts/run_package_tests.sh` runs all logic tests.

## How we work
1. Branch from `main`: `feature/<short-name>`.
2. Small PRs (under ~400 lines). Fill in the PR template.
3. CI must be green (`packages` and `app`). `main` is protected.
4. Every PR gets a line-by-line review. See [docs/code-review-guide.md](docs/code-review-guide.md).
5. Big decisions get an ADR in `docs/adr/`.
6. New here? Start with [docs/onboarding.md](docs/onboarding.md).

## Code rules
- Features depend on `Core` protocols and `DesignSystem`, never on another feature.
- View models are `@Observable @MainActor`; shared mutable state lives in actors.
- Money is `Money` (integer cents). Never `Double`.
- Tokens only in the Keychain.
- Every interactive element has an accessibility label; UI tests use accessibility identifiers.
- New logic needs tests; keep `Networking`, `Auth` and `Accounts` at 70%+ coverage.
