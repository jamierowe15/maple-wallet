#if canImport(UIKit) && DEBUG
import SwiftUI

/// Every component on one screen, previewed in light, dark and AX5 text.
private struct ComponentGallery: View {
    var body: some View {
        ScrollView {
            VStack(spacing: Spacing.l) {
                BalanceCard(title: "Everyday Chequing", subtitle: "Chequing, ending in 4821", balance: "$1,234.56")
                VStack(spacing: 0) {
                    TransactionRow(merchant: "Payroll deposit", detail: "Nov 1", amount: "+$2,150.00", isCredit: true)
                    Divider()
                    TransactionRow(merchant: "Groceries", detail: "Oct 31", amount: "-$42.15", isCredit: false)
                }
                PrimaryButton("Send money") {}
                PrimaryButton("Sending", isLoading: true) {}
                EmptyStateView(title: "No transactions yet", message: "New activity shows up here.",
                               systemImage: "tray", actionTitle: "Refresh") {}
            }
            .padding(Spacing.m)
        }
    }
}

#Preview("Light") { ComponentGallery() }
#Preview("Dark") { ComponentGallery().preferredColorScheme(.dark) }
#Preview("AX5 text") { ComponentGallery().dynamicTypeSize(.accessibility5) }
#endif
