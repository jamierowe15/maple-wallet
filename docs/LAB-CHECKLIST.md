# Lab checklist

Every task, deliverable and acceptance criterion in the iOS Proficiency Lab, and how it's covered.
**Script** = written by `maple-wallet-lab.sh`. **CI** = produced or proved on GitHub's Macs. **You** = needs a person.
Items marked * need a paid Apple Developer account to run end to end; the code and docs are still here.

## Day 1: Architecture, SPM modules and SwiftUI components
- [x] Xcode project, Swift 6 mode, strict concurrency (`project.yml`): Script
- [x] Packages DesignSystem, Networking, Auth, Accounts, Transfers + Core: Script
- [x] Models `Account`, `Transaction`, `Money` (integer cents), Sendable/Codable/Identifiable: Script
- [x] `AccountsService` protocol; `AccountsViewModel` with a state enum: Script
- [x] Components BalanceCard, TransactionRow, PrimaryButton, EmptyStateView with semantic tokens: Script
- [x] Previews in light, dark and AX text: Script
- [x] Composition root with a mock service: Script
- [x] Stretch: horizontal/vertical switch for large sizes (`AnyLayout`): Script
- [x] SDD spec, modern Swift list, CI started: Script
- [x] Deliverables: PR, `day-1` tag, `docs/day-1.md` with diagram, ADR 0001: Script; screenshots: CI
- [x] Acceptance: no feature imports another; view model testable in one line: Script (enforced by packages, tests)
- [x] Acceptance: builds under strict concurrency: CI

## Day 2: Networking, Swift Concurrency, Combine and offline cache
- [x] Fixtures + stub server (`LocalFixtureTransport`, `StubURLProtocol`): Script
- [x] Typed `APIClient`, `Endpoint<Response>`, `APIError` (offline, unauthorized, server, decoding, cancelled): Script
- [x] Thread-safe client (Sendable struct; reason in ADR 0002): Script
- [x] `async let` detail loading; task group for recent activity: Script
- [x] `.task {}` cancellation; no error UI for `CancellationError`: Script
- [x] Retry with backoff 0.5/1/2 s for offline and 5xx only: Script
- [x] Offline cache with "Last updated" banner: Script
- [x] Combine debounced search: Script
- [x] Every `APIError` mapped to plain-language copy with retry: Script
- [x] Stretch: pull to refresh: Script
- [ ] Stretch: ETag / If-None-Match: not built (optional stretch)
- [x] Deliverables: `day-2` tag, ADR 0002, offline recording: Script + CI
- [x] Acceptance: error mapping and retry policy unit-tested: Script

## Day 3: Auth flows, secure SSO and Keychain
- [x] Stub login works with no tenant; optional Auth0 via `Config/Auth.local.xcconfig`: Script
- [x] PKCE (S256) + state validation: Script (RFC test vector)
- [x] `ASWebAuthenticationSession` wrapped in a continuation: Script
- [x] Tokens in Keychain, `WhenUnlockedThisDeviceOnly`: Script
- [x] `TokenProvider` actor: five parallel 401s, one refresh: Script (proved by test)
- [x] Help centre in SFSafariViewController; Statements in WKWebView with header token, allowlist, JS off: Script
- [x] Sign-out clears Keychain, cache and web data: Script
- [x] Privacy blur in the app switcher: Script
- [x] `docs/security.md`: Script
- [x] Additions: certificate pinning with reject-path test, file protection + backup exclusion, Face ID and camera usage strings, privacy manifest: Script
- [x] Addition: Apple Pay top-up with delegate*: Script
- [x] Stretch: Face ID unlock (`AppLock`), deep link after sign-in: Script
- [x] Deliverables: `day-3` tag, ADR 0003, sign-in/refresh/sign-out recording: Script + CI
- [x] Acceptance: no secrets in the repo; state mismatch rejected; web view allowlist: Script (tests)

## Day 4: Accessibility and adaptive layouts
- [x] Transfers flow (from, to, amount, review, confirm): Script
- [x] VoiceOver: combined rows, spoken money, hints, headers: Script
- [x] Custom action "Repeat transfer": Script
- [x] Success/failure announcements: Script
- [x] Dynamic Type with layout switching: Script
- [x] Reduce Motion cross-fade: Script
- [x] High-contrast + Dark Mode colours; sign + icon, not colour alone: Script
- [x] `NavigationSplitView` for iPad: Script
- [x] Accessibility audit on every screen: CI (`AccessibilityAuditTests`, report in `docs/accessibility.md`)
- [x] Screenshots: small iPhone at AX5, Dark Mode, iPad split view: CI
- [x] Widget with App Group and lock-screen redaction: Script
- [x] Push notification opening a transaction (Simulator payload): Script
- [x] Deep link router, unit-tested: Script
- [x] Universal links* (AASA file + entitlement, commented until you have a domain): Script
- [x] App Clip* design note: Script
- [ ] VoiceOver eyes-closed transfer + recording: **You** (VoiceOver can't run in CI)
- [ ] Check the AX5 screenshots for clipped text and view the app in greyscale: **You** (2 minutes)

## Day 5: Testing, Instruments, CI/CD and packaging
- [x] Unit tests (view models, errors, retry, refresh coalescing, PKCE, money): Script
- [x] Integration tests (401 -> refresh -> 200, decoding failure, URLProtocol): Script
- [x] UI tests by accessibility identifier with `-uiTesting`: Script
- [x] Coverage on, numbers in README: Script + CI
- [x] Leaks: leak tests + retain-cycle before/after + Leaks/Time Profiler traces: Script + CI
- [ ] Instruments screenshots: optional, **You** (open the `.trace` files from the Evidence artifact on a Mac)
- [x] SwiftLint config: Script
- [x] CI workflow with lint, build, tests, artifacts: Script
- [x] fastlane test, screenshots, evidence and beta* lanes: Script
- [x] `scripts/bootstrap.sh`: Script
- [x] Final README with GIF, diagram, coverage, CI badge: Script + CI
- [x] Coverage gate in Python: Script
- [x] Protected `main`, PR template: Script (`protect`)
- [x] CI proven to fail on a broken test (throwaway PR): Script (`prove-ci`)
- [x] CONTRIBUTING, code review guide, onboarding guide: Script
- [ ] Review one open-source Swift PR or a classmate's repo: **You**
- [ ] Record the 5-minute walkthrough (`docs/walkthrough-script.md`) and link it: **You**

## Submission
- [x] Public repo with `day-1` to `day-5` and `v1.0` tags: Script (`auto` / `release`)
- [x] Three ADRs, five daily reports, three specs: Script
- [x] Recordings: main flow, offline cache, SSO + refresh: CI
- [ ] Pin the repo on your GitHub profile; add it to your resume and LinkedIn: **You**
- [ ] Read the code until you can explain every file (the beginner's course): **You**
