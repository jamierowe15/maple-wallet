import DesignSystem
import LocalAuthentication
import Observation
import SwiftUI

/// Optional Face ID / passcode lock when the app comes back from the background.
@Observable @MainActor
final class AppLock {
    var isEnabled: Bool {
        didSet { UserDefaults.standard.set(isEnabled, forKey: "appLockEnabled") }
    }
    private(set) var isLocked = false

    init() {
        isEnabled = UserDefaults.standard.bool(forKey: "appLockEnabled")
    }

    func lockIfEnabled() {
        if isEnabled { isLocked = true }
    }

    func unlock() async {
        let context = LAContext()
        var error: NSError?
        // Face ID with passcode fallback. No biometrics or passcode set up: nothing to check.
        guard context.canEvaluatePolicy(.deviceOwnerAuthentication, error: &error) else {
            isLocked = false
            return
        }
        let passed = (try? await context.evaluatePolicy(.deviceOwnerAuthentication,
                                                        localizedReason: "Unlock Maple Wallet")) ?? false
        isLocked = !passed
    }
}

struct LockView: View {
    let appLock: AppLock

    var body: some View {
        VStack(spacing: Spacing.l) {
            Image(systemName: "lock.fill")
                .font(.system(size: 48))
                .foregroundStyle(Palette.brand)
                .accessibilityHidden(true)
            Text("Maple Wallet is locked")
                .font(.title2.bold())
                .accessibilityAddTraits(.isHeader)
            PrimaryButton("Unlock") { Task { await appLock.unlock() } }
                .accessibilityIdentifier("lock.unlock")
        }
        .padding(Spacing.l)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(.background)
        .task { await appLock.unlock() }
    }
}
