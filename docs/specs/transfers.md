# Spec: Transfers

## User stories
- **T1** As a customer, I move money between my own accounts in four steps: from, to, amount, confirm.
- **T2** As a customer, I'm told in plain words why a transfer can't go yet.
- **T3** As a customer, I can repeat a past transaction's amount as a new transfer.
- **T4** As a VoiceOver user, I hear when the transfer succeeds or fails.

## Acceptance criteria
| ID | Then | Test |
|----|------|------|
| T1 | two different accounts are pre-selected | `TransferViewModelTests.preselectsTwoDifferentAccounts` |
| T1 | confirming moves to `.done` with a confirmation number | `confirmsTransfer` |
| T2 | no amount, same account, or more than the balance gives a message | `requiresAnAmount`, `blocksSameAccount`, `blocksMoreThanTheBalance` |
| T3 | a repeated amount pre-fills as a positive number | `prefillsRepeatedAmount` |
| T4 | success and failure post an announcement | `TransferView.announce` (manual VoiceOver check) |
| - | a failure shows friendly copy | `showsFriendlyFailure` |
