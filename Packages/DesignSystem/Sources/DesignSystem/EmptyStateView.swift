#if canImport(UIKit)
import SwiftUI

public struct EmptyStateView: View {
    private let title: String
    private let message: String
    private let systemImage: String
    private let actionTitle: String?
    private let action: (() -> Void)?

    public init(title: String, message: String, systemImage: String,
                actionTitle: String? = nil, action: (() -> Void)? = nil) {
        self.title = title
        self.message = message
        self.systemImage = systemImage
        self.actionTitle = actionTitle
        self.action = action
    }

    public var body: some View {
        VStack(spacing: Spacing.m) {
            Image(systemName: systemImage)
                .font(.largeTitle)
                .foregroundStyle(Palette.textSecondary)
                .accessibilityHidden(true)
            Text(title)
                .font(.title3.bold())
                .multilineTextAlignment(.center)
                .accessibilityAddTraits(.isHeader)
            Text(message)
                .font(.body)
                .foregroundStyle(Palette.textSecondary)
                .multilineTextAlignment(.center)
            if let actionTitle, let action {
                PrimaryButton(actionTitle, action: action).padding(.top, Spacing.s)
            }
        }
        .padding(Spacing.l)
        .frame(maxWidth: 480)
    }
}
#endif
