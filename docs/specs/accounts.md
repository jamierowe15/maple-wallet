# Spec: Accounts

Spec-driven development (SDD): this spec was written before the code. Each acceptance criterion names the test that proves it.

## User stories
- **A1** As a customer, I see all my accounts with their current balance when I open the app.
- **A2** As a customer with no accounts, I see a clear empty state, not a blank screen.
- **A3** As a customer, if loading fails I see a plain-language message and can try again.
- **A4** As a customer who leaves the screen mid-load, I never see an error caused by that.
- **A5** As a customer with no connection, I still see my last known balances and when they were updated.
- **A6** As a customer on iPad, I see my accounts and the selected account's activity side by side.

## Acceptance criteria
| ID | Given | When | Then | Test |
|----|-------|------|------|------|
| A1 | the service returns 3 accounts | the screen loads | state is `.loaded` with 3 accounts | `AccountsViewModelTests.loadsAccounts` |
| A2 | the service returns `[]` | the screen loads | state is `.empty` | `showsEmptyState` |
| A3 | the service throws, no cache | the screen loads | state is `.failed` with retry | `showsFriendlyErrorWithNoCache` |
| A4 | the load is cancelled | the screen loads | state is `.idle`, no error | `staysQuietWhenCancelled` |
| A5 | the service throws, cache has data | the screen loads | cached accounts + `lastUpdated` | `fallsBackToCacheWhenOffline` |
| A6 | regular width | an account is selected | list + detail in `NavigationSplitView` | screenshot `ipad-03-account-detail.png` |

## API contract
| Method | Path | Response |
|--------|------|----------|
| GET | `/accounts` | `[Account]` |
| GET | `/accounts/{id}` | `Account` |
| GET | `/accounts/{id}/transactions` | `[Transaction]` (newest first) |
| POST | `/transfers` | `{ "confirmation": String }` |

Money is always `{ "minorUnits": Int, "currencyCode": "CAD" }`. Dates are ISO 8601.
