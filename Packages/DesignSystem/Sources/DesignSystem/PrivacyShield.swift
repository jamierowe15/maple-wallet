#if canImport(UIKit)
import SwiftUI

public extension View {
    /// Blurs everything (balances included) in the app switcher.
    func privacyShield(isActive: Bool) -> some View {
        blur(radius: isActive ? 24 : 0)
            .overlay {
                if isActive {
                    Image(systemName: "lock.fill")
                        .font(.largeTitle)
                        .foregroundStyle(Palette.textSecondary)
                        .accessibilityHidden(true)
                }
            }
    }
}
#endif
