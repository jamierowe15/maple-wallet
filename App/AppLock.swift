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
        isLocked = !(await Self.authenticate())
    }

    /// Face ID with passcode fallback. The LAContext is created and used on one thread only.
    /// No biometrics or passcode set up on the device: nothing to check, so it unlocks.
    nonisolated private static func authenticate() async -> Bool {
        let context = LAContext()
        var error: NSError?
        guard context.canEvaluatePolicy(.deviceOwnerAuthentication, error: &error) else { return true }
        return (try? await context.evaluatePolicy(.deviceOwnerAuthentication,
                                                  localizedReason: "Unlock Maple Wallet")) ?? false
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
