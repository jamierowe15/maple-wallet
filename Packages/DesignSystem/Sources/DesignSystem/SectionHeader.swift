#if canImport(UIKit)
import SwiftUI

/// Section heading for lists and forms: high-contrast text and a VoiceOver heading trait.
public struct SectionHeader: View {
    private let title: String

    public init(_ title: String) {
        self.title = title
    }

    public var body: some View {
        Text(title)
            .font(.subheadline.weight(.semibold))
            .foregroundStyle(Palette.textSecondary)
            .textCase(nil)
            .accessibilityAddTraits(.isHeader)
    }
}
#endif
