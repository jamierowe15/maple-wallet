# ADR 0003: OAuth Authorization Code + PKCE, tokens in the Keychain

- **Status:** Accepted
- **Date:** 2026-11-17

## Context
The app must sign users in without ever seeing their password or shipping a client secret, support single sign-on, and keep tokens safe on a lost or stolen phone.

## Decision
- Authorization Code flow with PKCE (S256) and a random `state`, through `ASWebAuthenticationSession`.
- Tokens only in the Keychain (`WhenUnlockedThisDeviceOnly`).
- One `TokenProvider` actor coalesces refreshes.
- `SFSafariViewController` for help pages; `WKWebView` only for our own token-protected pages, with a host allowlist and JavaScript off.

## Consequences
- The password never touches app code, and SSO works through shared Safari cookies.
- A stolen authorization code is useless without the PKCE verifier.
- Concurrent 401s cause one refresh, so single-use refresh tokens aren't burned.
- The login page is the provider's UI, so branding is limited to what the provider allows.

## Alternatives considered
- Native username/password form (Resource Owner Password grant): the app would handle passwords, and the grant is deprecated.
- Tokens in UserDefaults: plain text in backups and on jailbroken devices.
- WKWebView for login: the app could read keystrokes and SSO cookies aren't shared.
