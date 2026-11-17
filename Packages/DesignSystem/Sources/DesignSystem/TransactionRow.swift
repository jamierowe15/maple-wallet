#if canImport(UIKit)
import SwiftUI

/// One transaction. Credit vs debit is shown with a sign, an icon AND colour,
/// so it still reads in greyscale.
public struct TransactionRow: View {
    private let merchant: String
    private let detail: String
    private let amount: String
    private let spokenAmount: String
    private let isCredit: Bool
    @Environment(\.dynamicTypeSize) private var typeSize

    public init(merchant: String, detail: String, amount: String, isCredit: Bool, spokenAmount: String? = nil) {
        self.merchant = merchant
        self.detail = detail
        self.amount = amount
        self.isCredit = isCredit
        self.spokenAmount = spokenAmount ?? amount
    }

    public var body: some View {
        let layout = typeSize.isAccessibilitySize
            ? AnyLayout(VStackLayout(alignment: .leading, spacing: Spacing.xs))
            : AnyLayout(HStackLayout(spacing: Spacing.m))

        layout {
            HStack(spacing: Spacing.m) {
                Image(systemName: isCredit ? "arrow.down.left.circle.fill" : "arrow.up.right.circle")
                    .font(.title2)
                    .foregroundStyle(isCredit ? Palette.credit : Palette.debit)
                    .accessibilityHidden(true)
                VStack(alignment: .leading, spacing: Spacing.xs) {
                    Text(merchant).font(.body).foregroundStyle(Palette.textPrimary)
                        .fixedSize(horizontal: false, vertical: true)
                    Text(detail).font(.subheadline).foregroundStyle(Palette.textSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            if !typeSize.isAccessibilitySize { Spacer(minLength: Spacing.s) }
            Text(amount)
                .font(.body.monospacedDigit().weight(.semibold))
                .foregroundStyle(isCredit ? Palette.credit : Palette.debit)
        }
        .padding(.vertical, Spacing.s)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("\(merchant), \(spokenAmount), \(detail)")
    }
}
#endif
