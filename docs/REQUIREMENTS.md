# How each job requirement is met

Mobile Software Engineer I (iOS), req. R_1520654. Each line of the posting, and where this repo shows it.

## Requirements
| Posting requirement | Evidence in this repo |
|---|---|
| Degree/diploma in CS or equivalent | Not something a repo can show: covered by the resume |
| 1-3 years professional iOS in Swift | Not something a repo can show: this repo is project evidence, not employment |
| SwiftUI production apps | `Packages/*/Sources/**/*View.swift`, `App/`, `Widget/`; screenshots in `docs/day-4.md` |
| Modern Swift features | `@Observable`, typed throws (`APIClient.send`), macros (`#Preview`, `#expect`), Swift Testing, Swift 6 language mode (`docs/day-1.md`) |
| Swift Concurrency: async/await, structured concurrency, cancellation, thread-safety | `AccountDetailViewModel` (async let), `RecentActivity` (task group), `.task {}` + `CancellationError` handling, `TokenProvider` actor, strict concurrency in `project.yml`; `RetryPolicyTests.stopsRetryingWhenCancelled`, `ParallelUnauthorizedRequestsTests` |
| Combine | `TransactionSearch` (debounce, removeDuplicates, combineLatest) |
| Reusable UI components, adaptive iPhone/iPad | `Packages/DesignSystem`; `NavigationSplitView` in `AccountsView`; `AnyLayout` at AX sizes; iPad screenshot |
| MVVM, protocol-oriented design | State-enum view models; `AccountsService`, `HTTPTransport`, `TokenStore`, `TransfersService`; `CompositionRoot` |
| REST APIs, auth flows, error handling, offline/cache | `APIClient`, `Endpoint`, `APIError` -> `UserFacingError`, `FileAccountsCache`; `docs/day-2.md` offline recording |
| WKWebView / SFSafariViewController, secure SSO | `StatementsWebView` (allowlist, header token, no JS), `SafariView`, `WebAuthenticator` (ASWebAuthenticationSession + PKCE); `docs/security.md` |
| Accessibility: VoiceOver, Dynamic Type, reduced motion, contrast, Dark Mode | `docs/accessibility.md` (automated audit + table of techniques), `Money.spokenDescription`, `StepTransition`, `Palette` |
| Unit + integration + UI tests, 60-80% coverage | `Packages/*/Tests`, `APIClientIntegrationTests`, `UITests/`; 70% gate in `scripts/check_coverage.py`; table in README |
| Instruments: memory, leaks, time profiler | `LeakTests`, `RetainCycleDemoTests`, Leaks + Time Profiler traces from the Evidence workflow (`docs/day-5.md`) |
| Git, PR review, shared code ownership | One PR per day, PR template, protected `main`, `CONTRIBUTING.md`, `docs/code-review-guide.md` |
| SPM, modular dependencies | Six local packages + `swift-crypto` with a platform condition |
| Technical communication, mentoring, code review | ADRs, specs, daily reports, `docs/onboarding.md`, `docs/walkthrough-script.md`, review guide |

## Nice to have
| Posting item | Evidence |
|---|---|
| CI/CD (GitHub Actions, fastlane) | `.github/workflows/ci.yml`, `evidence.yml`, `fastlane/Fastfile` (test, screenshots, evidence, beta) |
| Keychain, certificate pinning, privacy permissions, data protection | `KeychainTokenStore`, `PinSet` + `PinnedSessionDelegate`, usage strings + `PrivacyInfo.xcprivacy`, `.completeFileProtection`, `AppLock` |
| Push, Deep Links, Universal Links, Widgets, App Clips | `AppDelegate` + `push/*.apns`, `DeepLinkRouter`, `docs/apple-app-site-association`, `Widget/`, `docs/app-clip.md` (universal links and App Clips need a paid account) |
| Apple Pay / PassKit | `TopUpView` + `ApplePayCoordinator` (a real merchant ID needs a paid account) |
| Ruby/Python/Bash/YAML scripting | `Fastfile` (Ruby), `check_coverage.py` / `update_docs.py` (Python), `scripts/*.sh` (Bash), workflows (YAML) |
| Model 2 / SDD | Spec-first: `docs/specs/*.md` with acceptance criteria linked to tests. "Model 2" isn't a standard term; worth asking the recruiter what they mean. |
