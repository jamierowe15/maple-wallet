# Spec: Sign-in and session

## User stories
- **S1** As a customer, I sign in through my bank's secure login page, never inside the app.
- **S2** As a customer already signed in to the identity provider in Safari, I'm not asked for my password again (SSO).
- **S3** As a customer, my session renews quietly while I use the app.
- **S4** As a customer, signing out removes everything the app stored about me on this phone.

## Acceptance criteria
| ID | Then | Test |
|----|------|------|
| S1 | the authorize URL carries a PKCE S256 challenge and state, never a client secret | `CallbackValidatorTests.authorizeURLCarriesPKCEAndState` |
| S1 | a callback with a different state is rejected and nothing is stored | `SignInServiceTests.tamperedStateIsRejectedAndNothingIsStored` |
| S3 | five parallel 401s trigger exactly one refresh | `ParallelUnauthorizedRequestsTests.fiveParallel401sTriggerExactlyOneRefresh` |
| S3 | a fresh token is reused without refreshing | `TokenProviderTests.validTokenSkipsRefreshWhenFresh` |
| S4 | sign-out clears tokens | `SignInServiceTests.signOutClearsTokens` |
