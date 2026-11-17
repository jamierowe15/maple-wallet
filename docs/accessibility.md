# Accessibility

## Automated audit (Xcode accessibility audit on every main screen)
`AccessibilityAuditTests` runs `XCUIApplication.performAccessibilityAudit()` on Sign in, Accounts, Account detail, Transfer and More, the same checks as Accessibility Inspector's audit.
<!-- auto:a11y-audit -->
| Screen | Result | Details |
|---|---|---|
| Sign in | 1 issue(s) | Contrast nearly passed |
| Accounts | 3 issue(s) | Contrast nearly passed<br>Contrast nearly passed<br>Contrast nearly passed |
| Account detail | 8 issue(s) | Text clipped<br>Contrast nearly passed<br>Contrast nearly passed<br>Contrast nearly passed<br>Contrast nearly passed<br>Contrast nearly passed<br>Contrast nearly passed<br>Contrast nearly passed |
| Transfer | 5 issue(s) | Contrast nearly passed<br>Contrast nearly passed<br>Text clipped<br>Text clipped<br>Text clipped |
| More | 9 issue(s) | Contrast nearly passed<br>Contrast nearly passed<br>Contrast nearly passed<br>Contrast nearly passed<br>Contrast nearly passed<br>Contrast nearly passed<br>Contrast failed<br>Contrast failed<br>Contrast failed |
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
| Big tap targets | Buttons at least 50 points tall | `PrimaryButton` |

## Screens at AX5, in Dark Mode and on iPad
See the screenshots in [day-4.md](day-4.md).

## Manual VoiceOver pass (on a device or the Simulator)
Turn on VoiceOver, close your eyes, and sign in, open an account, and send a transfer. Record the result in [LAB-CHECKLIST.md](LAB-CHECKLIST.md).
