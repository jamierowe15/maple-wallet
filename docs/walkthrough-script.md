# 5-minute architecture walkthrough (script)

Read this aloud while screen-sharing the repo; record it with QuickTime or Loom and link it in the README.

1. **(0:00) What it is.** A fictional SwiftUI banking app built to show production iOS practices.
2. **(0:30) Modules.** Show the README diagram. Six SPM packages; features never depend on each other; the app target is the composition root.
3. **(1:15) One request, end to end.** Open `AccountsViewModel.load()`, then `APIClient.send`: retries with backoff for offline and 5xx, never for 4xx; every failure becomes one `APIError`.
4. **(2:00) Concurrency.** Open `TokenProvider`. Five requests get a 401; one refresh task is shared. Show the test that proves it.
5. **(2:45) Security.** PKCE + state through `ASWebAuthenticationSession`, tokens only in the Keychain, pinning, file protection.
6. **(3:30) Accessibility.** Show the AX5 and iPad screenshots; spoken money labels; the "Repeat transfer" VoiceOver action; the automated audit.
7. **(4:15) Quality.** CI: packages on macOS and Linux, UI tests, a 70% coverage gate, protected `main`, and the PR that proved a broken test is blocked.
8. **(4:45) What I'd do next.** A real backend, universal links on a real domain, TestFlight builds from CI.
