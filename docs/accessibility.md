# Accessibility

## Automated audit (Xcode accessibility audit on every main screen)
`AccessibilityAuditTests` runs `XCUIApplication.performAccessibilityAudit()` on Sign in, Accounts, Account detail, Transfer and More, the same checks as Accessibility Inspector's audit.
<!-- auto:a11y-audit -->
_Not generated yet. Run `bash maple-wallet-lab.sh evidence`._
<!-- /auto:a11y-audit -->

## Built in
| Need | How | Where |
|------|-----|-------|
| VoiceOver reads a row as one sentence | `.accessibilityElement(children: .ignore)` + label | `TransactionRow`, `BalanceCard` |
| Money spoken naturally | `Money.spokenDescription()`: "minus forty-two dollars fifteen cents" | `Money+Accessibility.swift`, tested in `SpokenMoneyTests` |
| Repeat a transfer without hunting | VoiceOver custom action "Repeat transfer" | `AccountDetailView` |
| Know a transfer succeeded | `AccessibilityNotification.Announcement` | `TransferView` |
| Headings to jump between | `.accessibilityAddTraits(.isHeader)` | Empty states, review, done |
| Dynamic Type to AX5 | Text styles only; rows switch to vertical stacks at accessibility sizes | `BalanceCard`, `TransactionRow` |
| Reduce Motion | Cross-fade instead of slide | `StepTransition`, `Animation.standard` |
| Increase Contrast + Dark Mode | Four-variant dynamic colours | `Palette` in `Tokens.swift` |
| Not colour alone | Sign + icon + colour for credit/debit | `TransactionRow` |
| Readable secondary text | `Palette.textSecondary` is darker than the system grey (about 7:1 on white) | `Tokens.swift`, `SectionHeader` |
| Links and buttons readable | App tint is the brand red (6:1 on white) instead of system blue (4:1) | `RootView` |
| No truncated account names | Transfer pickers list each account as a full, wrapping row | `TransferView` |
| Big tap targets | Buttons at least 50 points tall | `PrimaryButton` |

## Screens at AX5, in Dark Mode and on iPad
See the screenshots in [day-4.md](day-4.md).

## Manual VoiceOver pass (on a device or the Simulator)
Turn on VoiceOver, close your eyes, and sign in, open an account, and send a transfer. Record the result in [LAB-CHECKLIST.md](LAB-CHECKLIST.md).
