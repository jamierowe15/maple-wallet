# Security notes

The app signs in with OAuth Authorization Code + PKCE through the system browser, keeps tokens only in the Keychain, refreshes them once however many requests fail, and protects data at rest and on screen.

## Which web view, when
| Need | Use | Why |
|------|-----|-----|
| Sign in / SSO | `ASWebAuthenticationSession` | System browser: the app can't read the password, and Safari cookies give single sign-on. |
| Read-only help pages | `SFSafariViewController` | Real URL bar, no access to the page from the app. |
| Our own page that needs the user's token | `WKWebView` | Lets us add an Authorization header, allowlist hosts and disable JavaScript. |
Never use `WKWebView` for login: the app could read what the user types.

## Why PKCE
A mobile app can't keep a client secret: anyone can unpack the app and read it.
Without one, another app that registers the same `maplewallet://` scheme could catch the authorization code and swap it for tokens.
PKCE stops that: the app sends only a hash of a random verifier at the start, and must present the verifier itself to redeem the code.
A thief has the code but not the verifier, so the code is useless. The random `state` value separately rejects callbacks the app didn't start.

## Token storage
Access and refresh tokens are stored only in the Keychain with `kSecAttrAccessibleWhenUnlockedThisDeviceOnly`: unreadable while the phone is locked, never restored to another device.
Nothing goes in `UserDefaults` or files. Sign-out clears the Keychain, the offline cache and all web view data.

## Token refresh
`TokenProvider` is an actor. When several requests get a 401 together, the first starts one refresh task and the others await it. One network call; proved by `fiveParallel401sTriggerExactlyOneRefresh`.

## Certificate pinning
`PinnedSessionDelegate` rejects servers whose public key hash isn't in the `PinSet`.
- **Risk:** if the server's key rotates and the app doesn't know the new pin, every user is locked out until they update.
- **Mitigation:** pin the current key and a backup key; ship new pins before rotating; keep a remote kill switch.
- This demo hashes the raw key, not the full SubjectPublicKeyInfo used by most pinning tools.
In a real banking app pinning is worth it for the API host, because it defeats interception by a mis-issued or locally installed certificate, but only with backup pins and a rotation plan.

## Data protection
The offline cache is written with `.completeFileProtection` (encrypted while locked) and excluded from backups.
The app blurs itself in the app switcher (`privacyShield`), and can require Face ID when it comes back (`AppLock`).

## Permissions
Camera and Face ID usage strings live in `project.yml`. Permission is asked only when the user taps the feature, and "denied" shows a Settings link. A privacy manifest is in `App/PrivacyInfo.xcprivacy`.

## Apple Pay
The app never handles card numbers. Apple Pay returns an encrypted payment token (`PKPayment.token.paymentData`).
The app sends that token to the bank's server, which passes it to the payment processor to decrypt and charge, then tells the app success or failure.
`ApplePayCoordinator` implements this flow; `DemoPaymentServer` stands in for the server.
