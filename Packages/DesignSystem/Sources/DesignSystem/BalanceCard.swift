#if canImport(UIKit)
import SwiftUI

/// Account name + balance. Lays out horizontally, and stacks vertically at
/// accessibility text sizes so the number never truncates.
public struct BalanceCard: View {
    private let title: String
    private let subtitle: String
    private let balance: String
    private let spokenBalance: String
    @Environment(\.dynamicTypeSize) private var typeSize

    public init(title: String, subtitle: String, balance: String, spokenBalance: String? = nil) {
        self.title = title
        self.subtitle = subtitle
        self.balance = balance
        self.spokenBalance = spokenBalance ?? balance
    }

    public var body: some View {
        let layout = typeSize.isAccessibilitySize
            ? AnyLayout(VStackLayout(alignment: .leading, spacing: Spacing.s))
            : AnyLayout(HStackLayout(alignment: .firstTextBaseline, spacing: Spacing.m))

        layout {
            VStack(alignment: .leading, spacing: Spacing.xs) {
                Text(title).font(.headline).foregroundStyle(Palette.textPrimary)
                    .fixedSize(horizontal: false, vertical: true)
                Text(subtitle).font(.subheadline).foregroundStyle(Palette.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            if !typeSize.isAccessibilitySize { Spacer(minLength: Spacing.s) }
            Text(balance)
                .font(.title2.monospacedDigit().bold())
                .foregroundStyle(Palette.textPrimary)
        }
        .padding(Spacing.m)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Palette.surface, in: RoundedRectangle(cornerRadius: Radius.card, style: .continuous))
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("\(title), \(subtitle)")
        .accessibilityValue(spokenBalance)
    }
}
#endif
