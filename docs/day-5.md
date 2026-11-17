# Day 5: Testing, Instruments, CI/CD and packaging

Every push runs lint, unit, integration and UI tests with a 70% coverage gate on GitHub Actions; leak checks and Instruments traces cover memory; and the repo is documented for a new teammate.

## Coverage
<!-- auto:coverage -->
| Package | Line coverage | Lines | Gate |
|---|---|---|---|
| Core | 78.9% | 128 | report only |
| Networking | 87.4% | 191 | PASS (min 70%) |
| Auth | 84.8% | 276 | PASS (min 70%) |
| Accounts | 82.6% | 219 | PASS (min 70%) |
| Transfers | 82.5% | 63 | report only |
<!-- /auto:coverage -->

The gate (`scripts/check_coverage.py`) fails CI if `Networking`, `Auth` or `Accounts` drop below 70% line coverage.

## Tests
| Kind | Where | What it proves |
|------|-------|----------------|
| Unit | every package's `Tests/` | View model states, error mapping, retry policy, PKCE, token coalescing, money formatting, deep links |
| Integration | `APIClientIntegrationTests` | `APIClient` + token refresh + transport together: 401 -> refresh -> 200, decoding failures, real `URLSession` with `StubURLProtocol` |
| UI | `MainFlowUITests` | Sign in, open an account, send a transfer; sign out |
| Accessibility | `AccessibilityAuditTests` | Xcode's audit on every main screen |
| Leaks | `LeakTests`, `RetainCycleDemoTests` | View models and the token provider are freed; the classic strong-`self` cycle and its `[weak self]` fix |

## Memory: the retain cycle and its fix
`RetainCycleDemoTests` shows the before/after in code: `LeakyTicker` stores a closure that captures `self` strongly, so it is never freed; `FixedTicker` captures `[weak self]` and is freed.
`LeakTests` checks every view model and the token provider is freed after use.

## Instruments traces
<!-- auto:traces -->
_Not generated yet. Run `bash maple-wallet-lab.sh evidence`._
<!-- /auto:traces -->

## CI
- `packages`: Swift package tests + coverage gate on macOS (`scripts/run_package_tests.sh`).
- `packages-linux`: the same packages on Linux, proving the logic has no Apple-only dependencies.
- `app`: SwiftLint, XcodeGen, build, UI tests and the accessibility audit, with results uploaded as artifacts.
- `main` is protected: a pull request can't merge until `packages` and `app` pass.

### Proof that CI blocks a broken test
<!-- auto:ci-proof -->
[This throwaway pull request](https://github.com/jamierowe15/maple-wallet/pull/6) added a deliberately failing test. CI went red and GitHub blocked the merge, so the PR was closed unmerged.
<!-- /auto:ci-proof -->

## fastlane
```bash
bundle install
bundle exec fastlane test          # unit + UI tests with coverage
bundle exec fastlane screenshots   # light, dark, AX5 and iPad screenshots
bundle exec fastlane evidence      # everything in scripts/ci/evidence.sh
bundle exec fastlane beta          # TestFlight (needs a paid Apple Developer account)
```

## One-command setup
`scripts/bootstrap.sh` installs XcodeGen and SwiftLint, generates the project and opens Xcode.
