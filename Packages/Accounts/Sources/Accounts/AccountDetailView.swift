#if canImport(UIKit)
import Core
import DesignSystem
import SwiftUI

public struct AccountDetailView: View {
    @State private var viewModel: AccountDetailViewModel
    @StateObject private var search = TransactionSearch()
    private let onRepeatTransfer: @MainActor (Transaction) -> Void

    public init(viewModel: AccountDetailViewModel, onRepeatTransfer: @escaping @MainActor (Transaction) -> Void = { _ in }) {
        _viewModel = State(initialValue: viewModel)
        self.onRepeatTransfer = onRepeatTransfer
    }

    public var body: some View {
        content
            .navigationTitle(title)
            .navigationBarTitleDisplayMode(.inline)
            .task {
                // .task is cancelled automatically when the view disappears.
                await viewModel.load()
                if case .loaded(_, let transactions) = viewModel.state { search.setTransactions(transactions) }
            }
    }

    private var title: String {
        if case .loaded(let account, _) = viewModel.state { return account.name }
        return "Account"
    }

    @ViewBuilder private var content: some View {
        switch viewModel.state {
        case .loading:
            ProgressView("Loading account")
        case .failed(let error):
            EmptyStateView(title: error.title, message: error.message, systemImage: "exclamationmark.triangle",
                           actionTitle: error.canRetry ? "Try again" : nil) {
                Task { await viewModel.load() }
            }
        case .loaded(let account, _):
            List {
                Section {
                    BalanceCard(title: "Available balance", subtitle: "Ending in \(account.lastFour)",
                                balance: account.balance.formatted(),
                                spokenBalance: account.balance.spokenDescription())
                        .listRowInsets(EdgeInsets())
                        .listRowBackground(Color.clear)
                        .accessibilityIdentifier("account.detail.balance")
                }
                Section {
                    if search.results.isEmpty {
                        Text("No matching transactions").foregroundStyle(Palette.textSecondary)
                    }
                    ForEach(search.results) { transaction in
                        TransactionRow(transaction)
                            // VoiceOver users get this from the rotor/actions menu without hunting for a button.
                            .accessibilityAction(named: "Repeat transfer") { onRepeatTransfer(transaction) }
                            .contextMenu {
                                Button("Repeat transfer", systemImage: "arrow.clockwise") { onRepeatTransfer(transaction) }
                            }
                    }
                } header: {
                    Text("Transactions").accessibilityAddTraits(.isHeader)
                }
            }
            .searchable(text: $search.query, prompt: "Search transactions")
            .refreshable { await viewModel.load() }
        }
    }
}
#endif
