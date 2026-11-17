# App Clip design note: "Split a bill"

Signing and running an App Clip needs a paid Apple Developer account, so this is a design note rather than a shipped target.

## The flow
Scan a QR code at a restaurant -> the App Clip opens with the bill amount -> choose how many people -> pay your share with Apple Pay -> prompt to get the full app.

## Constraints
- Size limit (uncompressed App Clip binary, per Apple's App Clip documentation): 10 MB if it supports iOS 15 or earlier, 15 MB if it supports iOS 16, and 100 MB on iOS 17+ only if it is opened from digital links (website, Spotlight) and not from QR codes, NFC tags or App Clip Codes.
- A QR-code flow is a physical invocation, so this clip targets the 15 MB budget.
- Invocation: QR codes, NFC tags, App Clip Codes, Safari banners, Maps, Messages.
- Reuses `DesignSystem` and `Core` only. It must NOT include `Auth` or `Accounts`: no account data in a clip.
- Hand-off to the full app: an App Group shared container holding the bill ID.

## What would be built first
- An App Clip target with `NSAppClip` in its Info.plist and the parent app's App Group.
- A `SplitBillView` reusing `PrimaryButton`, `BalanceCard` and `Money(parsing:)`.
- Invocation URL handling through the same `DeepLinkRouter` with a `/split/{billID}` route.
