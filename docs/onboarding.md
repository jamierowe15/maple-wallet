# Onboarding: your first day on Maple Wallet

Written for a junior developer joining the project.

## 1. Get it running (30 minutes)
- On a Mac: `scripts/bootstrap.sh`, pick an iPhone simulator, press Cmd+R. Tap **Sign in** (the stub login needs no account).
- On Windows or Linux: install Swift 6 and run `scripts/run_package_tests.sh`.

## 2. Take the tour (1 hour)
1. Read the README architecture diagram, then `App/CompositionRoot.swift`: it shows every real type in one place.
2. Follow one request: `AccountsView` -> `AccountsViewModel.load()` -> `RemoteAccountsService` -> `APIClient.send` -> `LocalFixtureTransport`.
3. Read the three ADRs in `docs/adr/` to learn why things are the way they are.

## 3. House rules
- Features never import each other; share through `Core` protocols.
- View models are `@Observable @MainActor`; shared mutable state lives in actors.
- Money is `Money` (integer cents), never `Double`.
- Every interactive view gets an accessibility label and an identifier.
- New logic comes with tests; keep the coverage gate green.

## 4. A good first task
Add an `InfoBanner` component to `DesignSystem` with light, dark and AX5 previews, then use it for the offline banner. Open a small PR using the template; expect review comments on accessibility and naming.

## 5. Getting help
Ask early. Paste the exact error, what you tried, and the smallest code that shows it.
