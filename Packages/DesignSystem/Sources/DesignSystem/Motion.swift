#if canImport(UIKit)
import SwiftUI

/// Slides between steps, or cross-fades when Reduce Motion is on.
public struct StepTransition: ViewModifier {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    public func body(content: Content) -> some View {
        content.transition(reduceMotion
            ? .opacity
            : .asymmetric(insertion: .move(edge: .trailing), removal: .move(edge: .leading)))
    }
}

public extension View {
    func stepTransition() -> some View { modifier(StepTransition()) }
}

public extension Animation {
    /// Use instead of `.spring` so Reduce Motion is respected.
    static func standard(reduceMotion: Bool) -> Animation {
        reduceMotion ? .easeInOut(duration: 0.2) : .snappy
    }
}
#endif
